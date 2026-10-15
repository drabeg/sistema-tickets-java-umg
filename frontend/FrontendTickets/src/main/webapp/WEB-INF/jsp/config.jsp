<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="mb-4">
    <h1 class="h3 mb-1 fw-bold">Configuración del Ecosistema</h1>
    <p class="text-muted small">Mapeo de endpoints de interoperabilidad y variables de red del sistema distribuido.</p>
</div>

<div class="row g-4">
    <div class="col-12 col-lg-7">
        <div class="card border-0 shadow-sm p-4 h-100" style="background-color: var(--bg-tarjeta);">
            <h2 class="h5 fw-bold mb-3">🔗 Endpoints del Servidor SOAP</h2>
            <p class="text-muted small mb-4">Modifique la dirección IP virtual para enlazar dinámicamente tu capa visual con el GlassFish expuesto por Richard.</p>
            
            <form method="POST" action="config">
                <div class="mb-4">
                    <label class="form-label fw-semibold small text-muted">URL del Middleware (WSDL Base)</label>
                    <input type="text" name="urlBase" class="form-control py-2.5 border-2 rounded-2" 
                           value="${not empty soapUrl ? soapUrl : 'http://localhost:8080/BackendTickets'}" 
                           placeholder="Ej: http://xx.xx" required>
                    <div class="form-text text-muted small mt-1">Anteponga siempre el protocolo http:// seguido de la IP de Radmin VPN de Richard.</div>
                </div>
                
                <div class="d-flex gap-2 pt-2">
                    <button type="submit" class="btn btn-primary bg-primary border-primary text-white px-4 fw-semibold py-2">💾 Guardar Conexión</button>
                    <a href="inicio" class="btn btn-jira-action px-3 py-2 text-decoration-none">Cancelar</a>
                </div>
            </form>
        </div>
    </div>

    <div class="col-12 col-lg-5">
        <div class="card border-0 shadow-sm p-4 h-100 bg-dark text-white-50 border-secondary">
            <h2 class="h5 fw-bold mb-3 text-white">🌐 Diagnóstico del Clúster</h2>
            <hr class="border-secondary my-2">
            <ul class="list-unstyled small mb-0 pt-2 d-flex flex-column gap-3">
                <li class="mb-2">
                    <span class="text-white fw-bold d-block">Fase 1: Capa de Persistencia (Libbny)</span>
                    <span class="badge bg-success text-success-light mt-1">SQL Server (Puerto 1433)</span>
                </li>
                <li class="mb-2">
                    <span class="text-white fw-bold d-block">Fase 2: Capa Lógica / Middleware (Richard)</span>
                    <span class="badge bg-success text-success-light mt-1">GlassFish WS SOAP (Puerto 9090)</span>
                </li>
                <li>
                    <span class="text-white fw-bold d-block">Fase 3: Capa de Presentación Web (Tú)</span>
                    <span class="badge bg-primary text-white mt-1">Proyecto MVC Java Web (Bootstrap 5)</span>
                </li>
            </ul>
        </div>
    </div>
</div>
