(() => {
  let pending = null;
  let started = false;
  const dialog = document.getElementById('nameDialog');
  const input = document.getElementById('mobileName');
  const coarse = matchMedia('(pointer:coarse)').matches || navigator.maxTouchPoints > 0;
  window.paradoxo = {
    ready: false,
    loadingFailed: false,
    start: null,
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
  document.addEventListener('visibilitychange', () => { if (document.hidden && dialog.open) input.blur(); });
})();
