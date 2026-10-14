<%@ include file="/WEB-INF/jsp/_header.jspf" %>
<section class="encabezado-pagina">
    <h1>Control de Tickets</h1>
    <span id="estado-conexion" class="badge" data-url="<c:url value='/config?accion=ping'/>">Comprobando servicios…</span>
</section>
<p class="intro">Seleccione un módulo. Todas las operaciones se realizan a través de los servicios SOAP; esta aplicación no accede directamente a la base de datos.</p>
<div class="rejilla">
    <a class="tarjeta-modulo destacada" href="<c:url value='/tablero'/>">
        <span class="icono">📋</span>
        <strong>Tablero FIFO</strong>
        <small>Cola de tickets por estado: reclamar y avanzar</small>
    </a>
    <c:forEach var="m" items="${entidades}">
        <a class="tarjeta-modulo" href="<c:url value='/crud/${m.clave}'/>">
            <span class="icono"><c:out value="${m.icono}"/></span>
            <strong><c:out value="${m.titulo}"/></strong>
            <small><c:out value="${m.descripcion}"/></small>
        </a>
    </c:forEach>
    <a class="tarjeta-modulo" href="<c:url value='/historial'/>">
        <span class="icono">🕘</span>
        <strong>Historial</strong>
        <small>Trazabilidad de cambios de estado</small>
    </a>
    <a class="tarjeta-modulo" href="<c:url value='/notificaciones'/>">
        <span class="icono">🔔</span>
        <strong>Notificaciones</strong>
        <small>Alertas pendientes del especialista</small>
    </a>
    <a class="tarjeta-modulo" href="<c:url value='/config'/>">
        <span class="icono">⚙️</span>
        <strong>Configuración</strong>
        <small>URL del servidor de servicios y prueba de conexión</small>
    </a>
</div>
<%@ include file="/WEB-INF/jsp/_footer.jspf" %>
