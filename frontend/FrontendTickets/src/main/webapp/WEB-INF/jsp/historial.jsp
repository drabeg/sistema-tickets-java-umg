<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="_header.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
        <h1 class="h3 mb-1 fw-bold">Centro de Reportes Gerenciales</h1>
        <p class="text-muted small mb-0">Auditoría de rendimiento y exportación de bitácoras del sistema distribuidor.</p>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/historial?accion=exportar&tipo=pdf&id=${idSeleccionado}" 
           target="_blank" 
           class="btn btn-jira-action border-danger text-danger fw-semibold d-inline-flex align-items-center gap-2 ${empty idSeleccionado ? 'disabled' : ''}">
            <svg class="icono"><use href="#i-file-text"/></svg>Exportar PDF
        </a>
        <a href="${pageContext.request.contextPath}/historial?accion=exportar&tipo=excel&id=${idSeleccionado}" 
           target="_blank" 
           class="btn btn-jira-action border-success text-success fw-semibold d-inline-flex align-items-center gap-2 ${empty idSeleccionado ? 'disabled' : ''}">
            <svg class="icono"><use href="#i-table"/></svg>Exportar Excel
        </a>
    </div>
</div>

<div class="card border-0 shadow-sm mb-4 p-3" style="background-color: var(--bg-tarjeta);">
    <form method="GET" action="${pageContext.request.contextPath}/historial" class="row g-2 align-items-center">
        <div class="col-12 col-md-9">
            <select name="id" class="form-select border-2 py-2 rounded-2" required>
                <option value="">-- Seleccione un ticket de la lista para auditar transiciones --</option>
                <c:forEach var="t" items="${tickets}">
                    <option value="<c:out value='${t.id}'/>" ${t.id eq idSeleccionado ? 'selected' : ''}>
                        <c:out value="${t.texto}"/>
                    </option>
                </c:forEach>
            </select>
        </div>
        <div class="col-12 col-md-3">
            <button type="submit" class="btn btn-primary bg-primary border-primary text-white w-100 py-2 fw-semibold d-inline-flex align-items-center justify-content-center gap-2">
                <svg class="icono"><use href="#i-search"/></svg>Consultar Bitácora
            </button>
        </div>
    </form>
</div>

<div class="card border-0 shadow-sm overflow-hidden mb-4" style="background-color: var(--bg-tarjeta);">
    <div class="card-body p-3">
        <c:choose>
            <c:when test="${empty idSeleccionado}">
                <div class="text-center py-5 text-muted">
                    <svg class="icono icono-xl d-block mx-auto mb-2"><use href="#i-clipboard"/></svg>
                    <h5 class="fw-bold">Bandeja de Auditoría Vacía</h5>
                    <p class="small text-muted mb-0">Seleccione un ticket válido en la sección superior para desplegar la línea de tiempo de sus estados.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table table-hover table-striped align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <c:choose>
                                <c:when test="${not empty tabla and not empty tabla.columnas}">
                                    <c:forEach var="col" items="${tabla.columnas}">
                                        <th><c:out value="${col.titulo}"/></th>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <th>Fecha / Hora</th>
                                    <th>Operador Técnico</th>
                                    <th>Estado Origen</th>
                                    <th>Estado Destino</th>
                                </c:otherwise>
                            </c:choose>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty tabla and not empty tabla.filas}">
                                <c:forEach var="fila" items="${tabla.filas}">
                                    <tr>
                                        <c:forEach var="col" items="${tabla.columnas}">
                                            <td>
                                                <c:choose>
                                                    <c:when test="${col.clave eq 'Estado Origen' or col.clave eq 'Estado Destino'}">
                                                        <span class="badge ${col.clave eq 'Estado Destino' ? 'bg-warning text-dark' : 'bg-secondary'}">
                                                            <c:out value="${fila.celdas[col.clave].valor}"/>
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:out value="${fila.celdas[col.clave].valor}"/>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </c:forEach>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-4">
                                        <c:out value="${tabla.aviso}" default="No hay registros de transiciones para el ticket seleccionado."/>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="_footer.jspf" %>