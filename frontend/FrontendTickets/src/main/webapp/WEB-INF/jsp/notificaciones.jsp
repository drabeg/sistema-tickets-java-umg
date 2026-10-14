<%@ include file="/WEB-INF/jsp/_header.jspf" %>
<section class="encabezado-pagina">
    <h1>🔔 Notificaciones</h1>
</section>
<form class="buscador" method="get" action="<c:url value='/notificaciones'/>">
    <label for="idEspecialista">Especialista</label>
    <select id="idEspecialista" name="idEspecialista" required>
        <option value="">-- Seleccione --</option>
        <c:forEach var="e" items="${especialistas}">
            <option value="<c:out value='${e.id}'/>" ${idSeleccionado eq e.id ? 'selected' : ''}><c:out value="${e.texto}"/></option>
        </c:forEach>
    </select>
    <button class="btn" type="submit">Ver pendientes</button>
</form>

<c:if test="${not empty tabla.aviso}"><div class="alerta info"><c:out value="${tabla.aviso}"/></div></c:if>
<c:if test="${not empty tabla.filas}">
    <div class="tabla-responsive">
        <table class="tabla">
            <thead><tr><c:forEach var="col" items="${tabla.columnas}"><th><c:out value="${col}"/></th></c:forEach><th>Acciones</th></tr></thead>
            <tbody>
                <c:forEach var="fila" items="${tabla.filas}">
                    <tr>
                        <c:forEach var="celda" items="${fila.celdas}" varStatus="st">
                            <td data-label="<c:out value='${tabla.columnas[st.index]}'/>"><c:out value="${celda}"/></td>
                        </c:forEach>
                        <td data-label="Acciones" class="acciones">
                            <form method="post" action="<c:url value='/notificaciones'/>">
                                <input type="hidden" name="idNotificacion" value="<c:out value='${fila.id}'/>">
                                <input type="hidden" name="idEspecialista" value="<c:out value='${idSeleccionado}'/>">
                                <button class="btn pequeno" type="submit">Marcar leída</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>
<%@ include file="/WEB-INF/jsp/_footer.jspf" %>
