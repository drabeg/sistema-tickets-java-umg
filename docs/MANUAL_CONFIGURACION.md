# Manual de Configuraciones — Control de Tickets

> Borrador listo para completar: sustituye las IPs de ejemplo por las reales y agrega capturas.

## 1. Arquitectura de despliegue
| Servidor | Software | Puerto | Proyecto |
|---|---|---|---|
| Base de datos | SQL Server (Express) | 1433 | `DB_ControlTickets` |
| Servicios | GlassFish 7 + JDK 17 | 8080 | `BackendTickets.war` (JAX-WS) |
| Aplicación web | GlassFish 7 + JDK 17 (o Tomcat 10.1) | 8080 | `FrontendTickets.war` (Servlet/JSP) |
| Cliente | Navegador del móvil | — | `http://IP-WEB:8080/FrontendTickets/` |

## 2. Requisitos de software
JDK 17, GlassFish 7 (Jakarta EE 10), NetBeans (opcional), Maven 3.9+, SQL Server Express + SSMS, controlador `mssql-jdbc-13.4.0.jre11.jar` (incluido en `backend/BackendTickets/lib`).

## 3. Red local
Plan de direcciones (ejemplo): router 192.168.1.1 · BD 192.168.1.10 · Servicios 192.168.1.11 · Web 192.168.1.12 · Móvil 192.168.1.20 · máscara 255.255.255.0.
Perfil de red de Windows: **Privada**. Desactivar el aislamiento de clientes en el router.

## 4. Servidor de base de datos
1. Ejecutar `database/control_tickets_db.sql`.
2. Autenticación mixta y usuario `sa` habilitado.
3. TCP/IP habilitado, puerto fijo 1433 (Configuration Manager → IPAll), reiniciar el servicio.
4. Regla de firewall: `netsh advfirewall firewall add rule name="SQL Server 1433" dir=in action=allow protocol=TCP localport=1433`.

## 5. Servidor de servicios
1. En cada `WS*.java` configurar `jdbc:sqlserver://IP-BD:1433;databaseName=DB_ControlTickets;encrypt=true;trustServerCertificate=true;`, usuario y contraseña.
2. Compilar (`Clean and Build`) y desplegar `BackendTickets.war` (consola `http://localhost:4848` → Applications → Deploy).
3. Firewall del puerto 8080.
4. Verificar: `http://IP-SERVICIOS:8080/BackendTickets/WSTickets?wsdl`.

Servicios publicados: WSEmpresas, WSRoles, WSUsuarios, WSCategorias, WSEstados, WSPrioridades, WSTickets, WSHistorial, WSNotificaciones.

## 6. Servidor de aplicación web
1. `mvn clean package` (o `-Ptomcat` para Tomcat/XAMPP) → `target/FrontendTickets.war`; desplegar.
2. Firewall del puerto 8080.
3. URL de servicios: pantalla **Configuración**, o `config.properties` (`soap.base.url`), o parámetro de JVM `-Dsoap.base.url=...`, o variable de entorno `TICKETS_SOAP_URL`.
4. Probar con *Probar conexión con los servicios* (deben salir 9 en OK).

## 7. Dispositivo móvil
Conectar al Wi-Fi del laboratorio, fijar IP estática (o reserva DHCP) y abrir `http://IP-WEB:8080/FrontendTickets/`.
