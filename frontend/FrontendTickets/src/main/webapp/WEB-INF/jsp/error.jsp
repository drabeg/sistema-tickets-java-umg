<%@ page isErrorPage="true" %>
<%@ include file="/WEB-INF/jsp/_header.jspf" %>
<section class="encabezado-pagina"><h1>Ocurrió un problema</h1></section>
<div class="alerta error">
    La página solicitada no está disponible o se produjo un error interno.
    Código: <c:out value="${pageContext.errorData.statusCode}"/>
</div>
<p><a class="btn primario" href="<c:url value='/inicio'/>">Volver al inicio</a></p>
<%@ include file="/WEB-INF/jsp/_footer.jspf" %>
