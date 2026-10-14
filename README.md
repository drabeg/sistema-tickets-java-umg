# Control de Tickets (cola FIFO) — Proyecto Final Programación II

Sistema de tickets en arquitectura de 3 capas sobre red local:

```
 Móvil (navegador) ──HTTP──▶ Servidor WEB (FrontendTickets, Servlet/JSP, :8080)
                                   │ SOAP/HTTP
                                   ▼
                       Servidor de SERVICIOS (BackendTickets, JAX-WS, :8080)
                                   │ JDBC
                                   ▼
                       Servidor de BASE DE DATOS (SQL Server, :1433)
```

| Carpeta | Contenido |
|---|---|
| `database/` | Script T-SQL: tablas, catálogos, triggers y procedimientos |
| `backend/BackendTickets/` | Servicios SOAP (JAX-WS) — proyecto NetBeans/GlassFish 7 |
| `backend/parches/` | Cambios sugeridos al backend (leer `LEEME_PARCHES.md`) |
| `frontend/FrontendTickets/` | Aplicación web (Maven, Servlet + JSP, responsive) |
| `docs/` | Guía de entrega, manuales (técnico, usuario, configuración) y diccionario de datos |
| `herramientas/` | `MockBackend.java`: backend simulado para probar la web sin BD (no es parte de la entrega) |

## Inicio rápido
1. Ejecutar `database/control_tickets_db.sql` en SQL Server.
2. Desplegar `BackendTickets` en GlassFish 7 (equipo de servicios).
3. Compilar y desplegar la web: `cd frontend/FrontendTickets && mvn clean package` → `target/FrontendTickets.war`.
4. Abrir `http://IP-WEB:8080/FrontendTickets/` → **Configuración** → indicar `http://IP-SERVICIOS:8080/BackendTickets` → *Probar conexión*.

Detalle completo en `docs/GUIA_ENTREGA_FINAL.md` y `docs/MANUAL_CONFIGURACION.md`.

## Integrantes
_Completar con los 5 integrantes y su rol._
