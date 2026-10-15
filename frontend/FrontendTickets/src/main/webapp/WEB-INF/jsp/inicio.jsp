<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ include file="_header.jspf" %>

<!-- FILA SUPERIOR: TÍTULO Y CONTROLES LIMPIOS -->
<div class="d-flex justify-content-between align-items-center mb-1 flex-wrap gap-2">
    <div>
        <h1 class="h3 mb-1 fw-bold">Tablero de Gestión</h1>
        <p class="text-muted small mb-0">Flujo automatizado para atención técnica estructurada.</p>
    </div>
    
    <!-- Controles de visualización técnicos sin emojis -->
    <div class="d-flex align-items-center gap-1">
        <button class="btn btn-jira-action d-inline-flex align-items-center px-2 py-1" id="btnToggleTheme" onclick="alternarModoOscuro()" title="Cambiar tema" aria-label="Cambiar tema">
            <svg class="icono i-tema-luna"><use href="#i-moon"/></svg>
            <svg class="icono i-tema-sol"><use href="#i-sun"/></svg>
        </button>
        <button class="btn btn-jira-action d-inline-flex align-items-center px-2 py-1" onclick="togglePantallaCompleta()" title="Pantalla completa" aria-label="Pantalla completa">
            <svg class="icono i-fs-entrar"><use href="#i-maximize"/></svg>
            <svg class="icono i-fs-salir"><use href="#i-minimize"/></svg>
        </button>
    </div>
</div>

<!-- FILA INTERMEDIA: ALINEACIÓN PERFECTA DEL BUSCADOR, FILTROS Y BOTÓN -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3 pb-3 border-bottom border-secondary-subtle">
    <div class="d-flex align-items-center gap-2 flex-wrap" style="flex: 1;">
        <div class="position-relative" style="max-width: 250px; width: 100%;">
            <svg class="icono icono-input"><use href="#i-search"/></svg>
            <input type="text" id="buscadorTickets" class="form-control py-1.5 fs-7 rounded-2 ps-5" 
                   placeholder="Buscar ticket..." aria-label="Buscar ticket" onkeyup="filtrarTicketsPorTexto()">
        </div>
        <button class="btn btn-sm btn-jira-action py-1.5" onclick="filtrarPrioridad('alta')">Prioridad Alta</button>
        <button class="btn btn-sm btn-jira-action py-1.5" onclick="filtrarPrioridad('todas')">Mostrar Todo</button>
    </div>
    
    <div>
        <button class="btn btn-primary bg-primary border-primary px-4 py-1.5 fw-semibold text-white d-inline-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#modalNuevoTicket">
            <svg class="icono"><use href="#i-plus"/></svg>Crear Ticket
        </button>
    </div>
</div>

<!-- TABLERO KANBAN ACTIVADO PARA ARRASTRE -->
<div class="tablero">
    <div class="columna" ondragover="permitirSoltar(event)" ondrop="soltarTicket(event, 'solicitado')">
        <h2>
            <span>Solicitado</span>
            <span class="contador" id="badge-solicitado">1</span>
        </h2>
        <div id="col-solicitado" style="min-height: 500px;">
            <div class="tarjeta prio-alta" id="ticket-101" draggable="true" ondragstart="iniciarArrastre(event)">
                <header class="d-flex justify-content-between align-items-center">
                    <span class="badge bg-danger-subtle text-danger small px-2">BG-101</span>
                    <small class="text-muted fw-bold">Alta</small>
                </header>
                <div class="titulo my-2 fw-bold">Error en servidor de impresión</div>
                <div class="meta mb-3">No se emiten reportes de inventario.</div>
                <div class="d-flex justify-content-end gap-2 border-top pt-2">
                    <button class="btn btn-sm btn-outline-primary py-1 px-2.5 rounded-2 fw-semibold text-primary" style="font-size:0.85rem;" onclick="cambiarEstadoTicket(101, 'proceso')">
                        Atender <svg class="icono ms-1"><use href="#i-arrow-right"/></svg>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="columna" ondragover="permitirSoltar(event)" ondrop="soltarTicket(event, 'proceso')">
        <h2>
            <span>En Proceso</span>
            <span class="contador" id="badge-proceso">0</span>
        </h2>
        <div id="col-proceso" style="min-height: 500px;"></div>
    </div>

    <div class="columna" ondragover="permitirSoltar(event)" ondrop="soltarTicket(event, 'finalizado')">
        <h2>
            <span>Finalizado</span>
            <div class="d-flex align-items-center gap-2">
                <span class="contador" id="badge-finalizado">0</span>
                <button class="btn p-0 border-0 bg-transparent d-inline-flex align-items-center" onclick="limpiarColumnaFinalizados()" title="Limpiar columna" aria-label="Limpiar columna" style="color: var(--texto-secundario) !important;">
                    <svg class="icono"><use href="#i-trash"/></svg>
                </button>
            </div>
        </h2>
        <div id="col-finalizado" style="min-height: 500px;"></div>
    </div>
</div>

<!-- MODAL FLOTANTE -->
<div class="modal fade" id="modalNuevoTicket" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title fw-bold">Registrar Incidencia</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="formTicketNuevo">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-muted">Título de la incidencia</label>
                        <input type="text" id="titulo" required placeholder="Ej: Error de conexión SQL">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-muted">Nivel de Prioridad</label>
                        <select id="prioridad">
                            <option value="baja">Baja Prioridad</option>
                            <option value="media" selected>Media Prioridad</option>
                            <option value="alta">Alta Prioridad</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-muted">Descripción Detallada</label>
                        <textarea id="descripcion" rows="3" required placeholder="Detalle los síntomas del error..."></textarea>
                    </div>
                </div>
                <div class="modal-footer bg-light p-3">
                    <button type="button" class="btn text-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary bg-primary border-primary text-white px-4 fw-semibold">Guardar Ticket</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@ include file="_footer.jspf" %>
