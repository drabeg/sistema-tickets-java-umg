# Manual de Operación y Usuario — Sistema de Gestión de Tickets

Este documento describe la funcionalidad de la plataforma y sirve como guía operativa para la administración de incidencias bajo el esquema de colas FIFO en el entorno distribuido.

---

## 1. Propósito del Sistema

El sistema automatiza el registro, seguimiento y resolución de incidentes técnicos (*help desk*) garantizando un flujo secuencial estricto controlado por base de datos. Las incidencias transicionan de manera ordenada bajo los siguientes estados mutables:
\[\text{Solicitado} \longrightarrow \text{En Proceso} \longrightarrow \text{Finalizado}\]

---

## 2. Acceso a la Plataforma

Para iniciar la aplicación, abra el navegador web de su dispositivo e ingrese la URL correspondiente al nodo de presentación:
```http
http://[IP_NODO_FRONTEND]:8080/FrontendTickets/
```
* **Indicador de Conectividad:** La cabecera superior despliega dinámicamente el estado del clúster. La insignia **"Servicios en línea"** (color verde) confirma la comunicación XML/SOAP activa; de lo contrario, se mostrará la alerta **"Sin conexión con los servicios"** (color rojo).
* **Adaptabilidad Móvil:** En dispositivos móviles, la interfaz se compacta automáticamente y habilita un menú colapsable accesible mediante el ícono de hamburguesa (`☰`).

---

## 3. Operación del Tablero FIFO

El módulo central opera mediante un modelo Kanban adaptado a la lógica FIFO (primero en entrar, primero en salir), organizando las tarjetas de modo que la incidencia más antigua se ubica siempre en la parte superior de cada columna.

### Elementos de la Tarjeta de Incidencia
Cada registro visualiza el identificador único (Folio), título de la falla, categoría de clasificación, nivel de prioridad asignada, datos del solicitante y el especialista asignado.

### Flujo de Acciones de Control
* **Reclamar Incidencia:** Dentro de la columna *Solicitado*, el operador debe seleccionar su identificador de especialista en el menú desplegable y presionar el botón **Reclamar**. El sistema bloquea transacciones concurrentes para impedir el doble reclamo de un mismo ticket.
* **Avanzar Estado:** Modifica secuencialmente la fase actual hacia la etapa inmediata superior (de *Solicitado* a *En Proceso*, y de *En Proceso* a *Finalizado*) habilitando los botones de acción rápida tras cada validación.
* **Accesos Directos:** Cada tarjeta provee enlaces contextuales directos para consultar el histórico de transiciones, efectuar modificaciones de edición o proceder con el borrado lógico.

---

## 4. Registro de Nuevas Incidencias

1. Diríjase a la sección **Tickets** dentro del menú de navegación y presione el botón **+ Nuevo**.
2. Complete el formulario con los siguientes datos obligatorios: *Título*, *Categoría de Servicio*, *Prioridad* y *Usuario Solicitante*. El campo *Descripción* se mantiene opcional para detalles extendidos.
3. Pulse **Guardar**. El sistema procesará la solicitud en el backend y retornará un folio estructurado de forma automática (por ejemplo: `HD-001`, `SW-002`) de acuerdo con la categoría seleccionada.

---

## 5. Módulos de Mantenimiento y Catálogos

Los submódulos de gestión (*Tickets, Usuarios, Empresas, Roles, Categorías, Estados y Prioridades*) unifican su experiencia de usuario bajo el patrón de mantenimiento genérico:

* **Visualización de Datos:** Despliega los registros en tablas estructuradas para pantallas de escritorio, transformándose de forma automática en tarjetas independientes al procesarse desde pantallas móviles.
* **Búsqueda Dinámica por ID:** Permite filtrar de forma exacta ingresando el código del registro y presionando *Buscar*. El control *Ver todos* restablece los filtros de la grilla.
* **Inserción y Modificación:** Al presionar **+ Nuevo** o **Editar**, se despliega un formulario con validaciones en tiempo real en la capa del servidor. Los campos requeridos se encuentran señalados con un asterisco (`*`). Si el sistema detecta inconsistencias (longitudes inválidas o formatos de correo erróneos), interrumpe el almacenamiento y preserva los datos ingresados para su corrección rápida.
* **Remoción Segura (Borrado Lógico):** El botón de eliminación solicita una confirmación explícita. Para proteger la integridad referencial del histórico, los módulos de *Usuarios* y *Empresas* ejecutan una **desactivación de estado**, mientras que los *Tickets* se marcan con un flag oculto sin ser eliminados físicamente del motor de base de datos.

---

## 6. Centro de Notificaciones

Permite auditar el buzón de alertas del personal técnico. Al seleccionar un especialista y pulsar **Ver pendientes**, la interfaz cargará las acciones del sistema automatizadas por los *triggers*. La acción **Marcar como leída** archiva la alerta del tablero de pendientes del especialista.

---

## 7. Trazabilidad e Historial

Módulo dedicado a la auditoría de datos. Al seleccionar una incidencia, el sistema consulta el histórico completo en orden cronológico, detallando: la marca de tiempo exacta (fecha y hora), el usuario responsable, el estado de origen, el estado de destino y la nota técnica justificativa del cambio.

---

## 8. Consola de Configuración General

Herramienta administrativa para realizar la interconexión de la arquitectura distribuida. Permite ingresar o modificar la dirección IP y puerto del servidor de servicios en caliente. Cuenta con el botón **"Probar conexión con los servicios"**, el cual ejecuta una verificación asíncrona de los 9 descriptores SOAP independientes para certificar la salud de la red local.

---

## 9. Catálogo de Mensajes del Sistema

| Mensaje de Error en Pantalla | Significado Técnico | Acción Correctiva Recomendada |
| :--- | :--- | :--- |
| *No se pudo conectar con el servicio...* | Pérdida de conectividad con la capa intermedia SOAP. | Verificar IP en la sección de *Configuración* y revisar reglas del firewall local. |
| *Transición de estado inválida* | Intento de saltar fases del ciclo de vida FIFO. | Avanzar los flujos estrictamente de uno en uno (`Solicitado -> En Proceso -> Finalizado`). |
| *El ticket ya fue reclamado* | Conflicto de concurrencia en base de datos. | Seleccionar otra incidencia libre; el ticket ya cuenta con un especialista asignado. |
| *Error (puede estar en uso)* | Restricción por clave foránea de integridad referencial. | No es posible eliminar el catálogo porque existen registros dependientes vinculados a él. |
