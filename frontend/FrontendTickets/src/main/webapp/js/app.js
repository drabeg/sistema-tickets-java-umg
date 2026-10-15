/**
 * Mueve visualmente una tarjeta de ticket a su nueva columna 
 * y notifica al Servlet en segundo plano (sin recargar la página).
 * 
 * @param {number} ticketId - El identificador único del ticket (ej: 101)
 * @param {string} nuevoEstado - El estado destino ('solicitado', 'proceso', 'finalizado')
 */
function cambiarEstadoTicket(ticketId, nuevoEstado) {
    // 1. Buscamos el elemento HTML de la tarjeta usando su ID único
    const tarjeta = document.getElementById(`ticket-${ticketId}`);
    
    // 2. Buscamos el contenedor (cuerpo) de la columna de destino
    const columnaDestino = document.getElementById(`col-${nuevoEstado}`);
    
    if (!tarjeta || !columnaDestino) {
        console.error("Error local: No se encontró la tarjeta o la columna destino.");
        return;
    }

    // 3. Modificamos los botones internos de la tarjeta dinámicamente según su nueva posición
    const contenedorBotones = tarjeta.querySelector('.d-flex.justify-content-end');
    if (contenedorBotones) {
        if (nuevoEstado === 'proceso') {
            contenedorBotones.innerHTML = `
                <button class="btn btn-sm btn-outline-success d-flex align-items-center py-1 px-2.5 rounded-2 fw-semibold" style="font-size:0.85rem;"
                        onclick="cambiarEstadoTicket(${ticketId}, 'finalizado')">
                    Finalizar <i class="bi bi-check2-circle ms-1"></i>
                </button>
            `;
        } else if (nuevoEstado === 'finalizado') {
            contenedorBotones.innerHTML = `
                <span class="text-success small fw-bold d-flex align-items-center" style="font-size:0.85rem;">
                    <i class="bi bi-check-lg me-1"></i> Resuelto
                </span>
            `;
        }
    }

    // 4. ¡Efecto visual inmediato! Movemos el elemento en el árbol visual (DOM) sin parpadear
    columnaDestino.appendChild(tarjeta);
    
    // 5. Recalculamos los números de los contadores (Badges) de cada columna de forma dinámica
    actualizarContadoresTablero();

    // 6. ENLACE CON TU BACKEND (Petición asíncrona)
    const urlServlet = "CrudServlet"; 
    
    const datosParaEnviar = new URLSearchParams();
    datosParaEnviar.append("accion", "actualizarEstado");
    datosParaEnviar.append("id", ticketId);
    datosParaEnviar.append("estado", nuevoEstado);

    fetch(urlServlet, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: datosParaEnviar
    })
    .then(response => {
        if (!response.ok) {
            throw new Error("El servidor no respondió de forma correcta.");
        }
        return response.text();
    })
    .then(data => {
        console.log("Base de datos actualizada con éxito en segundo plano:", data);
    })
    .catch(error => {
        console.error("Error de comunicación por red virtual:", error);
        alert("Atención: El cambio se aplicó en tu pantalla, pero no se pudo guardar en el servidor. Verifica tu conexión de Radmin VPN.");
    });
}

/**
 * Cuenta automáticamente cuántas tarjetas hay en cada contenedor 
 * y actualiza los globos numéricos del encabezado Kanban.
 */
function actualizarContadoresTablero() {
    const estados = ['solicitado', 'proceso', 'finalizado'];
    
    estados.forEach(estado => {
        const columna = document.getElementById(`col-${estado}`);
        const badge = document.getElementById(`badge-${estado}`);
        
        if (columna && badge) {
            // Cuenta cuántos elementos hijos con la clase '.tarjeta' viven dentro de esa columna
            const cantidadTickets = columna.querySelectorAll('.tarjeta').length;
            badge.textContent = cantidadTickets;
        }
    });
}

// Escuchador global: Cuando el formulario de nuevo ticket se envíe, interceptamos el flujo
document.getElementById('formTicketNuevo')?.addEventListener('submit', function(e) {
    e.preventDefault();
    alert("Lógica de inserción asíncrona interceptada con éxito. Listo para conectar al Servlet de creación.");
});

/**
 * Remueve visualmente todas las tarjetas que se encuentren 
 * dentro de la columna de Finalizados y resetea su contador.
 */
function limpiarColumnaFinalizados() {
    const columna = document.getElementById("col-finalizado");
    
    if (columna) {
        const tarjetasResueltas = columna.querySelectorAll('.tarjeta');
        
        if (tarjetasResueltas.length === 0) {
            console.log("No hay tickets finalizados para limpiar.");
            return;
        }
        
        tarjetasResueltas.forEach(tarjeta => {
            tarjeta.style.transition = "all 0.3s ease";
            tarjeta.style.opacity = "0";
            tarjeta.style.transform = "scale(0.8)";
            
            setTimeout(() => {
                tarjeta.remove();
                actualadoresContadoresTablero();
            }, 300);
        });
    }
}

/**
 * Cambia el tema visual entre Light y Dark Mode guardando 
 * la preferencia del usuario en el navegador de forma local.
 */
function alternarModoOscuro() {
    const cuerpo = document.documentElement;
    const icono = document.getElementById("themeIcon");
    
    if (cuerpo.getAttribute("data-theme") === "dark") {
        cuerpo.removeAttribute("data-theme");
        if (icono) icono.textContent = "[Contrast]";
        localStorage.setItem("temaSeleccionado", "light");
    } else {
        cuerpo.setAttribute("data-theme", "dark");
        if (icono) icono.textContent = "[Contrast]";
        localStorage.setItem("temaSeleccionado", "dark");
    }
}

// Escuchador global: Al cargar la página, verificamos y aplicamos el tema e icono correspondientes
document.addEventListener("DOMContentLoaded", () => {
    const temaGuardado = localStorage.getItem("temaSeleccionado");
    const icono = document.getElementById("themeIcon");
    
    if (temaGuardado === "dark") {
        document.documentElement.setAttribute("data-theme", "dark");
        if (icono) icono.textContent = "[Contrast]";
    } else {
        if (icono) icono.textContent = "[Contrast]";
    }
    if (typeof actualizarContadoresTablero === "function") {
        actualizarContadoresTablero();
    }
});


/**
 * Expande la interfaz web para ocupar el 100% del monitor físico.
 */
function togglePantallaCompleta() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.error(`Error al intentar activar pantalla completa: ${err.message}`);
        });
    } else {
        document.exitFullscreen();
    }
}

/**
 * Filtra en tiempo real las tarjetas basándose en el texto escrito en el buscador.
 */
function filtrarTicketsPorTexto() {
    const textoBuscado = document.getElementById("buscadorTickets").value.toLowerCase();
    const tarjetas = document.querySelectorAll(".tarjeta");
    
    tarjetas.forEach(tarjeta => {
        const titulo = tarjeta.querySelector(".titulo")?.textContent.toLowerCase() || "";
        const desc = tarjeta.querySelector(".meta")?.textContent.toLowerCase() || "";
        
        if (titulo.includes(textoBuscado) || desc.includes(textoBuscado)) {
            tarjeta.style.display = ""; 
        } else {
            tarjeta.style.display = "none"; 
        }
    });
}

/**
 * Filtra las tarjetas visibles en el tablero basándose en su nivel de prioridad.
 * @param {string} prioridad - 'alta', 'media', 'baja' o 'todas'
 */
function filtrarPrioridad(prioridad) {
    const tarjetas = document.querySelectorAll(".tarjeta");
    
    tarjetas.forEach(tarjeta => {
        if (prioridad === 'todas') {
            tarjeta.style.display = ""; 
            return;
        }
        
        if (tarjeta.classList.contains(`prio-${prioridad}`)) {
            tarjeta.style.display = "";
        } else {
            tarjeta.style.display = "none";
        }
    });
}

// Al cargar la página, verificamos si el usuario ya tenía activo el Modo Oscuro
document.addEventListener("DOMContentLoaded", () => {
    const temaGuardado = localStorage.getItem("temaSeleccionado");
    if (temaGuardado === "dark") {
        document.documentElement.setAttribute("data-theme", "dark");
        const icono = document.getElementById("themeIcon");
        if (icono) icono.className = "bi bi-sun-fill";
    }
    actualizarContadoresTablero();
});

// ========================================================
/* LOGICA DE ARRASTRE Y SOLTADO (DRAG AND DROP NATIVO) */
// ========================================================

/**
 * Guarda temporalmente el ID de la tarjeta que el usuario empezó a arrastrar.
 */
function iniciarArrastre(event) {
    event.dataTransfer.setData("text/plain", event.target.id);
    // Añadimos un efecto visual de opacidad mientras se arrastra
    event.target.style.opacity = "0.5";
}

/**
 * Cancela el comportamiento por defecto del navegador para permitir el soltado.
 */
function permitirSoltar(event) {
    event.preventDefault();
}

/**
 * Procesa la caída de la tarjeta dentro de la columna destino, actualiza 
 * los botones internos de forma adaptativa y notifica al backend en segundo plano.
 */
function soltarTicket(event, nuevoEstado) {
    event.preventDefault();
    
    // Recuperamos el ID de la tarjeta guardado en el paso de inicio
    const idTarjeta = event.dataTransfer.getData("text/plain");
    const tarjeta = document.getElementById(idTarjeta);
    const columnaDestino = document.getElementById(`col-${nuevoEstado}`);
    
    if (tarjeta && columnaDestino) {
        // Restauramos la opacidad normal de la tarjeta
        tarjeta.style.opacity = "1";
        
        // Extraemos el número de ID puro (quitando la palabra 'ticket-')
        const ticketIdPuro = idTarjeta.replace("ticket-", "");
        
        // 1. Modificamos los botones internos de la tarjeta dinámicamente según la columna destino
        const contenedorBotones = tarjeta.querySelector('.d-flex.justify-content-end');
        if (contenedorBotones) {
            if (nuevoEstado === 'solicitado') {
                contenedorBotones.innerHTML = `
                    <button class="btn btn-sm btn-outline-primary py-1 px-2.5 rounded-2 fw-semibold text-primary" style="font-size:0.85rem;" 
                            onclick="cambiarEstadoTicket(${ticketIdPuro}, 'proceso')">
                        Atender &rarr;
                    </button>
                `;
            } else if (nuevoEstado === 'proceso') {
                contenedorBotones.innerHTML = `
                    <button class="btn btn-sm btn-outline-success d-flex align-items-center py-1 px-2.5 rounded-2 fw-semibold" style="font-size:0.85rem;"
                            onclick="cambiarEstadoTicket(${ticketIdPuro}, 'finalizado')">
                        Finalizar &rarr;
                    </button>
                `;
            } else if (nuevoEstado === 'finalizado') {
                contenedorBotones.innerHTML = `
                    <span class="text-success small fw-bold d-flex align-items-center" style="font-size:0.85rem;">
                        Resuelto
                    </span>
                `;
            }
        }
        
        // 2. Desplazamos físicamente la tarjeta dentro del contenedor HTML sin recargar
        columnaDestino.appendChild(tarjeta);
        
        // 3. Recalculamos los globos numéricos del encabezado
        actualizarContadoresTablero();
        
        // 4. Disparamos la sincronización asíncrona hacia tu CrudServlet en segundo plano
        sincronizarEstadoConServidor(ticketIdPuro, nuevoEstado);
    }
}

/**
 * Función auxiliar para realizar el Fetch asíncrono sin mover la tarjeta visualmente de nuevo.
 */
function sincronizarEstadoConServidor(ticketId, nuevoEstado) {
    const datosParaEnviar = new URLSearchParams();
    datosParaEnviar.append("accion", "actualizarEstado");
    datosParaEnviar.append("id", ticketId);
    datosParaEnviar.append("estado", nuevoEstado);

    fetch("CrudServlet", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: datosParaEnviar
    })
    .then(response => response.text())
    .then(data => console.log("Sincronización remota exitosa:", data))
    .catch(error => console.error("Error en red virtual de sincronización:", error));
}

// Vinculamos un escuchador de seguridad por si el usuario cancela el arrastre a mitad de camino
document.addEventListener("dragend", (event) => {
    if (event.target && event.target.style) {
        event.target.style.opacity = "1";
    }
});

// Lógica para encender el Highlight correcto en el menú según la URL actual de tu navegador
document.addEventListener("DOMContentLoaded", () => {
    const rutaActual = window.location.pathname;
    
    // Removemos cualquier brillo viejo por seguridad
    document.querySelectorAll("#mainMenuNav .nav-link").forEach(enlace => {
        enlace.classList.remove("active");
    });
    
    // Evaluamos en qué Servlet se encuentra parado el usuario y encendemos el ID correspondiente
    if (rutaActual.includes("/inicio")) {
        document.getElementById("nav-inicio")?.classList.add("active");
    } else if (rutaActual.includes("/historial")) {
        document.getElementById("nav-historial")?.classList.add("active");
    } else if (rutaActual.includes("/notificaciones")) {
        document.getElementById("nav-notificaciones")?.classList.add("active");
    } else if (rutaActual.includes("/config")) {
        document.getElementById("nav-config")?.classList.add("active");
    }
    
    // Ejecutamos el conteo inicial de tus tarjetas Kanban
    if (typeof actualizarContadoresTablero === "function") {
        actualizarContadoresTablero();
    }
});

