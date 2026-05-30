# -*- coding: utf-8 -*-
"""Bot scanner protection — block known WordPress/PHP exploit attempts.

Boty postoyanno skanyuyut publichnye sayty v poiske ustaravshih CMS
(WordPress, phpMyAdmin, etc). Ih zaprosy:
- Zasoryayut analitiku
- Tratyat resursy (CPU, BD na log, kazhdyy 404 = zapros do Flask)
- Mogut byt' nachalom razvedki pered atakoy

Eto promezhutochnyy module: blokiruet izvestnye paterny *do* togo
kak Flask render-it 404 stranicu.
"""
import re

# Pattern-y kotorye TOL'KO boty zaprashivayut. Lyuboy normal'nyy polzovatel'
# nikogda ne pereyti po /wp-admin ili /xmlrpc.php
_BOT_PATTERNS = [
    # WordPress
    re.compile(r"^/wp[-_/]"),
    re.compile(r"^/wordpress[/-]"),
    re.compile(r"^/xmlrpc\.php"),
    re.compile(r"\.php$"),
    re.compile(r"^/cms/"),
    re.compile(r"^/blog/wp-"),
    re.compile(r"^/site/wp-"),
    re.compile(r"^/old/wp-"),
    re.compile(r"^/test/wp-"),
    re.compile(r"^/tmp/wp-"),
    # PHP / phpMyAdmin
    re.compile(r"^/phpmyadmin"),
    re.compile(r"^/pma/"),
    re.compile(r"^/myadmin/"),
    re.compile(r"^/dbadmin/"),
    re.compile(r"^/sqlmanager/"),
    # Common config files
    re.compile(r"\.env$"),
    re.compile(r"^/\.env"),
    re.compile(r"^/\.git/"),
    re.compile(r"/config\.(json|yml|php)$"),
    re.compile(r"^/credentials"),
    re.compile(r"^/backup"),
    re.compile(r"\.sql$"),
    re.compile(r"\.bak$"),
    # Common shells
    re.compile(r"/(shell|cmd|backdoor|webshell|c99|r57)\.php"),
    # Vulnerability probes
    re.compile(r"/etc/passwd"),
    re.compile(r"\.\./"),
    re.compile(r"%2e%2e"),
    # Common admin panels
    re.compile(r"^/manager/"),
    re.compile(r"^/cgi-bin/"),
    re.compile(r"^/install\."),
]

# Suspicious User-Agent stroki — common scanners
_BOT_USER_AGENTS = re.compile(
    r"(masscan|nmap|sqlmap|nikto|wpscan|acunetix|nessus|"
    r"vuln|exploit|hack|payload|injection|xss|fuzz)",
    re.IGNORECASE
)


def is_bot_request(path: str, user_agent: str = "") -> bool:
    """True esli zapros vyglyadit kak bot/scanner attempt."""
    if not path:
        return False
    # Normalize
    path_lower = path.lower()
    # Check path patterns
    for p in _BOT_PATTERNS:
        if p.search(path_lower):
            return True
    # Check user agent
    if user_agent and _BOT_USER_AGENTS.search(user_agent):
        return True
    return False
