/* QuizAIPro — Growth Stages, premium web edition.
   Canvas particle engine with additive bloom + a cinematic full-screen lightbox.
   One shared rAF loop drives visible card canvases and the open lightbox. */
(function () {
  "use strict";

  var DPR = Math.min(window.devicePixelRatio || 1, 2);
  var reduce = window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var cards = [];
  var lightbox = null;

  function hexA(hex, a) {
    hex = (hex || "#fff").replace("#", "");
    if (hex.length === 3) hex = hex.split("").map(function (x){return x+x;}).join("");
    var r = parseInt(hex.substr(0,2),16), g = parseInt(hex.substr(2,2),16), b = parseInt(hex.substr(4,2),16);
    return "rgba(" + r + "," + g + "," + b + "," + a + ")";
  }
  function rnd(i, s) { var v = Math.sin((i + 1) * 12.9898 * s) * 43758.5453; return v - Math.floor(v); }

  function TreeFX(canvas, opts) {
    opts = opts || {};
    this.c = canvas; this.ctx = canvas.getContext("2d");
    this.mode = canvas.dataset.fx || "none";
    this.glow = canvas.dataset.glow || "#ffffff";
    this.ring = canvas.dataset.ring === "1";
    this.colors = (canvas.dataset.colors || this.glow).split(",");
    this.count = parseInt(canvas.dataset.count || "16", 10);
    this.scale = opts.scale || 1;       // particle-count / glow multiplier
    this.visible = true;
    this.resize();
  }
  TreeFX.prototype.refresh = function () {
    this.mode = this.c.dataset.fx || "none";
    this.glow = this.c.dataset.glow || "#ffffff";
    this.ring = this.c.dataset.ring === "1";
    this.colors = (this.c.dataset.colors || this.glow).split(",");
    this.count = parseInt(this.c.dataset.count || "16", 10);
  };
  TreeFX.prototype.resize = function () {
    var r = this.c.getBoundingClientRect();
    this.w = Math.max(1, r.width); this.h = Math.max(1, r.height);
    this.c.width = this.w * DPR; this.c.height = this.h * DPR;
    this.ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
  };
  TreeFX.prototype.n = function (b) { return Math.round(b * this.scale); };
  TreeFX.prototype.shape = function (kind, x, y, s, rot, color) {
    var ctx = this.ctx; ctx.fillStyle = color;
    if (kind === "dot") { ctx.beginPath(); ctx.arc(x, y, s, 0, 6.283); ctx.fill(); return; }
    ctx.save(); ctx.translate(x, y); ctx.rotate(rot);
    if (kind === "petal") { ctx.beginPath(); ctx.ellipse(0,0,s*0.95,s*0.55,0,0,6.283); ctx.fill(); }
    else if (kind === "leaf") { ctx.beginPath(); ctx.moveTo(-s,0); ctx.quadraticCurveTo(0,-s*0.9,s,0); ctx.quadraticCurveTo(0,s*0.9,-s,0); ctx.fill(); }
    else if (kind === "diamond") { ctx.rotate(0.785); ctx.fillRect(-s,-s,s*2,s*2); }
    else if (kind === "star") { ctx.beginPath(); for (var k=0;k<4;k++){var a=k*1.5708; ctx.lineTo(Math.cos(a)*s*1.9,Math.sin(a)*s*1.9); var am=a+0.785; ctx.lineTo(Math.cos(am)*s*0.5,Math.sin(am)*s*0.5);} ctx.closePath(); ctx.fill(); }
    ctx.restore();
  };
  TreeFX.prototype.draw = function (t) {
    var ctx=this.ctx, w=this.w, h=this.h, cx=w/2, cy=h/2, i, p, cols=this.colors, m=this.mode;
    ctx.clearRect(0,0,w,h);
    ctx.save();
    ctx.globalCompositeOperation = "lighter";   // additive bloom
    ctx.shadowColor = this.glow; ctx.shadowBlur = w * 0.02 * this.scale;

    if (this.ring) {
      var rr = w*0.4;
      ctx.save(); ctx.lineWidth = w*0.014*this.scale; ctx.lineCap="round";
      if (ctx.createConicGradient){ var cg=ctx.createConicGradient(t*6.283,cx,cy);
        cg.addColorStop(0,hexA(this.glow,0)); cg.addColorStop(0.5,hexA(this.glow,0.9)); cg.addColorStop(1,hexA(this.glow,0));
        ctx.strokeStyle=cg; } else ctx.strokeStyle=hexA(this.glow,0.5);
      ctx.beginPath(); ctx.arc(cx,cy,rr,0,6.283); ctx.stroke(); ctx.restore();
    }

    if (m==="petals"||m==="autumnLeaves") {
      var leaf=m==="autumnLeaves", N=this.n(leaf?16:18);
      for(i=0;i<N;i++){ p=(t+rnd(i,1.7))%1; var x0=rnd(i,2.3)*w;
        var sp=rnd(i,4.1)>0.7?Math.sin(p*12.56)*w*0.05:0;
        var x=x0+Math.sin(p*6.283+i)*w*0.07+sp, y=p*h*1.08-h*0.04;
        var f=p<0.1?p/0.1:p>0.85?(1-p)/0.15:1;
        this.shape(leaf?"leaf":"petal",x,y,w*(0.02+rnd(i,3.5)*0.018),p*18.8+i,hexA(cols[i%cols.length],0.9*f)); }
    } else if (m==="sunRising"||m==="goldRising"||m==="greenMotes") {
      var slow=m==="greenMotes"?0.6:1, N2=this.n(m==="goldRising"?22:14);
      for(i=0;i<N2;i++){ p=(t*slow+rnd(i,1.3))%1;
        var rx=(0.12+rnd(i,2.7)*0.76)*w+Math.sin(p*6.283+i)*w*0.03, ry=h*(0.96-p*0.9);
        var ff=p<0.15?p/0.15:p>0.8?(1-p)/0.2:1;
        this.shape("dot",rx,ry,w*(0.008+rnd(i,3.1)*0.013),0,hexA(cols[i%cols.length],0.85*ff)); }
    } else if (m==="sparks") {
      var N3=this.n(16);
      for(i=0;i<N3;i++){ var an=rnd(i,1.9)*6.283, rad=(0.08+rnd(i,2.2)*0.36)*w;
        var sx=cx+Math.cos(an)*rad, sy=cy+0.14*h+Math.sin(an)*rad*0.55;
        var tw=(Math.sin(t*6.283+i*1.7)+1)/2;
        this.shape("star",sx,sy,w*(0.006+tw*0.015),0,hexA(cols[i%cols.length],0.3+0.7*tw)); }
    } else if (m==="purpleOrbit"||m==="crystals"||m==="stars") {
      var kind=m==="crystals"?"diamond":m==="stars"?"star":"dot", N4=this.n(18);
      for(i=0;i<N4;i++){ var dir=rnd(i,5)>0.5?1:-1, base=i*(6.283/N4), a2=base+dir*t*6.283;
        var rad2=(0.28+rnd(i,2.6)*0.2)*w, ox=cx+Math.cos(a2)*rad2, oy=cy+Math.sin(a2)*rad2*0.62;
        var sh=(Math.sin(t*12.56+i)+1)/2;
        this.shape(kind,ox,oy,w*(0.012+rnd(i,3.3)*0.014),a2,hexA(cols[i%cols.length],0.45+0.55*sh)); }
      if(m==="crystals"){ var N5=this.n(8); for(i=0;i<N5;i++){ var pp=(t*0.6+rnd(i,9))%1;
        this.shape("dot",(0.2+rnd(i,7)*0.6)*w,h*(0.96-pp*0.9),w*0.01,0,hexA(cols[0],0.7*(1-Math.abs(pp-0.5)*2))); } }
    }
    ctx.restore();
  };

  // ── shared loop ─────────────────────────────────────────────
  function loop(ts) {
    var t = (ts % 7000) / 7000;
    for (var i = 0; i < cards.length; i++) if (cards[i].visible) cards[i].draw(t);
    if (lightbox && lightbox.open && lightbox.fx) {
      lightbox.fx.draw(t);
      var ph = 6 * Math.sin(ts / 2200), pv = 4 * Math.cos(ts / 2600);
      lightbox.img.style.transform = "scale(1.06) translate(" + (lightbox.mx + ph) + "px," + (lightbox.my + pv) + "px)";
    }
    requestAnimationFrame(loop);
  }

  // ── lightbox ────────────────────────────────────────────────
  function buildLightbox() {
    var o = document.createElement("div");
    o.className = "gt-lb";
    o.innerHTML =
      '<img class="gt-lb-img" alt="">' +
      '<canvas class="gt-lb-canvas" data-fx="none"></canvas>' +
      '<div class="gt-lb-vig"></div>' +
      '<button class="gt-lb-close" aria-label="Закрыть">&times;</button>' +
      '<div class="gt-lb-cap"><span class="gt-lb-range"></span>' +
      '<div class="gt-lb-title"></div><div class="gt-lb-hint">Нажмите, чтобы закрыть</div></div>';
    document.body.appendChild(o);
    lightbox = {
      el: o, open: false, mx: 0, my: 0, fx: null,
      img: o.querySelector(".gt-lb-img"),
      canvas: o.querySelector(".gt-lb-canvas"),
      range: o.querySelector(".gt-lb-range"),
      title: o.querySelector(".gt-lb-title"),
    };
    function close() {
      lightbox.open = false; o.classList.remove("show");
      document.body.style.overflow = "";
      setTimeout(function () { o.style.display = "none"; }, 350);
    }
    o.addEventListener("click", function (e) {
      if (e.target === lightbox.img || e.target === lightbox.canvas ||
          e.target.classList.contains("gt-lb-vig") || e.target === o ||
          e.target.classList.contains("gt-lb-close")) close();
    });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape" && lightbox.open) close(); });
    o.addEventListener("pointermove", function (e) {
      var px = e.clientX / window.innerWidth - 0.5, py = e.clientY / window.innerHeight - 0.5;
      lightbox.mx = -px * 28; lightbox.my = -py * 22;
    });
  }
  function openLightbox(card) {
    if (!lightbox) buildLightbox();
    var lb = lightbox;
    lb.img.src = card.dataset.wide || card.dataset.img;
    lb.title.textContent = card.dataset.title;
    lb.title.style.color = card.dataset.accent;
    lb.range.innerHTML = "⚡ " + card.dataset.range;
    lb.range.style.background = card.dataset.accent;
    lb.canvas.dataset.fx = card.dataset.fx;
    lb.canvas.dataset.glow = card.dataset.glow;
    lb.canvas.dataset.colors = card.dataset.colors;
    lb.canvas.dataset.ring = card.dataset.ring;
    lb.el.style.display = "block";
    lb.el.style.setProperty("--lb-glow", card.dataset.glow);
    requestAnimationFrame(function () {
      lb.el.classList.add("show");
      if (!lb.fx) lb.fx = new TreeFX(lb.canvas, { scale: reduce ? 1 : 2.4 });
      else { lb.fx.scale = reduce ? 1 : 2.4; lb.fx.resize(); lb.fx.refresh(); }
      lb.open = true;
    });
    document.body.style.overflow = "hidden";
  }
  window.gtOpen = function (card) { openLightbox(card); };

  function init() {
    document.querySelectorAll(".gt-card canvas[data-fx]").forEach(function (cv) {
      var fx = new TreeFX(cv, { scale: 1.2 }); cv._fx = fx; cards.push(fx);
    });
    var bgCv = document.getElementById("gt-bg-canvas");
    if (bgCv) { var bfx = new TreeFX(bgCv, { scale: 1.9 }); bgCv._fx = bfx; cards.push(bfx); }

    // Honour reduced-motion: render a single static frame, no animation loop.
    if (reduce) {
      cards.forEach(function (x) { try { x.draw(0.35); } catch (e) {} });
      return;
    }

    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) { var f = cards.find(function (x){return x.c===e.target;}); if (f) f.visible = e.isIntersecting; });
    }, { threshold: 0.04 });
    cards.forEach(function (x) { io.observe(x.c); });

    var rt; window.addEventListener("resize", function () {
      clearTimeout(rt); rt = setTimeout(function () {
        cards.forEach(function (x) { x.resize(); }); if (lightbox && lightbox.fx) lightbox.fx.resize();
      }, 150);
    });

    requestAnimationFrame(loop);

    // Hero 3D parallax.
    var hero = document.querySelector(".gt-hero-art");
    if (hero && !reduce) {
      var wrap = hero.closest(".gt-hero") || hero;
      wrap.addEventListener("pointermove", function (ev) {
        var r = wrap.getBoundingClientRect();
        var px = (ev.clientX - r.left) / r.width - 0.5, py = (ev.clientY - r.top) / r.height - 0.5;
        hero.style.transform = "rotateY(" + px*12 + "deg) rotateX(" + (-py*12) + "deg) translateZ(24px)";
      });
      wrap.addEventListener("pointerleave", function () { hero.style.transform = ""; });
    }
  }

  if (document.readyState !== "loading") init();
  else document.addEventListener("DOMContentLoaded", init);
})();
