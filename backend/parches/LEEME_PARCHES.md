# Parches sugeridos para el backend (BackendTickets)

El backend de WSTickets original **no devuelve el ID de cada ticket** y no tiene *actualizar* ni *seleccionar por ID*.
La aplicación web los necesita (reclamar, avanzar, editar y eliminar trabajan por ID). Estos archivos son
reemplazos completos; revísenlos con quien hizo el backend antes de integrarlos.

| Archivo | Qué cambia | Prioridad |
|---|---|---|
| `WSTickets.java` | `seleccionarTickets` ahora antepone `ID: n` y agrega `Especialista`; nuevos métodos `seleccionarTicketPorId` y `actualizarTicket`. Es compatible con lo anterior (solo agrega campos). | **Alta** |
| `WSUsuarios.java` | Corrige la URL JDBC: tenía `t rustServerCertificate` (con un espacio). Sin esto, con `encrypt=true` este servicio puede fallar por el certificado del servidor SQL mientras los demás funcionan. | **Alta** |

Cómo aplicarlos: copiar cada archivo sobre `backend/BackendTickets/src/java/servicios/`, *Clean and Build* en NetBeans y volver a desplegar.

## Pendientes de cumplimiento del enunciado (decisión del equipo)

El enunciado pide CRUD completo (insertar, actualizar, eliminar, seleccionar todos y por ID) de **todas** las tablas del diagrama ER.
Hoy el backend no cumple del todo:

| Servicio | Falta |
|---|---|
| WSCategorias, WSEstados, WSPrioridades | `seleccionarXPorId` (la web lo suple filtrando la lista, pero el servicio debe tenerlo) |
| WSHistorial | solo tiene `seleccionarHistorialPorTicket` (no insertar/actualizar/eliminar/por ID) |
| WSNotificaciones | solo pendientes y `marcarNotificacionLeida` |

Ejemplo de patrón para `seleccionarPorId` de un catálogo (WSPrioridades):

```java
@WebMethod(operationName = "seleccionarPrioridadPorId")
public String seleccionarPrioridadPorId(@WebParam(name = "idPrioridad") int idPrioridad) {
    try (Connection con = obtenerConexion()) {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM PrioridadTicket WHERE IdPrioridad = ?");
        ps.setInt(1, idPrioridad);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return "ID: " + rs.getInt("IdPrioridad") + " | Prioridad: " + rs.getString("NombrePrioridad")
                 + " | Peso: " + rs.getInt("NivelPeso");
        }
        return "No se encontró ninguna prioridad con el ID: " + idPrioridad;
    } catch (Exception e) {
        return "Error: " + e.getMessage();
    }
}
```

Cuando existan, se activan en la web cambiando **una línea** en `frontend/FrontendTickets/src/main/java/tickets/modelo/Entidades.java`
(por ejemplo `.porId("seleccionarPrioridadPorId")`). Historial y Notificaciones son tablas de auditoría que llenan los triggers;
si el equipo decide dejarlas de solo lectura, conviene justificarlo explícitamente ante el ingeniero.

## Otros riesgos que conviene corregir antes de subir a GitHub

* **Credenciales en el código:** `sa` / `123456` y la IP están escritas en los 9 servicios. Usen un repositorio **privado** y, de ser posible, centralicen la conexión en una sola clase `Conexion` para cambiar la IP en un único lugar el día de la presentación.
* **Contraseñas:** `insertarUsuario` guarda la contraseña con `CONVERT(VARBINARY, ?)`, es decir, texto sin protección, aunque el script SQL dice "Hash (nunca texto plano)". Si el ingeniero lo revisa, conviene aplicar un hash (p. ej. `HASHBYTES('SHA2_256', ?)`).
* **Servidor:** el proyecto está configurado para **GlassFish 7** (Jakarta EE 10). El checklist menciona XAMPP; confirmen con el ingeniero qué servidor espera, porque un `@WebService` en Tomcat/XAMPP requiere librerías JAX-WS adicionales.
