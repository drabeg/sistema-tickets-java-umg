// Confirmación en formularios con data-confirm
document.addEventListener('submit', function (e) {
    var msg = e.target.getAttribute && e.target.getAttribute('data-confirm');
    if (msg && !window.confirm(msg)) { e.preventDefault(); }
});

// Indicador de conexión con los servicios (pantalla de inicio)
(function () {
    var badge = document.getElementById('estado-conexion');
    if (!badge) { return; }
    function fallo(detalle) {
        badge.textContent = 'Sin conexión con los servicios';
        badge.className = 'badge error';
        badge.title = detalle || '';
    }
    fetch(badge.getAttribute('data-url'), { cache: 'no-store' })
        .then(function (r) { return r.text(); })
        .then(function (t) {
            if (t.indexOf('OK') === 0) {
                badge.textContent = 'Servicios en línea';
                badge.className = 'badge ok';
            } else { fallo(t); }
        })
        .catch(function () { fallo('No se pudo consultar el estado'); });
})();
