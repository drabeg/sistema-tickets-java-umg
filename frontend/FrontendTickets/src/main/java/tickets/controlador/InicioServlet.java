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
import tickets.modelo.Campo;
import tickets.modelo.ColumnaTablero;
import tickets.modelo.Entidad;
import tickets.modelo.Entidades;
import tickets.modelo.Opcion;
import tickets.servicio.CrudService;
import tickets.soap.SoapClient;
import tickets.soap.SoapException;
import tickets.util.Filas;

/**
 * Tablero Kanban de la pantalla de inicio, alimentado por los servicios SOAP.
 *   GET  /inicio                      dibuja las columnas con los tickets reales
 *   POST /inicio  accion=crear        registra un ticket nuevo (WSTickets.insertarTicket)
 *   POST /inicio  accion=atender      reclama el ticket y lo pasa a "En Proceso"
 *   POST /inicio  accion=avanzar      mueve el ticket al siguiente estado
 * Todas las acciones POST responden con redirect (PRG) y un mensaje que muestra el encabezado.
 */
@WebServlet(name = "InicioServlet", urlPatterns = {"/inicio"})
public class InicioServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private static final String SERVICIO = "WSTickets";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<ColumnaTablero> columnas = new ArrayList<>();
        List<Opcion> categorias = new ArrayList<>();
        List<Opcion> prioridades = new ArrayList<>();
        List<Opcion> solicitantes = new ArrayList<>();
        List<Opcion> especialistas = new ArrayList<>();
        boolean avisoParche = false;
        try {
            List<Map<String, String>> estados = CrudService.filas(Entidades.obtener("estados"));
            List<Map<String, String>> tickets = CrudService.filas(Entidades.obtener("tickets"));
            List<Map<String, String>> usuarios = CrudService.filas(Entidades.obtener("usuarios"));
            columnas = TableroServlet.armarColumnas(estados);
            avisoParche = TableroServlet.distribuir(columnas, tickets);
            especialistas = TableroServlet.especialistas(usuarios);
            solicitantes = CrudService.opciones(Entidades.obtener("usuarios"), usuarios);
            categorias = CrudService.opciones(Entidades.obtener("categorias"));
            prioridades = CrudService.opciones(Entidades.obtener("prioridades"));
        } catch (SoapException ex) {
            aviso(req, "error", "No se pudo cargar el tablero: " + ex.getMessage());
        }
        req.setAttribute("columnas", columnas);
        req.setAttribute("categorias", categorias);
        req.setAttribute("prioridades", prioridades);
        req.setAttribute("solicitantes", solicitantes);
        req.setAttribute("especialistas", especialistas);
        req.setAttribute("avisoParche", avisoParche);
        mostrar(req, resp, "inicio.jsp", "Inicio");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accion = param(req, "accion");
        try {
            switch (accion) {
                case "crear":
                    crear(req);
                    break;
                case "atender":
                    atender(req);
                    break;
                case "avanzar":
                    avanzar(req);
                    break;
                default:
                    flash(req, "error", "Acción no reconocida.");
            }
        } catch (IllegalArgumentException | SoapException ex) {
            flash(req, "error", ex.getMessage());
        }
        redirigir(req, resp, "/inicio");
    }

    // ------------------------------------------------------------------ acciones

    private void crear(HttpServletRequest req) throws SoapException {
        Entidad e = Entidades.obtener("tickets");
        Map<String, String> valores = new LinkedHashMap<>();
        for (Campo c : e.getCampos()) {
            valores.put(c.getNombre(), param(req, c.getNombre()));
        }
        List<String> errores = CrudService.validar(e, valores, false);
        if (!errores.isEmpty()) {
            flash(req, "error", String.join(" ", errores));
            return;
        }
        String mensaje = CrudService.guardar(e, valores, null);
        flash(req, tipoDe(mensaje), mensaje);
    }

    private void atender(HttpServletRequest req) throws SoapException {
        String idTicket = idValido(req, "idTicket", "ticket");
        String idEsp = idValido(req, "idEspecialista", "especialista");
        String idEstado = idValido(req, "idNuevoEstado", "estado");

        Map<String, String> reclamo = new LinkedHashMap<>();
        reclamo.put("idTicket", idTicket);
        reclamo.put("idEspecialista", idEsp);
        String r1 = SoapClient.invocarTexto(SERVICIO, "reclamarTicket", reclamo);
        if (!"ok".equals(tipoDe(r1))) {
            flash(req, "error", r1);
            return;
        }
        Map<String, String> cambio = new LinkedHashMap<>();
        cambio.put("idTicket", idTicket);
        cambio.put("idNuevoEstado", idEstado);
        String r2 = SoapClient.invocarTexto(SERVICIO, "cambiarEstadoTicket", cambio);
        if ("ok".equals(tipoDe(r2))) {
            flash(req, "ok", "Ticket reclamado y movido a la siguiente etapa.");
        } else {
            flash(req, "error", "El ticket se reclamó, pero no pudo avanzar: " + r2);
        }
    }

    private void avanzar(HttpServletRequest req) throws SoapException {
        Map<String, String> p = new LinkedHashMap<>();
        p.put("idTicket", idValido(req, "idTicket", "ticket"));
        p.put("idNuevoEstado", idValido(req, "idNuevoEstado", "estado"));
        String r = SoapClient.invocarTexto(SERVICIO, "cambiarEstadoTicket", p);
        flash(req, tipoDe(r), "ok".equals(tipoDe(r)) ? "Ticket movido de etapa." : r);
    }

    private static String idValido(HttpServletRequest req, String nombre, String etiqueta) {
        String v = param(req, nombre);
        if (!Filas.esEnteroPositivo(v)) {
            throw new IllegalArgumentException("Dato no válido: " + etiqueta + ".");
        }
        return v;
    }
}
