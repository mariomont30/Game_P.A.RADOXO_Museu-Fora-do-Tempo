(() => {
  const status = document.getElementById('status');
  const notice = document.getElementById('status-notice');
  const recovery = document.getElementById('status-recovery');
  const retry = document.getElementById('retryLoad');
  let failed = false;
  window.paradoxoLoadFailure = (error) => {
    if (window.paradoxo?.ready || failed) return;
    failed = true;
    console.error(error);
    const detail = String(error?.message ?? error ?? '');
    const unsupported = /features required|missing|WebGL|WebAssembly|DecompressionStream/i.test(detail);
    const message = unsupported
      ? 'Este navegador não oferece os recursos necessários para abrir o museu. Use um navegador atualizado e tente novamente.'
      : 'Não foi possível carregar o museu. Verifique sua conexão e tente novamente.';
    if (window.paradoxo) window.paradoxo.loadingFailed = true;
    document.body.classList.add('load-failed');
    document.getElementById('welcome').style.display = 'none';
    document.getElementById('enterMuseum').disabled = true;
    status.classList.add('is-failed');
    status.style.visibility = 'visible';
    document.getElementById('status-progress').style.display = 'none';
    const subtitle = document.getElementById('status-subtitle');
    if (subtitle) subtitle.hidden = true;
    notice.textContent = message;
    notice.style.display = 'block';
    recovery.hidden = false;
    retry.disabled = false;
    retry.focus({ preventScroll: true });
  };
  // Some engine initialization failures do not reject startGame promptly.
  // Observe startup resource fetches directly, including compressed WASM.
  const startupFetch = window.fetch.bind(window);
  window.fetch = async (input, options) => {
    const url = new URL(typeof input === 'string' ? input : input.url, location.href);
    const startupResource = url.origin === location.origin && /\/index\.(pck|wasm)(\.gz)?$/.test(url.pathname);
    try {
      const response = await startupFetch(input, options);
      if (startupResource && !response.ok) throw new Error('Startup download failed: ' + response.status);
      return response;
    } catch (error) {
      if (startupResource) window.paradoxoLoadFailure(error);
      throw error;
    }
  };
  retry.addEventListener('click', () => {
    if (!failed || retry.disabled) return;
    retry.disabled = true;
    retry.textContent = 'Reabrindo o museu…';
    // Reload creates a fresh engine. IndexedDB and saved journeys are untouched.
    window.location.reload();
  });
  window.addEventListener('error', (event) => {
    if (!(event.target instanceof HTMLScriptElement) || !event.target.src) return;
    const path = new URL(event.target.src, location.href).pathname;
    if (path.endsWith('/index.js') || path.endsWith('/mobile.js')) {
      window.paradoxoLoadFailure(new Error('Startup script unavailable'));
    }
  }, true);
})();
