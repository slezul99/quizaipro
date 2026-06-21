/* QuizAIPro — Growth Stages tree animations (web).
   A lightweight canvas particle engine: each <canvas data-fx="..."> overlays a
   tree image and renders a per-stage effect (petals, leaves, sparks, motes,
   orbits, crystals, stars) plus an optional rotating energy ring. One shared
   rAF loop drives every visible instance; offscreen canvases are paused via an
   IntersectionObserver so the page stays smooth. */
(function () {
  "use strict";

  var DPR = Math.min(window.devicePixelRatio || 1, 2);
  var instances = [];
  var reduceMotion = window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function hexA(hex, a) {
    hex = hex.replace("#", "");
    var r = parseInt(hex.substr(0, 2), 16),
      g = parseInt(hex.substr(2, 2), 16),
      b = parseInt(hex.substr(4, 2), 16);
    return "rgba(" + r + "," + g + "," + b + "," + a + ")";
  }
  function rnd(i, salt) {
    var v = Math.sin((i + 1) * 12.9898 * salt) * 43758.5453;
    return v - Math.floor(v);
  }

  function TreeFX(canvas) {
    this.c = canvas;
    this.ctx = canvas.getContext("2d");
    this.mode = canvas.dataset.fx || "none";
    this.glow = canvas.dataset.glow || "#ffffff";
    this.ring = canvas.dataset.ring === "1";
    this.colors = (canvas.dataset.colors || this.glow).split(",");
    this.visible = false;
    this.w = 0;
    this.h = 0;
    this.count = parseInt(canvas.dataset.count || "14", 10);
    this.resize();
  }
  TreeFX.prototype.refresh = function () {
    this.mode = this.c.dataset.fx || "none";
    this.glow = this.c.dataset.glow || "#ffffff";
    this.ring = this.c.dataset.ring === "1";
    this.colors = (this.c.dataset.colors || this.glow).split(",");
    this.count = parseInt(this.c.dataset.count || "14", 10);
  };
  TreeFX.prototype.resize = function () {
    var r = this.c.getBoundingClientRect();
    this.w = Math.max(1, r.width);
    this.h = Math.max(1, r.height);
    this.c.width = this.w * DPR;
    this.c.height = this.h * DPR;
    this.ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
  };
  TreeFX.prototype.shape = function (kind, x, y, s, rot, color) {
    var ctx = this.ctx;
    ctx.fillStyle = color;
    if (kind === "dot") {
      ctx.beginPath();
      ctx.arc(x, y, s, 0, 6.283);
      ctx.fill();
    } else if (kind === "petal" || kind === "leaf") {
      ctx.save();
      ctx.translate(x, y);
      ctx.rotate(rot);
      ctx.beginPath();
      if (kind === "petal") {
        ctx.ellipse(0, 0, s * 0.95, s * 0.55, 0, 0, 6.283);
      } else {
        ctx.moveTo(-s, 0);
        ctx.quadraticCurveTo(0, -s * 0.9, s, 0);
        ctx.quadraticCurveTo(0, s * 0.9, -s, 0);
      }
      ctx.fill();
      ctx.restore();
    } else if (kind === "diamond") {
      ctx.save();
      ctx.translate(x, y);
      ctx.rotate(0.785);
      ctx.fillRect(-s, -s, s * 2, s * 2);
      ctx.restore();
    } else if (kind === "star") {
      ctx.save();
      ctx.translate(x, y);
      ctx.beginPath();
      for (var k = 0; k < 4; k++) {
        var a = k * 1.5708;
        ctx.lineTo(Math.cos(a) * s * 1.9, Math.sin(a) * s * 1.9);
        var am = a + 0.785;
        ctx.lineTo(Math.cos(am) * s * 0.55, Math.sin(am) * s * 0.55);
      }
      ctx.closePath();
      ctx.fill();
      ctx.restore();
    }
  };
  TreeFX.prototype.draw = function (t) {
    var ctx = this.ctx,
      w = this.w,
      h = this.h,
      cx = w / 2,
      cy = h / 2,
      i,
      p,
      n = this.count,
      cols = this.colors;
    ctx.clearRect(0, 0, w, h);

    // Rotating energy ring.
    if (this.ring) {
      var rr = w * 0.4;
      var grad = ctx.createConicGradient
        ? ctx.createConicGradient(t * 6.283, cx, cy)
        : null;
      ctx.save();
      ctx.lineWidth = w * 0.016;
      ctx.lineCap = "round";
      if (grad) {
        grad.addColorStop(0, hexA(this.glow, 0));
        grad.addColorStop(0.5, hexA(this.glow, 0.85));
        grad.addColorStop(1, hexA(this.glow, 0));
        ctx.strokeStyle = grad;
      } else {
        ctx.strokeStyle = hexA(this.glow, 0.5);
      }
      ctx.beginPath();
      ctx.arc(cx, cy, rr, 0, 6.283);
      ctx.stroke();
      ctx.restore();
    }

    var m = this.mode;
    if (m === "petals" || m === "autumnLeaves") {
      var leaf = m === "autumnLeaves";
      for (i = 0; i < n; i++) {
        p = (t + rnd(i, 1.7)) % 1;
        var x0 = rnd(i, 2.3) * w;
        var spin = rnd(i, 4.1) > 0.7 ? Math.sin(p * 12.56) * w * 0.05 : 0;
        var x = x0 + Math.sin(p * 6.283 + i) * w * 0.06 + spin;
        var y = p * h * 1.08 - h * 0.04;
        var fade = p < 0.1 ? p / 0.1 : p > 0.85 ? (1 - p) / 0.15 : 1;
        this.shape(leaf ? "leaf" : "petal", x, y, w * (0.02 + rnd(i, 3.5) * 0.016),
          p * 18.8 + i, hexA(cols[i % cols.length], 0.85 * fade));
      }
    } else if (m === "sunRising" || m === "goldRising" || m === "greenMotes") {
      var slow = m === "greenMotes" ? 0.6 : 1;
      for (i = 0; i < n; i++) {
        p = (t * slow + rnd(i, 1.3)) % 1;
        var rx = (0.15 + rnd(i, 2.7) * 0.7) * w + Math.sin(p * 6.283 + i) * w * 0.03;
        var ry = h * (0.95 - p * 0.85);
        var f = p < 0.15 ? p / 0.15 : p > 0.8 ? (1 - p) / 0.2 : 1;
        this.shape("dot", rx, ry, w * (0.009 + rnd(i, 3.1) * 0.012),
          0, hexA(cols[i % cols.length], 0.8 * f));
      }
    } else if (m === "sparks") {
      for (i = 0; i < n; i++) {
        var ang = rnd(i, 1.9) * 6.283;
        var rad = (0.1 + rnd(i, 2.2) * 0.34) * w;
        var sx = cx + Math.cos(ang) * rad;
        var sy = cy + 0.16 * h + Math.sin(ang) * rad * 0.5;
        var tw = (Math.sin(t * 6.283 + i * 1.7) + 1) / 2;
        this.shape("star", sx, sy, w * (0.006 + tw * 0.013), 0,
          hexA(cols[i % cols.length], 0.25 + 0.75 * tw));
      }
    } else if (m === "purpleOrbit" || m === "crystals" || m === "stars") {
      var kind = m === "crystals" ? "diamond" : m === "stars" ? "star" : "dot";
      for (i = 0; i < n; i++) {
        var dir = rnd(i, 5) > 0.5 ? 1 : -1;
        var base = i * (6.283 / n);
        var a2 = base + dir * t * 6.283;
        var rad2 = (0.3 + rnd(i, 2.6) * 0.17) * w;
        var ox = cx + Math.cos(a2) * rad2;
        var oy = cy + Math.sin(a2) * rad2 * 0.62;
        var sh = (Math.sin(t * 12.56 + i) + 1) / 2;
        this.shape(kind, ox, oy, w * (0.013 + rnd(i, 3.3) * 0.013), a2,
          hexA(cols[i % cols.length], 0.4 + 0.55 * sh));
      }
      if (m === "crystals") {
        for (i = 0; i < 6; i++) {
          var pp = (t * 0.6 + rnd(i, 9)) % 1;
          this.shape("dot", (0.2 + rnd(i, 7) * 0.6) * w, h * (0.95 - pp * 0.85),
            w * 0.01, 0, hexA(cols[0], 0.6 * (1 - Math.abs(pp - 0.5) * 2)));
        }
      }
    }
  };

  var last = 0;
  function loop(ts) {
    var t = (ts % 7000) / 7000; // 7s loop
    for (var i = 0; i < instances.length; i++) {
      if (instances[i].visible) instances[i].draw(t);
    }
    requestAnimationFrame(loop);
  }

  function init() {
    var canvases = document.querySelectorAll("canvas[data-fx]");
    canvases.forEach(function (cv) {
      var inst = new TreeFX(cv);
      cv._fx = inst;
      instances.push(inst);
    });
    if (!instances.length) return;

    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        var inst = instances.find(function (x) { return x.c === e.target; });
        if (inst) inst.visible = e.isIntersecting;
      });
    }, { threshold: 0.05 });
    instances.forEach(function (x) { io.observe(x.c); });

    var rt;
    window.addEventListener("resize", function () {
      clearTimeout(rt);
      rt = setTimeout(function () {
        instances.forEach(function (x) { x.resize(); });
      }, 150);
    });

    if (!reduceMotion) requestAnimationFrame(loop);
    else instances.forEach(function (x) { x.visible = true; x.draw(0.2); });

    // Hero parallax on pointer move (subtle 3D tilt).
    var hero = document.querySelector(".gt-hero-art");
    if (hero && !reduceMotion) {
      var wrap = hero.closest(".gt-hero");
      (wrap || hero).addEventListener("pointermove", function (ev) {
        var r = (wrap || hero).getBoundingClientRect();
        var px = (ev.clientX - r.left) / r.width - 0.5;
        var py = (ev.clientY - r.top) / r.height - 0.5;
        hero.style.transform =
          "rotateY(" + px * 10 + "deg) rotateX(" + -py * 10 + "deg) translateZ(20px)";
      });
      (wrap || hero).addEventListener("pointerleave", function () {
        hero.style.transform = "";
      });
    }
  }

  if (document.readyState !== "loading") init();
  else document.addEventListener("DOMContentLoaded", init);
})();
