'use strict';
document.addEventListener('submit', function (event) {
  const form = event.target;
  if (form.matches('[data-confirm]') && !window.confirm(form.dataset.confirm)) event.preventDefault();
});

async function copyReportForSheets() {
  const table = document.querySelector('.panel:not(.no-print) table');
  if (!table) { window.open('https://sheets.new', '_blank', 'noopener'); return; }
  const rows = Array.from(table.querySelectorAll('tr')).map(tr =>
    Array.from(tr.querySelectorAll('th,td')).map(cell => cell.innerText.replace(/[\t\n]+/g, ' ').trim()).join('\t')
  ).join('\n');
  try {
    await navigator.clipboard.writeText(rows);
    window.open('https://sheets.new', '_blank', 'noopener');
    window.alert('Data laporan disalin. Di Google Sheets, pilih sel A1 lalu tekan Ctrl+V.');
  } catch (error) {
    window.open('https://sheets.new', '_blank', 'noopener');
    window.alert('Clipboard tidak diizinkan browser. Gunakan tombol Excel/CSV lalu impor file ke Google Sheets.');
  }
}

// Live menu filtering keeps navigation useful as the module list grows.
(function initMenuSearch() {
  const input = document.getElementById('menu-search');
  if (!input) return;
  const groups = Array.from(document.querySelectorAll('.nav-group'));
  const links = Array.from(document.querySelectorAll('.nav-item'));
  input.addEventListener('input', function () {
    const query = input.value.trim().toLocaleLowerCase('id');
    groups.forEach(group => {
      let visible = 0;
      group.querySelectorAll('.nav-item').forEach(link => {
        const match = !query || (link.dataset.menuLabel || link.textContent).toLocaleLowerCase('id').includes(query);
        link.hidden = !match;
        if (match) visible += 1;
      });
      group.hidden = visible === 0;
    });
  });
  input.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
      input.value = '';
      input.dispatchEvent(new Event('input'));
      input.blur();
    }
    if (event.key === 'Enter') {
      const first = links.find(link => !link.hidden && link.offsetParent !== null);
      if (first) window.location.href = first.href;
    }
  });
})();


// Resolve keyboard-wedge barcode/QR scans to the canonical active product master.
(function initOperationalProductScanner() {
  document.querySelectorAll('.product-code-scan[data-product-target]').forEach(function (input) {
    const select = document.getElementById(input.dataset.productTarget);
    if (!select) return;
    let debounce;
    function resolveCode() {
      const code = input.value.trim();
      if (!code) { input.setCustomValidity(''); input.classList.remove('scan-found', 'scan-not-found'); return false; }
      const normalized = code.toLocaleLowerCase('id');
      const option = Array.from(select.options).find(function (item) {
        return (item.dataset.sku || '').trim().toLocaleLowerCase('id') === normalized ||
          (item.dataset.barcode || '').trim().toLocaleLowerCase('id') === normalized;
      });
      if (option) {
        select.value = option.value;
        input.setCustomValidity('');
        input.classList.add('scan-found');
        input.classList.remove('scan-not-found');
        input.setAttribute('aria-invalid', 'false');
        select.dispatchEvent(new Event('change', { bubbles: true }));
        return true;
      }
      input.setCustomValidity('SKU/barcode tidak ditemukan pada master produk aktif. Periksa kode atau master produk.');
      input.classList.add('scan-not-found');
      input.classList.remove('scan-found');
      input.setAttribute('aria-invalid', 'true');
      return false;
    }
    input.addEventListener('input', function () {
      clearTimeout(debounce);
      debounce = setTimeout(resolveCode, 140);
    });
    input.addEventListener('change', resolveCode);
    input.addEventListener('keydown', function (event) {
      // Most USB barcode scanners send Enter after the code.
      if (event.key === 'Enter') {
        event.preventDefault();
        if (resolveCode()) {
          const form = input.closest('form');
          const qty = form && form.querySelector('input[name="qty"]');
          if (qty) qty.focus();
        } else input.reportValidity();
      }
    });
    const form = input.closest('form');
    if (form) form.addEventListener('submit', function (event) {
      if (input.value.trim() && !resolveCode()) { event.preventDefault(); input.reportValidity(); input.focus(); }
    });
  });
})();
