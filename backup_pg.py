# -*- coding: utf-8 -*-
"""Free logical backup for the production Postgres (no pg_dump binary needed).

Pure psycopg: dumps every public table to a single gzipped JSON file, keeps the
last N, and can restore. Designed to be run either from the in-app scheduler
(app.py) or standalone:

    DATABASE_URL=postgres://...  python backup_pg.py                 # make a backup
    DATABASE_URL=postgres://...  python backup_pg.py --list          # list backups
    DATABASE_URL=postgres://...  python backup_pg.py --restore FILE  # restore (destructive)

Backups live in $BACKUP_DIR (default $DATA_DIR/backups, i.e. the web volume —
a separate failure domain from the Postgres service). Format is versioned JSON:
{"_meta": {...}, "table": {"columns": [...], "rows": [[...], ...]}, ...}.
"""
import os
import io
import gzip
import json
import glob
import time
from datetime import datetime, timezone
from pathlib import Path

KEEP = int(os.environ.get("BACKUP_KEEP", "7"))


def _backup_dir() -> Path:
    d = os.environ.get("BACKUP_DIR") or str(
        Path(os.environ.get("DATA_DIR") or Path(__file__).resolve().parent) / "backups")
    p = Path(d)
    p.mkdir(parents=True, exist_ok=True)
    return p


def _connect(url=None):
    import psycopg
    url = url or os.environ.get("DATABASE_URL", "").strip()
    if not url:
        raise SystemExit("backup_pg: DATABASE_URL not set (Postgres target).")
    return psycopg.connect(url, connect_timeout=15)


def _tables(conn):
    rows = conn.execute(
        "SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename"
    ).fetchall()
    return [r[0] for r in rows]


def _q(name):  # quote identifier
    return '"%s"' % name.replace('"', '""')


def run_backup(log=print) -> str:
    """Dump all tables to a new gzipped JSON file. Returns the file path."""
    conn = _connect()
    try:
        tables = _tables(conn)
        payload = {"_meta": {
            "created_at": datetime.now(timezone.utc).isoformat(),
            "format": 1, "tables": len(tables),
        }}
        total = 0
        for t in tables:
            cur = conn.execute("SELECT * FROM %s" % _q(t))
            cols = [d.name for d in cur.description] if cur.description else []
            rows = cur.fetchall()
            payload[t] = {"columns": cols, "rows": [list(r) for r in rows]}
            total += len(rows)
        payload["_meta"]["rows"] = total
    finally:
        conn.close()

    ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    dest = _backup_dir() / f"pgbackup-{ts}.json.gz"
    buf = io.BytesIO()
    with gzip.GzipFile(fileobj=buf, mode="wb") as gz:
        gz.write(json.dumps(payload, default=str, ensure_ascii=False).encode("utf-8"))
    dest.write_bytes(buf.getvalue())
    log("[backup_pg] wrote %s (%d tables, %d rows, %d KB)" % (
        dest.name, len(payload) - 1, total, len(buf.getvalue()) // 1024))
    _rotate(log)
    return str(dest)


def _rotate(log=print):
    files = sorted(_backup_dir().glob("pgbackup-*.json.gz"))
    excess = len(files) - KEEP
    for f in files[:max(0, excess)]:
        try:
            f.unlink(); log("[backup_pg] rotated out %s" % f.name)
        except OSError:
            pass


def list_backups() -> list[dict]:
    out = []
    for f in sorted(_backup_dir().glob("pgbackup-*.json.gz"), reverse=True):
        st = f.stat()
        out.append({"name": f.name, "size": st.st_size, "mtime": st.st_mtime,
                    "path": str(f)})
    return out


def latest_backup_age_hours():
    files = list_backups()
    if not files:
        return None
    return (time.time() - files[0]["mtime"]) / 3600.0


def restore(path, log=print):
    """DESTRUCTIVE: wipe every table and reload from the dump. Superuser needed
    (Railway's postgres role is) for session_replication_role."""
    data = json.loads(gzip.open(path, "rb").read().decode("utf-8"))
    conn = _connect()
    try:
        cur = conn.cursor()
        cur.execute("SET session_replication_role = replica")  # disable FK/triggers
        tabs = [t for t in data if t != "_meta"]
        for t in tabs:
            cur.execute("DELETE FROM %s" % _q(t))
        conn.commit()
        for t in tabs:
            cols = data[t]["columns"]; rows = data[t]["rows"]
            if not rows:
                continue
            collist = ", ".join(_q(c) for c in cols)
            ph = ", ".join(["%s"] * len(cols))
            sql = "INSERT INTO %s (%s) VALUES (%s)" % (_q(t), collist, ph)
            cur.executemany(sql, [tuple(r) for r in rows])
            conn.commit()
            log("[restore] %s: %d rows" % (t, len(rows)))
        # reseed identity sequences
        for t in tabs:
            if "id" in data[t]["columns"]:
                cur.execute(
                    "SELECT setval(pg_get_serial_sequence(%s,'id'), "
                    "GREATEST((SELECT COALESCE(MAX(id),0) FROM %s),1)) "
                    "WHERE pg_get_serial_sequence(%s,'id') IS NOT NULL"
                    % ("%s", _q(t), "%s"), (t, t))
        cur.execute("SET session_replication_role = DEFAULT")
        conn.commit()
        log("[restore] done: %d tables" % len(tabs))
    finally:
        conn.close()


if __name__ == "__main__":
    import sys
    if "--list" in sys.argv:
        for b in list_backups():
            print("%s  %8d KB  %s" % (
                datetime.fromtimestamp(b["mtime"]).strftime("%Y-%m-%d %H:%M"),
                b["size"] // 1024, b["name"]))
    elif "--restore" in sys.argv:
        i = sys.argv.index("--restore")
        f = sys.argv[i + 1]
        if "--yes" not in sys.argv:
            if input("DESTRUCTIVE restore from %s — proceed? [y/N] " % f).strip().lower() != "y":
                sys.exit(1)
        restore(f)
    else:
        run_backup()
