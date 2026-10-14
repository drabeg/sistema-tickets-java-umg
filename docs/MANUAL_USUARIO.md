# Manual de Usuario — Control de Tickets

> Borrador: agrega una captura de pantalla del móvil donde se indica **[CAPTURA]**.

## 1. ¿Para qué sirve?
Registrar incidentes (tickets) y atenderlos en estricto orden de llegada (cola FIFO): **Solicitado → En Proceso → Finalizado**.

## 2. Ingreso
Abra `http://IP-WEB:8080/FrontendTickets/` en el navegador. La pantalla de inicio muestra los módulos y la insignia **Servicios en línea** (verde) o **Sin conexión con los servicios** (rojo). **[CAPTURA]**
En el móvil, el botón ☰ abre el menú.

## 3. Tablero FIFO
Tres columnas, una por estado; el ticket más antiguo está arriba. Cada tarjeta muestra folio, título, categoría, prioridad, solicitante y especialista. **[CAPTURA]**
* **Reclamar:** en *Solicitado*, elija un especialista y pulse *Reclamar*. Solo un especialista puede reclamar cada ticket.
* **Pasar a …:** avanza el ticket a la siguiente etapa (de uno en uno).
* **Historial / Editar / Eliminar:** accesos rápidos de la tarjeta.

## 4. Crear un ticket
*Tickets → + Nuevo* → complete Título, Descripción (opcional), Categoría, Prioridad y Solicitante → *Guardar*. El sistema asigna el folio (p. ej. HD-001). **[CAPTURA]**

## 5. Módulos de mantenimiento
Tickets, Usuarios, Empresas, Roles, Categorías, Estados y Prioridades funcionan igual:
* **Ver todos:** la tabla aparece al entrar. En el móvil cada registro se muestra como una tarjeta.
* **Buscar por ID:** escriba el número y pulse *Buscar*; *Ver todos* limpia el filtro.
* **Nuevo:** botón *+ Nuevo*, llene el formulario y *Guardar*. Los campos con * son obligatorios.
* **Editar:** botón *Editar* del registro; modifique y *Guardar*.
* **Eliminar / Desactivar:** botón rojo; pide confirmación. Usuarios y empresas se *desactivan* (no se borran); los tickets se ocultan.
Si un dato no es válido (correo, número, longitud) se muestra el mensaje y el formulario conserva lo escrito. **[CAPTURA]**

## 6. Notificaciones
Elija un especialista y pulse *Ver pendientes*. Use *Marcar leída* para descartar una alerta. **[CAPTURA]**

## 7. Historial
Elija un ticket para ver cada cambio de estado: fecha, usuario, estado anterior y nuevo, y nota. **[CAPTURA]**

## 8. Configuración
Permite indicar la dirección del servidor de servicios y probar la conexión con cada servicio. **[CAPTURA]**

## 9. Mensajes frecuentes
| Mensaje | Significado |
|---|---|
| No se pudo conectar con … | El servidor de servicios no responde: revisar *Configuración* |
| Transición de estado inválida | Solo se puede avanzar un estado a la vez |
| El ticket ya fue reclamado | Otro especialista lo tomó antes |
| Error (puede estar en uso) | El registro tiene datos relacionados y no se puede eliminar |
