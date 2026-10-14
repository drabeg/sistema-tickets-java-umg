<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ include file="_header.jspf" %>

<!-- Encabezado de la página con botones adaptables -->
<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
    <div>
        <h1 class="h3 mb-1 text-dark fw-bold">Tablero de Gestión</h1>
        <p class="text-muted small mb-0">Control de flujo de atención técnica mediante cola estructurada.</p>
    </div>
    <!-- Botón disparador del Modal Flotante de Bootstrap -->
    <button class="btn btn-primary shadow-sm px-4 py-2 fw-semibold d-flex align-items-center" data-bs-toggle="modal" data-bs-target="#modalNuevoTicket">
        <i class="bi bi-plus-lg me-2"></i> Crear Nuevo Ticket
    </button>
</div>

<!-- CONTENEDOR KANBAN DE TRES COLUMNAS RESPONSIVO -->
<div class="row g-4">
    
    <!-- Columna: Solicitado -->
    <div class="col-12 col-md-6 col-lg-4">
        <div class="card border-0 shadow-sm rounded-3 overflow-hidden bg-white">
            <div class="card-header bg-secondary text-white fw-bold d-flex justify-content-between align-items-center py-3 border-0">
                <span class="d-flex align-items-center"><i class="bi bi-inbox me-2"></i> Solicitado</span>
                <span class="badge bg-light text-dark shadow-sm px-2.5 py-1.5" id="badge-solicitado">1</span>
            </div>
            <div class="card-body p-2 bg-light-subtle transition-all" id="col-solicitado" style="min-height: 550px;">
                <!-- Tarjeta de ejemplo autogenerada -->
                <div class="card mb-3 shadow-sm border-start border-danger border-4 rounded-3" id="ticket-101">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1">Alta Prioridad</span>
                            <span class="text-muted small fw-semibold">#101</span>
                        </div>
                        <h6 class="card-title fw-bold text-dark mb-1">Error en servidor de impresión</h6>
                        <p class="card-text text-muted small mb-3">No se pueden emitir reportes de inventario desde el nodo de operaciones.</p>
                        <div class="d-flex justify-content-end gap-2 border-top pt-2 mt-2">
                            <button class="btn btn-sm btn-outline-primary d-flex align-items-center py-1.5 px-3 rounded-2 fw-semibold" onclick="cambiarEstadoTicket(101, 'proceso')">
                                Atender <i class="bi bi-arrow-right ms-2"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Columna: En Proceso -->
    <div class="col-12 col-md-6 col-lg-4">
        <div class="card border-0 shadow-sm rounded-3 overflow-hidden bg-white">
            <div class="card-header bg-warning text-dark fw-bold d-flex justify-content-between align-items-center py-3 border-0">
                <span class="d-flex align-items-center"><i class="bi bi-gear-fill me-2"></i> En Proceso</span>
                <span class="badge bg-dark text-white shadow-sm px-2.5 py-1.5" id="badge-proceso">0</span>
            </div>
            <div class="card-body p-2 bg-light-subtle" id="col-proceso" style="min-height: 550px;">
                <!-- Los tickets en atención se inyectarán dinámicamente aquí -->
            </div>
        </div>
    </div>

     <!-- Columna: Finalizado (Actualizada con botón de limpieza) -->
    <div class="col-12 col-md-6 col-lg-4">
        <div class="card border-0 shadow-sm rounded-3 overflow-hidden bg-white">
            <div class="card-header bg-success text-white fw-bold d-flex justify-content-between align-items-center py-3 border-0">
                <span class="d-flex align-items-center"><i class="bi bi-check-circle-fill me-2"></i> Finalizado</span>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-light text-dark shadow-sm px-2.5 py-1.5" id="badge-finalizado">0</span>
                    <!-- Botón para archivar/limpiar las tarjetas resueltas de la vista actual -->
                    <button class="btn btn-sm btn-success border border-white-50 p-1 lh-1 rounded-2" 
                            title="Limpiar tablero" onclick="limpiarColumnaFinalizados()">
                        <i class="bi bi-trash3-fill fs-6"></i>
                    </button>
                </div>
            </div>
            <div class="card-body p-2 bg-light-subtle" id="col-finalizado" style="min-height: 550px;">
                <!-- Los tickets resueltos se depositarán aquí -->
            </div>
        </div>
    </div>
</div>

<!-- MODAL FLOTANTE: FORMULARIO ASÍNCRONO DE REGISTRO -->
<div class="modal fade" id="modalNuevoTicket" tabindex="-1" aria-labelledby="modalNuevoTicketLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-3">
            <div class="modal-header bg-primary text-white py-3">
                <h5 class="modal-title fw-bold" id="modalNuevoTicketLabel"><i class="bi bi-ticket-detailed me-2"></i>Registrar Nueva Incidencia</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="formTicketNuevo">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label for="titulo" class="form-label fw-semibold small text-secondary">Título de la incidencia</label>
                        <input type="text" id="titulo" class="form-control border-2 py-2 fs-6 rounded-2" required placeholder="Ej: Pérdida de paquetes en el switch de red">
                    </div>
                    <div class="mb-3">
                        <label for="prioridad" class="form-label fw-semibold small text-secondary">Nivel de prioridad</label>
                        <select id="prioridad" class="form-select border-2 py-2 fs-6 rounded-2">
                            <option value="baja">Baja Prioridad</option>
                            <option value="media" selected>Media Prioridad</option>
                            <option value="alta">Alta Prioridad</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="descripcion" class="form-label fw-semibold small text-secondary">Descripción detallada</label>
                        <textarea id="descripcion" class="form-control border-2 rounded-2" rows="3" required placeholder="Describa el comportamiento o código de error visualizado..."></textarea>
                    </div>
                </div>
                <div class="modal-footer bg-light p-3 border-top-0 rounded-bottom-3">
                    <button type="button" class="btn btn-outline-secondary px-3 py-2" data-bs-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-primary px-4 py-2 shadow-sm fw-semibold">Guardar Incidencia</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@ include file="_footer.jspf" %>
