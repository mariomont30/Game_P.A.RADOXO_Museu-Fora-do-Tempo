(() => {
  let pending = null;
  let started = false;
  const dialog = document.getElementById('nameDialog');
  const input = document.getElementById('mobileName');
  const coarse = matchMedia('(pointer:coarse)').matches || navigator.maxTouchPoints > 0;
  document.documentElement.classList.toggle('mobile-web', coarse);
  window.paradoxo = {
    ready: false,
    loadingFailed: false,
    start: null,
    setReduced(value) {
      document.documentElement.classList.toggle('reduced-motion', value || matchMedia('(prefers-reduced-motion:reduce)').matches);
      try { localStorage.setItem('paradoxo-reduced-motion', String(value)); } catch {}
    },
    takeName() { const result = pending; pending = null; return result; },
    openName(value) {
      if (dialog.open) return;
      input.value = value;
      dialog.showModal();
      input.focus();
    },
    launch() {
      if (started || this.loadingFailed || typeof this.start !== 'function') return;
      started = true;
      document.getElementById('enterMuseum').disabled = true;
      document.getElementById('welcome').style.display = 'none';
      document.getElementById('status').style.visibility = 'visible';
      if (coarse) {
        const request = document.documentElement.requestFullscreen;
        if (request) request.call(document.documentElement)
          .then(() => screen.orientation?.lock?.('landscape')).catch(() => {});
      }
      try { Promise.resolve(this.start()).catch(window.paradoxoLoadFailure); }
      catch (error) { window.paradoxoLoadFailure(error); }
    }
  };
  try { window.paradoxo.setReduced(localStorage.getItem('paradoxo-reduced-motion') === 'true'); } catch { window.paradoxo.setReduced(false); }
  document.getElementById('nameForm').addEventListener('submit', event => {
    event.preventDefault();
    pending = input.value;
    dialog.close();
    document.getElementById('canvas').focus();
  });
  document.getElementById('cancelName').addEventListener('click', () => {
    dialog.close();
    document.getElementById('canvas').focus();
  });
  const orientation = () => { window.paradoxo.portrait = coarse && innerHeight > innerWidth; };
  addEventListener('resize', orientation);
  orientation();
  const welcome = document.getElementById('welcome');
  const content = welcome.querySelector('.welcome-content');
  welcome.addEventListener('pointermove', event => {
    if (coarse || document.documentElement.classList.contains('reduced-motion')) return;
    welcome.style.setProperty('--scene-dx', ((event.clientX / innerWidth - .5) * 14) + 'px');
    welcome.style.setProperty('--scene-dy', ((event.clientY / innerHeight - .5) * 10) + 'px');
  });
  welcome.addEventListener('pointerleave', () => { welcome.style.setProperty('--scene-dx','0px'); welcome.style.setProperty('--scene-dy','0px'); });
  let fitFrame = 0;
  const fitWelcome = () => {
    if (getComputedStyle(welcome).display === 'none') return;
    const style = getComputedStyle(welcome);
    const availableHeight = Math.min(welcome.clientHeight, window.visualViewport?.height ?? innerHeight)
      - parseFloat(style.paddingTop) - parseFloat(style.paddingBottom);
    const availableWidth = welcome.clientWidth - parseFloat(style.paddingLeft) - parseFloat(style.paddingRight);
    const scale = Math.min(1, availableHeight / Math.max(1, content.offsetHeight), availableWidth / Math.max(1, content.offsetWidth));
    content.style.setProperty('--welcome-scale', String(Math.max(.1, Math.floor(scale * 10000) / 10000)));
  };
  const scheduleFit = () => {
    cancelAnimationFrame(fitFrame);
    fitFrame = requestAnimationFrame(fitWelcome);
  };
  addEventListener('resize', scheduleFit);
  window.visualViewport?.addEventListener('resize', scheduleFit);
  if (typeof ResizeObserver === 'function') new ResizeObserver(scheduleFit).observe(content);
  document.fonts?.ready.then(scheduleFit);
  scheduleFit();
  document.addEventListener('visibilitychange', () => { if (document.hidden && dialog.open) input.blur(); });
})();
