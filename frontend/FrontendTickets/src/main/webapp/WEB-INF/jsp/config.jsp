<%@ include file="/WEB-INF/jsp/_header.jspf" %>
<section class="encabezado-pagina">
    <h1>⚙️ Configuración</h1>
</section>
<p class="intro">Indique la dirección del <strong>servidor de servicios</strong> (GlassFish con BackendTickets). Cambia al instante, sin reiniciar la aplicación.</p>
<form class="formulario" method="post" action="<c:url value='/config'/>">
    <div class="campo">
        <label for="baseUrl">URL base de los servicios SOAP</label>
        <input id="baseUrl" name="baseUrl" type="url" required value="<c:out value='${baseUrl}'/>" placeholder="http://192.168.1.20:8080/BackendTickets">
        <small>Formato: <code>http://IP-del-servidor-de-servicios:8080/BackendTickets</code></small>
    </div>
    <div class="botones">
        <button class="btn primario" type="submit">Guardar</button>
        <a class="btn secundario" href="<c:url value='/config'><c:param name='probar' value='1'/></c:url>">Probar conexión con los servicios</a>
    </div>
</form>

<c:if test="${not empty pruebas}">
    <h2>Resultado de la prueba</h2>
    <div class="tabla-responsive">
        <table class="tabla">
            <thead><tr><th>Servicio</th><th>Estado</th><th>Detalle</th><th>Tiempo</th></tr></thead>
            <tbody>
                <c:forEach var="p" items="${pruebas}">
                    <tr>
                        <td data-label="Servicio"><c:out value="${p.servicio}"/></td>
                        <td data-label="Estado"><span class="badge ${p.ok ? 'ok' : 'error'}">${p.ok ? 'OK' : 'ERROR'}</span></td>
                        <td data-label="Detalle"><c:out value="${p.detalle}"/></td>
                        <td data-label="Tiempo"><c:out value="${p.milisegundos}"/> ms</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>
<%@ include file="/WEB-INF/jsp/_footer.jspf" %>
