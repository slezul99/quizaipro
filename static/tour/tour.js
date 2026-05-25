/* === QuizAIPro Interactive Tour Engine === */
/* Lightweight tour: highlights real UI elements, no dependencies. */
/* Usage:
     QTour.start([
       { selector: '.btn-new-deck', title: 'Sozdai kolodu', body: '...', side: 'bottom' },
       ...
     ]);
*/
(function(global){
  'use strict';

  const STATE = {
    steps: [],
    current: 0,
    overlay: null,
    spotlight: null,
    tooltip: null,
    targetEl: null,
    onComplete: null,
    onSkip: null,
    waitingForClick: false,
  };

  // i18n labels (passed via QTour.i18n before start)
  const I18N = {
    next: 'Дальше',
    back: 'Назад',
    skip: 'Пропустить',
    finish: 'Готово',
    step: 'Шаг',
  };

  function ensureUI() {
    if (STATE.overlay) return;
    const ov = document.createElement('div');
    ov.className = 'qtour-overlay';
    ov.addEventListener('click', () => {
      if (!STATE.waitingForClick) skip();
    });
    document.body.appendChild(ov);
    STATE.overlay = ov;

    const spot = document.createElement('div');
    spot.className = 'qtour-spotlight';
    spot.style.display = 'none';
    document.body.appendChild(spot);
    STATE.spotlight = spot;

    const tip = document.createElement('div');
    tip.className = 'qtour-tooltip';
    tip.innerHTML = `
      <button class="qtour-close" type="button" aria-label="Close">×</button>
      <div class="qtour-step-num"></div>
      <div class="qtour-title"></div>
      <div class="qtour-body"></div>
      <div class="qtour-actions">
        <div class="qtour-progress"></div>
        <div class="qtour-buttons">
          <button class="qtour-btn qtour-btn-ghost qtour-back" type="button">${I18N.back}</button>
          <button class="qtour-btn qtour-btn-primary qtour-next" type="button">${I18N.next}</button>
        </div>
      </div>
    `;
    document.body.appendChild(tip);
    STATE.tooltip = tip;

    tip.querySelector('.qtour-close').addEventListener('click', skip);
    tip.querySelector('.qtour-back').addEventListener('click', back);
    tip.querySelector('.qtour-next').addEventListener('click', next);
  }

  function teardown() {
    if (STATE.overlay) STATE.overlay.classList.remove('qtour-active');
    if (STATE.spotlight) STATE.spotlight.style.display = 'none';
    if (STATE.tooltip) STATE.tooltip.classList.remove('qtour-visible');
    cleanupTargetListener();
    document.body.style.overflow = '';
    setTimeout(() => {
      if (STATE.overlay) { STATE.overlay.remove(); STATE.overlay = null; }
      if (STATE.spotlight) { STATE.spotlight.remove(); STATE.spotlight = null; }
      if (STATE.tooltip) { STATE.tooltip.remove(); STATE.tooltip = null; }
    }, 300);
  }

  let _targetClickHandler = null;
  function cleanupTargetListener() {
    if (STATE.targetEl && _targetClickHandler) {
      STATE.targetEl.removeEventListener('click', _targetClickHandler, true);
      _targetClickHandler = null;
    }
    STATE.waitingForClick = false;
    STATE.targetEl = null;
  }

  function showStep(i) {
    cleanupTargetListener();
    if (i < 0) i = 0;
    if (i >= STATE.steps.length) { finish(); return; }
    STATE.current = i;
    const s = STATE.steps[i];

    // Render text
    const tip = STATE.tooltip;
    tip.querySelector('.qtour-step-num').textContent = `${I18N.step} ${i+1} / ${STATE.steps.length}`;
    tip.querySelector('.qtour-title').textContent = s.title || '';
    tip.querySelector('.qtour-body').innerHTML = s.body || '';

    // Progress dots
    const prog = tip.querySelector('.qtour-progress');
    prog.innerHTML = '';
    for (let j = 0; j < STATE.steps.length; j++) {
      const d = document.createElement('div');
      d.className = 'qtour-dot' + (j < i ? ' qtour-dot-done' : (j === i ? ' qtour-dot-current' : ''));
      prog.appendChild(d);
    }

    // Buttons
    const backBtn = tip.querySelector('.qtour-back');
    const nextBtn = tip.querySelector('.qtour-next');
    backBtn.style.display = i === 0 ? 'none' : '';
    if (i === STATE.steps.length - 1) {
      nextBtn.textContent = I18N.finish;
    } else {
      nextBtn.textContent = I18N.next;
    }

    // Find target
    let target = null;
    if (s.selector) {
      target = document.querySelector(s.selector);
    }

    if (!target || s.floating) {
      // No target -> floating center tooltip
      STATE.spotlight.style.display = 'none';
      STATE.overlay.classList.add('qtour-floating-mode');
      tip.classList.add('qtour-tooltip-floating');
      // Clear inline positioning from previous targeted step (otherwise it overrides CSS center)
      tip.style.left = '';
      tip.style.top = '';
      requestAnimationFrame(() => tip.classList.add('qtour-visible'));
    } else {
      STATE.targetEl = target;
      STATE.overlay.classList.remove('qtour-floating-mode');
      tip.classList.remove('qtour-tooltip-floating');

      // Scroll target into view
      target.scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' });

      setTimeout(() => {
        positionSpotlightAndTooltip(target, s);
        tip.classList.add('qtour-visible');

        // If "wait for click" mode — listen for click on target
        if (s.waitForClick) {
          STATE.waitingForClick = true;
          nextBtn.textContent = '↑ ' + (s.clickHint || 'Нажмите на подсвеченный элемент');
          nextBtn.disabled = true;
          nextBtn.style.opacity = '0.5';
          nextBtn.style.cursor = 'not-allowed';

          _targetClickHandler = function(e){
            // Don't prevent — let it work naturally
            // Move to next step after small delay (chtoby Alpine uspel obrabotat')
            var delay = (s.afterClickDelayMs && s.afterClickDelayMs > 0) ? s.afterClickDelayMs : 400;
            setTimeout(next, delay);
          };
          // capture: false chtoby native handlers (Alpine, etc.) srabotali pervymi
          target.addEventListener('click', _targetClickHandler, { once: true });
        } else {
          nextBtn.disabled = false;
          nextBtn.style.opacity = '';
          nextBtn.style.cursor = '';
        }
      }, 350); // wait scroll to settle
    }
  }

  function positionSpotlightAndTooltip(target, step) {
    const rect = target.getBoundingClientRect();
    const pad = step.padding != null ? step.padding : 8;

    // Spotlight
    STATE.spotlight.style.display = 'block';
    STATE.spotlight.style.left = (rect.left - pad) + 'px';
    STATE.spotlight.style.top = (rect.top - pad) + 'px';
    STATE.spotlight.style.width = (rect.width + pad*2) + 'px';
    STATE.spotlight.style.height = (rect.height + pad*2) + 'px';

    // Tooltip — auto-place
    const tip = STATE.tooltip;
    const tipRect = tip.getBoundingClientRect();
    const tipW = tipRect.width || 380;
    const tipH = tipRect.height || 200;
    const margin = 16;
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    let left, top;
    const side = step.side || 'auto';

    function placeBelow() {
      top = rect.bottom + margin;
      left = rect.left + rect.width/2 - tipW/2;
    }
    function placeAbove() {
      top = rect.top - tipH - margin;
      left = rect.left + rect.width/2 - tipW/2;
    }
    function placeRight() {
      left = rect.right + margin;
      top = rect.top + rect.height/2 - tipH/2;
    }
    function placeLeft() {
      left = rect.left - tipW - margin;
      top = rect.top + rect.height/2 - tipH/2;
    }

    if (side === 'top') placeAbove();
    else if (side === 'left') placeLeft();
    else if (side === 'right') placeRight();
    else if (side === 'bottom') placeBelow();
    else {
      // auto: try below, then above, then right, then left
      placeBelow();
      if (top + tipH > vh - margin) {
        placeAbove();
        if (top < margin) {
          placeRight();
          if (left + tipW > vw - margin) placeLeft();
        }
      }
    }

    // Clamp to viewport
    left = Math.max(margin, Math.min(left, vw - tipW - margin));
    top = Math.max(margin, Math.min(top, vh - tipH - margin));

    tip.style.left = left + 'px';
    tip.style.top = top + 'px';
  }

  function next() { showStep(STATE.current + 1); }
  function back() { showStep(STATE.current - 1); }
  function skip() {
    if (STATE.onSkip) STATE.onSkip();
    teardown();
  }
  function finish() {
    if (STATE.onComplete) STATE.onComplete();
    teardown();
  }

  function start(steps, opts) {
    if (!steps || !steps.length) return;
    STATE.steps = steps;
    STATE.current = 0;
    STATE.onComplete = opts && opts.onComplete;
    STATE.onSkip = opts && opts.onSkip;
    ensureUI();
    document.body.style.overflow = 'hidden';
    requestAnimationFrame(() => {
      STATE.overlay.classList.add('qtour-active');
      showStep(0);
    });
  }

  function setI18n(obj) {
    Object.assign(I18N, obj || {});
  }

  // Repaint on resize / scroll (to keep spotlight aligned)
  window.addEventListener('resize', () => {
    if (STATE.targetEl && STATE.steps[STATE.current]) {
      positionSpotlightAndTooltip(STATE.targetEl, STATE.steps[STATE.current]);
    }
  });
  window.addEventListener('scroll', () => {
    if (STATE.targetEl && STATE.steps[STATE.current]) {
      positionSpotlightAndTooltip(STATE.targetEl, STATE.steps[STATE.current]);
    }
  }, { passive: true });

  global.QTour = { start, setI18n, skip, next, back };
})(window);
