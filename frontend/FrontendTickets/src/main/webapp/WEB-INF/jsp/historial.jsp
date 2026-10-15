<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>



<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h1 class="h3 mb-1 fw-bold">Centro de Reportes Gerenciales</h1>
        <p class="text-muted small mb-0">Auditoría de rendimiento y exportación de bitácoras del sistema distribuidor.</p>
    </div>
    <div class="d-flex gap-2">
        <a href="#" class="btn btn-jira-action border-danger text-danger fw-semibold" onclick="alert('Generando PDF corporativo con Jasper Reports...')">📄 Exportar PDF</a>
        <a href="#" class="btn btn-jira-action border-success text-success fw-semibold" onclick="alert('Generando Excel corporativo con Jasper Reports...')">📊 Exportar Excel</a>
    </div>
</div>

<div class="card border-0 shadow-sm mb-4 p-3" style="background-color: var(--bg-tarjeta);">
    <form method="GET" action="historial" class="row g-2 align-items-center">
        <div class="col-12 col-md-9">
            <select name="id" class="form-select border-2 py-2 rounded-2">
                <option value="">-- Seleccione un ticket de la lista para auditar transiciones --</option>
                <c:forEach var="t" items="${tickets}">
                    <option value="${t.id}" ${t.id == idSeleccionado ? 'selected' : ''}>${t.texto}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-12 col-md-3">
            <button type="submit" class="btn btn-primary bg-primary border-primary text-white w-100 py-2 fw-semibold">🔎 Consultar Bitácora</button>
        </div>
    </form>
</div>

<div class="card border-0 shadow-sm overflow-hidden mb-4" style="background-color: var(--bg-tarjeta);">
    <div class="card-body p-3">
        <c:choose>
            <c:when class="${empty idSeleccionado}">
                <div class="text-center py-5 text-muted">
                    <span class="fs-1 d-block mb-2">📋</span>
                    <h5 class="fw-bold">Bandeja de Auditoría Vacía</h5>
                    <p class="small text-muted mb-0">Seleccione un ticket válido en la sección superior para desplegar la línea de tiempo de sus estados.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table table-hover table-striped align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>Fecha / Hora</th>
                            <th>Operador Técnico</th>
                            <th>Estado Origen</th>
                            <th>Estado Destino</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>15/10/2026 00:05</td>
                            <td>Richard UMG</td>
                            <td><span class="badge bg-secondary">Solicitado</span></td>
                            <td><span class="badge bg-warning text-dark">En Proceso</span></td>
                        </tr>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>
