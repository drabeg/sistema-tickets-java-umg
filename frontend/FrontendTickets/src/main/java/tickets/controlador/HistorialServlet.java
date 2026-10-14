package tickets.controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import tickets.modelo.Entidades;
import tickets.modelo.Opcion;
import tickets.modelo.Tabla;
import tickets.servicio.CrudService;
import tickets.soap.SoapClient;
import tickets.soap.SoapException;
import tickets.util.Filas;

/** Trazabilidad: historial de cambios de estado de un ticket (WSHistorial). */
@WebServlet(name = "HistorialServlet", urlPatterns = {"/historial"})
public class HistorialServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = param(req, "id");
        List<Opcion> tickets = new ArrayList<>();
        try {
            for (Map<String, String> t : CrudService.filas(Entidades.obtener("tickets"))) {
                if (!Filas.vacio(t.get("ID"))) {
                    tickets.add(new Opcion(t.get("ID"), t.getOrDefault("Folio", "") + " — " + t.getOrDefault("Título", "")));
                }
            }
        } catch (SoapException ex) {
            aviso(req, "error", ex.getMessage());
        }
        Tabla tabla = Tabla.vacia();
        if (!id.isEmpty()) {
            if (!Filas.esEnteroPositivo(id)) {
                aviso(req, "error", "El ID del ticket debe ser un número entero positivo.");
            } else {
                try {
                    Map<String, String> p = new LinkedHashMap<>();
                    p.put("idTicket", id);
                    List<String> crudas = SoapClient.invocar("WSHistorial", "seleccionarHistorialPorTicket", p);
                    if (Filas.esError(crudas)) {
                        aviso(req, "error", crudas.get(0));
                    } else {
                        List<Map<String, String>> filas = new ArrayList<>();
                        for (String linea : crudas) {
                            filas.add(separarTransicion(Filas.parsear(linea)));
                        }
                        tabla = CrudService.construirTabla(filas, null);
                        if (filas.isEmpty()) {
                            tabla.conAviso("Este ticket no tiene historial registrado.");
                        }
                    }
                } catch (SoapException ex) {
                    aviso(req, "error", ex.getMessage());
                }
            }
        }
        req.setAttribute("tickets", tickets);
        req.setAttribute("idSeleccionado", id);
        req.setAttribute("tabla", tabla);
        mostrar(req, resp, "historial.jsp", "Historial de tickets");
    }

    /** El servicio devuelve "De: X -> A: Y"; se separa en dos columnas. */
    static Map<String, String> separarTransicion(Map<String, String> fila) {
        String de = fila.get("De");
        if (de == null || !de.contains(" -> A: ")) {
            return fila;
        }
        Map<String, String> nueva = new LinkedHashMap<>();
        for (Map.Entry<String, String> e : fila.entrySet()) {
            if ("De".equals(e.getKey())) {
                int i = de.indexOf(" -> A: ");
                nueva.put("De", de.substring(0, i));
                nueva.put("A", de.substring(i + 7));
            } else {
                nueva.put(e.getKey(), e.getValue());
            }
        }
        return nueva;
    }
}
