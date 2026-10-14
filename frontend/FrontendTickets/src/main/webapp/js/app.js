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
    const contenedorBotones = tarjeta.querySelector('.d-flex');
    if (nuevoEstado === 'proceso') {
        // Si pasa a "En Proceso", el botón ahora debe decir "Finalizar" y apuntar al siguiente estado
        contenedorBotones.innerHTML = `
            <button class="btn btn-sm btn-outline-success d-flex align-items-center py-1.5 px-3 rounded-2 fw-semibold" 
                    onclick="cambiarEstadoTicket(${ticketId}, 'finalizado')">
                Finalizar <i class="bi bi-check2-circle ms-2"></i>
            </button>
        `;
    } else if (nuevoEstado === 'finalizado') {
        // Si el ticket se finaliza, removemos los botones de acción ya que completó el flujo
        contenedorBotones.innerHTML = `
            <span class="text-success small fw-bold d-flex align-items-center">
                <i class="bi bi-check-lg me-1"></i> Resuelto
            </span>
        `;
    }

    // 4. ¡Efecto visual inmediato! Movemos el elemento en el árbol visual (DOM) sin parpadear
    columnaDestino.appendChild(tarjeta);
    
    // 5. Recalculamos los números de los contadores (Badges) de cada columna de forma dinámica
    actualizarContadoresTablero();

    // 6. ENLACE CON TU BACKEND (Petición asíncrona por debajo de la mesa)
    // Apuntamos al CrudServlet que tus compañeros prepararon para registrar el cambio en base de datos
    const urlServlet = "CrudServlet"; 
    
    // Preparamos los parámetros tradicionales que un Servlet de Java espera recibir
    const datosParaEnviar = new URLSearchParams();
    datosParaEnviar.append("accion", "actualizarEstado");
    datosParaEnviar.append("id", ticketId);
    datosParaEnviar.append("estado", nuevoEstado);

    // Disparamos la magia de 'fetch' (AJAX moderno)
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
            // Cuenta cuántos elementos hijos con la clase '.card' viven dentro de esa columna
            const cantidadTickets = columna.querySelectorAll('.card').length;
            badge.textContent = cantidadTickets;
        }
    });
}

// Escuchador global: Cuando el formulario de nuevo ticket se envíe, interceptamos el flujo
document.getElementById('formTicketNuevo')?.addEventListener('submit', function(e) {
    // Evitamos el comportamiento por defecto de HTML que recarga la pantalla completa
    e.preventDefault();
    
    alert("Lógica de inserción asíncrona interceptada con éxito. Listo para conectar al Servlet de creación.");
    
    // Aquí implementaremos en el siguiente paso la recolección automática de tus campos
});

/**
 * Remueve visualmente todas las tarjetas que se encuentren 
 * dentro de la columna de Finalizados y resetea su contador.
 */
function limpiarColumnaFinalizados() {
    const columna = document.getElementById("col-finalizado");
    
    if (columna) {
        // Buscamos todas las tarjetas de tickets individuales dentro de la columna verde
        const tarjetasResueltas = columna.querySelectorAll('.card');
        
        if (tarjetasResueltas.length === 0) {
            console.log("No hay tickets finalizados para limpiar.");
            return;
        }
        
        // Animamos u ocultamos cada tarjeta de forma segura
        tarjetasResueltas.forEach(tarjeta => {
            tarjeta.style.transition = "all 0.3s ease";
            tarjeta.style.opacity = "0";
            tarjeta.style.transform = "scale(0.8)";
            
            // Esperamos a que termine la animación visual para sacarla definitivamente del documento
            setTimeout(() => {
                tarjeta.remove();
                actualizarContadoresTablero(); // Volvemos a contar para que el Badge quede en 0
            }, 300);
        });
        
        console.log("Columna de finalizados limpiada en pantalla con éxito.");
    }
}
