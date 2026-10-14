<%@ include file="/WEB-INF/jsp/_header.jspf" %>
<section class="encabezado-pagina">
    <h1>🕘 Historial de tickets</h1>
</section>
<form class="buscador" method="get" action="<c:url value='/historial'/>">
    <c:choose>
        <c:when test="${not empty tickets}">
            <label for="id">Ticket</label>
            <select id="id" name="id" required>
                <option value="">-- Seleccione --</option>
                <c:forEach var="t" items="${tickets}">
                    <option value="<c:out value='${t.id}'/>" ${idSeleccionado eq t.id ? 'selected' : ''}><c:out value="${t.texto}"/></option>
                </c:forEach>
            </select>
        </c:when>
        <c:otherwise>
            <label for="id">ID del ticket</label>
            <input id="id" name="id" type="number" min="1" inputmode="numeric" required value="<c:out value='${idSeleccionado}'/>">
        </c:otherwise>
    </c:choose>
    <button class="btn" type="submit">Consultar</button>
</form>

<c:if test="${not empty tabla.aviso}"><div class="alerta info"><c:out value="${tabla.aviso}"/></div></c:if>
<c:if test="${not empty tabla.filas}">
    <div class="tabla-responsive">
        <table class="tabla">
            <thead><tr><c:forEach var="col" items="${tabla.columnas}"><th><c:out value="${col}"/></th></c:forEach></tr></thead>
            <tbody>
                <c:forEach var="fila" items="${tabla.filas}">
                    <tr>
                        <c:forEach var="celda" items="${fila.celdas}" varStatus="st">
                            <td data-label="<c:out value='${tabla.columnas[st.index]}'/>"><c:out value="${celda}"/></td>
                        </c:forEach>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>
<%@ include file="/WEB-INF/jsp/_footer.jspf" %>
