package tickets.controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import tickets.modelo.Entidades;
import tickets.modelo.Tabla;
import tickets.servicio.CrudService;
import tickets.soap.SoapClient;
import tickets.soap.SoapException;

/** Trazabilidad: historial de cambios de estado de un ticket (WSHistorial). */
@WebServlet(name = "HistorialServlet", urlPatterns = {"/historial"})
public class HistorialServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private static final String SERVICIO_HISTORIAL = "WSHistorial";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = param(req, "id");
        String accion = param(req, "accion");
        String tipo = param(req, "tipo");

        List<Map<String, String>> listaTicketsReal = new ArrayList<>();
        
        // 1. Cargar SIEMPRE los tickets reales para el desplegable
        try {
            List<Map<String, String>> ticketsBD = CrudService.filas(Entidades.obtener("tickets"));
            for (Map<String, String> t : ticketsBD) {
                String idTicket = t.get("ID");
                String codigo = t.getOrDefault("Código", t.getOrDefault("Codigo", idTicket));
                String titulo = t.getOrDefault("Título", t.getOrDefault("Titulo", "Sin título"));
                
                if (idTicket != null && !idTicket.trim().isEmpty()) {
                    Map<String, String> item = new LinkedHashMap<>();
                    item.put("id", idTicket);
                    item.put("texto", (codigo != null ? codigo : idTicket) + " — " + titulo);
                    listaTicketsReal.add(item);
                }
            }
        } catch (Exception ex) {
            req.setAttribute("avisoError", "Error al cargar tickets: " + ex.getMessage());
        }

        // 2. Cargar historial/transiciones desde el servicio SOAP WSHistorial
        Tabla tabla = Tabla.vacia();
        List<Map<String, String>> historialProcesado = new ArrayList<>();

        if (id != null && !id.trim().isEmpty()) {
            try {
                Map<String, String> p = new LinkedHashMap<>();
                p.put("idTicket", id);
                
                // Invocación nativa al servicio SOAP de historial
                List<String> respuestas = SoapClient.invocar(SERVICIO_HISTORIAL, "obtenerHistorialTicket", p);
                
                if (respuestas != null && !respuestas.isEmpty()) {
                    for (String r : respuestas) {
                        Map<String, String> item = new LinkedHashMap<>();
                        item.put("Ticket ID", id);
                        item.put("Detalle / Transición", r);
                        historialProcesado.add(item);
                    }
                    tabla = CrudService.construirTabla(historialProcesado, null);
                } else {
                    tabla = Tabla.vacia().conAviso("No se registraron transiciones para este ticket.");
                }
            } catch (SoapException ex) {
                tabla = Tabla.vacia().conAviso("No hay transiciones registradas para este ticket.");
            } catch (Exception ex) {
                tabla = Tabla.vacia().conAviso("Error al obtener la bitácora del ticket.");
            }
        }

        // 3. Manejo de exportación de archivos (PDF/Excel)
        if ("exportar".equals(accion) && id != null && !id.trim().isEmpty()) {
            exportarArchivo(resp, id, tipo, historialProcesado);
            return;
        }

        // 4. Enviar datos a la vista JSP
        req.setAttribute("tickets", listaTicketsReal);
        req.setAttribute("idSeleccionado", id);
        req.setAttribute("tabla", tabla);
        
        mostrar(req, resp, "historial.jsp", "Centro de Reportes Gerenciales");
    }

    /** Genera la descarga física del archivo en el navegador. */
    private void exportarArchivo(HttpServletResponse resp, String idTicket, String tipo, List<Map<String, String>> historial) throws IOException {
        String extension = "excel".equalsIgnoreCase(tipo) ? "csv" : "txt";
        String mimeType = "excel".equalsIgnoreCase(tipo) ? "text/csv" : "application/octet-stream";
        String nombreArchivo = "Reporte_Bitacora_Ticket_" + idTicket + "." + extension;

        resp.setContentType(mimeType + "; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");

        try (PrintWriter out = resp.getWriter()) {
            out.println("REPORTE DE AUDITORIA Y BITACORA - TICKET #" + idTicket);
            out.println("=================================================");
            out.println();
            if (historial == null || historial.isEmpty()) {
                out.println("Sin transiciones o movimientos registrados.");
            } else {
                for (int i = 0; i < historial.size(); i++) {
                    out.println((i + 1) + ". " + historial.get(i).getOrDefault("Detalle / Transición", ""));
                }
            }
            out.flush();
        }
    }
}