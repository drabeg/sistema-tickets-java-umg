package servicios;

import jakarta.jws.WebService;
import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebService(serviceName = "WSTickets")
public class WSTickets {

// Datos de Conexion
    String url = "jdbc:sqlserver://26.140.214.229\\SQLEXPRESS;databaseName=DB_ControlTickets;encrypt=true;trustServerCertificate=true;";
    String usuario = "sa"; 
    String contrasena = "123456";

    // Método auxiliar de conexión
    private Connection obtenerConexion() throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, usuario, contrasena);
    }

    // --- 1. INSERTAR TICKET NUEVO ---
    @WebMethod(operationName = "insertarTicket")
    public String insertarTicket(
            @WebParam(name = "titulo") String titulo, 
            @WebParam(name = "descripcion") String descripcion,
            @WebParam(name = "idCategoria") int idCategoria,
            @WebParam(name = "idPrioridad") int idPrioridad,
            @WebParam(name = "idSolicitante") int idSolicitante) {
        try (Connection con = obtenerConexion()) {
            // Nota: Mandamos PosicionCola como 0. El Trigger "TR_Ticket_Insertar" se encargará 
            // de asignarle su Folio y calcular su posición real en la cola inmediatamente después.
            // El IdEstado siempre inicia en 1 (Solicitado).
            String sql = "INSERT INTO Ticket (Titulo, Descripcion, IdCategoria, IdPrioridad, IdEstado, IdSolicitante, PosicionCola) "
                       + "VALUES (?, ?, ?, ?, 1, ?, 0)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setInt(3, idCategoria);
            ps.setInt(4, idPrioridad);
            ps.setInt(5, idSolicitante);
            ps.executeUpdate();
            return "¡Ticket creado exitosamente! (Folio e Historial generados por SQL)";
        } catch (Exception e) { 
            return "Error al crear ticket: " + e.getMessage(); 
        }
    }

    // --- 2. RECLAMAR TICKET (ASIGNAR ESPECIALISTA) ---
    @WebMethod(operationName = "reclamarTicket")
    public String reclamarTicket(@WebParam(name = "idTicket") int idTicket, @WebParam(name = "idEspecialista") int idEspecialista) {
        try (Connection con = obtenerConexion()) {
            // El Trigger "TR_Ticket_Reclamo" validará que no esté reclamado, le pondrá fecha de asignación y creará la notificación.
            String sql = "UPDATE Ticket SET IdEspecialista = ? WHERE IdTicket = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, idEspecialista);
            ps.setInt(2, idTicket);
            int filas = ps.executeUpdate();
            return filas > 0 ? "¡Ticket reclamado exitosamente!" : "No se encontró el ticket.";
        } catch (Exception e) { 
            return "Error al reclamar (o ya fue reclamado): " + e.getMessage(); 
        }
    }

    // --- 3. CAMBIAR ESTADO DE TICKET ---
    @WebMethod(operationName = "cambiarEstadoTicket")
    public String cambiarEstadoTicket(@WebParam(name = "idTicket") int idTicket, @WebParam(name = "idNuevoEstado") int idNuevoEstado) {
        try (Connection con = obtenerConexion()) {
            // El Trigger "TR_Ticket_ValidarEstado" validará que no se salten pasos y creará el historial.
            String sql = "UPDATE Ticket SET IdEstado = ? WHERE IdTicket = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, idNuevoEstado);
            ps.setInt(2, idTicket);
            int filas = ps.executeUpdate();
            return filas > 0 ? "¡Estado actualizado!" : "No se encontró el ticket.";
        } catch (Exception e) { 
            return "Error (Transición inválida o ticket no existe): " + e.getMessage(); 
        }
    }

    // --- 4. ELIMINAR TICKET (BORRADO LÓGICO) ---
    @WebMethod(operationName = "eliminarTicket")
    public String eliminarTicket(@WebParam(name = "idTicket") int idTicket) {
        try (Connection con = obtenerConexion()) {
            String sql = "UPDATE Ticket SET Eliminado = 1 WHERE IdTicket = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, idTicket);
            int filas = ps.executeUpdate();
            return filas > 0 ? "¡Ticket eliminado de la vista!" : "No se encontró el ticket.";
        } catch (Exception e) { 
            return "Error al eliminar: " + e.getMessage(); 
        }
    }

    // --- 5. SELECCIONAR TICKETS ACTIVOS (LA COLA FIFO) ---
    @WebMethod(operationName = "seleccionarTickets")
    public List<String> seleccionarTickets() {
        List<String> listaTickets = new ArrayList<>();
        try (Connection con = obtenerConexion()) {
            // Unimos varias tablas para que la app frontend reciba los textos y no puros números
            String sql = "SELECT T.Folio, T.Titulo, C.NombreCategoria, P.NombrePrioridad, E.NombreEstado, U.NombreCompleto AS Solicitante "
                       + "FROM Ticket T "
                       + "INNER JOIN CategoriaTicket C ON T.IdCategoria = C.IdCategoria "
                       + "INNER JOIN PrioridadTicket P ON T.IdPrioridad = P.IdPrioridad "
                       + "INNER JOIN EstadoTicket E ON T.IdEstado = E.IdEstado "
                       + "INNER JOIN Usuario U ON T.IdSolicitante = U.IdUsuario "
                       + "WHERE T.Eliminado = 0 "
                       + "ORDER BY T.PosicionCola ASC";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                String info = "Folio: " + rs.getString("Folio") + 
                              " | Título: " + rs.getString("Titulo") +
                              " | Cat: " + rs.getString("NombreCategoria") +
                              " | Prio: " + rs.getString("NombrePrioridad") +
                              " | Estado: " + rs.getString("NombreEstado") +
                              " | Solicitante: " + rs.getString("Solicitante");
                listaTickets.add(info);
            }
        } catch (Exception e) { 
            listaTickets.add("Error: " + e.getMessage()); 
        }
        return listaTickets;
    }
}