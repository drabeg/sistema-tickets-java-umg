# Guía maestra de la entrega final — Control de Tickets

Esta guía te lleva de cero a la presentación. Sigue las fases en orden y marca cada casilla.

---

## 0. Qué te piden (resumen) y qué confirmar con el ingeniero

| Requisito | Dónde se cumple |
|---|---|
| 3 servidores en red local (BD, Servicios, Web) que interactúan | Fase 3 |
| Servidor de servicios con CRUD completo (insertar, actualizar, eliminar, seleccionar todos, seleccionar por ID) | `backend/` + parches (ver `backend/parches/LEEME_PARCHES.md`) |
| Aplicación web con formularios para insertar, actualizar, eliminar, ver todos y filtrar por ID, de **todas las tablas del ER** | `frontend/FrontendTickets` |
| Presentación desde un **dispositivo móvil** con IP específica en la red local | Fase 3.6 |
| Entregables: script de BD, código fuente (servicios y web), manual de usuario, manual de configuraciones | `database/`, `backend/`, `frontend/`, `docs/` |
| (Del checklist de imágenes) Manual técnico con arquitectura + diccionario de BD, y video de defensa con los 5 integrantes | `docs/MANUAL_TECNICO.md`, `docs/DICCIONARIO_DB.md`, Fase 6 |

**Pregunten esto al ingeniero (una sola vez, por escrito):**
1. ¿Servidor de servicios en **GlassFish** (como está el backend) o en **XAMPP/Tomcat**? El checklist dice XAMPP; el backend actual está hecho para GlassFish 7.
2. ¿Piden "Manual de configuraciones" (enunciado) o "Manual técnico" (checklist), o ambos? Lo más seguro: entregar los tres documentos.
3. ¿El video es obligatorio y en qué formato/plataforma se entrega?
4. ¿Historial y Notificaciones (tablas de auditoría) deben tener CRUD completo o basta con consulta?

---

## 1. Reparto sugerido para 5 integrantes

| Rol | Responsabilidad |
|---|---|
| 1. Base de datos | Script SQL, SQL Server accesible por red, diccionario de datos |
| 2. Servicios | BackendTickets en GlassFish, parches, prueba de WSDL |
| 3. Web (tú) | FrontendTickets, pruebas desde el móvil |
| 4. Infraestructura y repositorio | Red local, IPs fijas, firewall, GitHub |
| 5. Documentación | Manuales, capturas, guion y edición del video |

Todos deben poder explicar cualquier parte del código: en la defensa se sustenta entre los cinco.

---

## 2. GitHub desde cero (Windows)

### 2.1 Instalar y configurar Git
1. Descarga Git para Windows desde <https://git-scm.com/download/win> e instálalo con las opciones por defecto (incluye *Git Bash* y *Git Credential Manager*).
2. Abre **Git Bash** y configura tu identidad (una sola vez por PC):
```bash
git config --global user.name  "Tu Nombre"
git config --global user.email "tu-correo@ejemplo.com"
git config --global init.defaultBranch main
```
3. Verifica: `git --version`

### 2.2 Crear la cuenta y el repositorio remoto
1. Crea una cuenta en <https://github.com> (usa el correo que configuraste en Git).
2. **+ → New repository**. Nombre: `proyecto-tickets`.
3. Visibilidad: **Private** (el código tiene la IP y la contraseña de la BD; no lo publiquen).
4. **No** marques "Add a README", ni `.gitignore`, ni licencia (ya vienen en el proyecto).
5. Crea el repositorio y copia la URL `https://github.com/USUARIO/proyecto-tickets.git`.

### 2.3 Preparar la carpeta del proyecto
Descomprime el repo entregado (`proyecto-tickets`). La estructura debe quedar así:
```
proyecto-tickets/
├── README.md
├── .gitignore
├── database/        (script SQL)
├── backend/         (BackendTickets + parches)
├── frontend/        (FrontendTickets)
├── docs/            (guías y manuales)
└── herramientas/    (MockBackend, opcional)
```
Antes de subir, **revisa que no haya contraseñas reales** que no quieras exponer (el backend tiene `sa/123456`, ver `LEEME_PARCHES.md`).

### 2.4 Subir por primera vez
Dentro de la carpeta (clic derecho → *Open Git Bash here*):
```bash
git init -b main
git add .
git status                       # revisa qué se va a subir (no debe aparecer build/, dist/, target/)
git commit -m "Versión inicial: base de datos, backend y frontend"
git remote add origin https://github.com/USUARIO/proyecto-tickets.git
git push -u origin main
```
La primera vez se abrirá el navegador para autenticarte (Git Credential Manager). Si pide contraseña por consola, **no** es la de tu cuenta: crea un *Personal Access Token* en GitHub → Settings → Developer settings → Personal access tokens (permiso `repo`) y úsalo como contraseña.

### 2.5 Agregar a los compañeros
Repositorio → **Settings → Collaborators → Add people** (por usuario o correo). Cada uno acepta la invitación y clona:
```bash
git clone https://github.com/USUARIO/proyecto-tickets.git
```

### 2.6 Flujo de trabajo diario (para los 5)
```bash
git pull                                   # 1) traer lo último antes de empezar
git switch -c feature/mi-cambio            # 2) crear una rama propia
# ... editar archivos ...
git add .
git commit -m "Descripción corta de lo que cambié"
git push -u origin feature/mi-cambio       # 3) subir la rama
```
4. En GitHub aparece el botón **Compare & pull request** → crear el *Pull Request* → otro integrante revisa → **Merge**.
5. Todos vuelven a `main` y actualizan: `git switch main && git pull`.

Reglas simples: un cambio por commit, mensajes claros, nunca trabajar dos personas sobre el mismo archivo sin avisar, y **jamás** subir `build/`, `dist/`, `target/` ni `nbproject/private/` (ya están en `.gitignore`).
Si hay un conflicto, Git marca `<<<<<<<` en el archivo: se editan los dos lados, se deja el texto correcto, y luego `git add archivo` + `git commit`.

### 2.7 Marcar la versión final
```bash
git tag -a v1.0-entrega -m "Entrega final"
git push origin v1.0-entrega
```
En GitHub → **Releases → Draft a new release** → elige la etiqueta `v1.0-entrega` y adjunta `BackendTickets.war`, `FrontendTickets.war` y los manuales en PDF. Así tienes los binarios listos sin ensuciar el repo.

> Alternativa gráfica: NetBeans → *Team → Git → Initialize Repository* y *Team → Remote → Push*; o GitHub Desktop.

---

## 3. Armar la red local con 3 servidores y el móvil

### 3.1 Plan de direcciones (ejemplo; ajusta al rango de tu router)
| Equipo | Rol | IP fija de ejemplo |
|---|---|---|
| Router / punto de acceso | puerta de enlace | 192.168.1.1 |
| PC 1 | **Base de datos** (SQL Server) | 192.168.1.10 |
| PC 2 | **Servicios** (GlassFish + BackendTickets) | 192.168.1.11 |
| PC 3 | **Web** (GlassFish + FrontendTickets) | 192.168.1.12 |
| Móvil | cliente de la presentación | 192.168.1.20 |

Los 4 dispositivos deben estar en la **misma red** (mismo router/Wi-Fi, máscara 255.255.255.0). Desactiva el *aislamiento de clientes* (AP isolation) del router. En Windows pon la red como **Privada**.
> La IP `26.x.x.x` que usa hoy el backend suele ser de Radmin VPN/Hamachi (sirve para trabajar a distancia, pero **no** para la presentación en red local).

### 3.2 IP fija en cada PC (Windows)
Configuración → Red e Internet → Wi-Fi/Ethernet → Propiedades → *Asignación de IP* → **Manual** → IPv4: dirección, máscara `255.255.255.0`, puerta de enlace `192.168.1.1`. Comprueba con `ipconfig` y con `ping` entre equipos.

### 3.3 PC 1 — SQL Server
1. Ejecuta `database/control_tickets_db.sql` en SSMS (crea `DB_ControlTickets` con tablas, catálogos, triggers y procedimientos).
2. Habilita **autenticación mixta**: SSMS → clic derecho al servidor → Propiedades → Seguridad → *SQL Server and Windows Authentication*. Habilita el login `sa` con contraseña.
3. Habilita TCP/IP: *SQL Server Configuration Manager* → Configuración de red de SQL Server → Protocolos de SQLEXPRESS → **TCP/IP: Habilitado** → Propiedades → pestaña *Direcciones IP* → sección **IPAll**: deja *Puertos dinámicos TCP* vacío y pon *Puerto TCP* = `1433`.
4. Reinicia el servicio *SQL Server (SQLEXPRESS)*.
5. Abre el firewall (CMD como administrador):
```bat
netsh advfirewall firewall add rule name="SQL Server 1433" dir=in action=allow protocol=TCP localport=1433
```
6. Prueba desde PC 2: `Test-NetConnection 192.168.1.10 -Port 1433` (PowerShell) debe decir `TcpTestSucceeded : True`.

### 3.4 PC 2 — Servicios (BackendTickets en GlassFish 7)
1. Aplica los parches de `backend/parches/` (sobre todo `WSTickets.java` y `WSUsuarios.java`).
2. En **los 9** archivos `WS*.java` cambia la URL a la IP del PC 1 (recomendado, sin instancia con nombre):
```java
String url = "jdbc:sqlserver://192.168.1.10:1433;databaseName=DB_ControlTickets;encrypt=true;trustServerCertificate=true;";
```
3. NetBeans → *Clean and Build* → *Run* (o despliega `dist/BackendTickets.war` en la consola de GlassFish `http://localhost:4848` → Applications → Deploy).
4. Firewall:
```bat
netsh advfirewall firewall add rule name="GlassFish 8080" dir=in action=allow protocol=TCP localport=8080
```
5. Prueba el WSDL en el navegador de otro equipo: `http://192.168.1.11:8080/BackendTickets/WSTickets?wsdl` (debe mostrar XML). Repite con los otros 8 servicios.

### 3.5 PC 3 — Web (FrontendTickets)
1. Compila: `cd frontend/FrontendTickets && mvn clean package` (genera `target/FrontendTickets.war`). En NetBeans: *File → Open Project* sobre la carpeta `FrontendTickets` (detecta el `pom.xml`) → *Run* con GlassFish 7.
   Si usan **Tomcat/XAMPP**: `mvn clean package -Ptomcat` y copian el WAR a `webapps`.
2. Abre el firewall del puerto 8080 (mismo comando del paso 3.4).
3. Entra a `http://localhost:8080/FrontendTickets/` → **⚙ Configuración** → escribe `http://192.168.1.11:8080/BackendTickets` → *Guardar* → **Probar conexión con los servicios**: los 9 deben salir **OK**.
   (Para que arranque con esa URL sin tocar la pantalla: editar `src/main/resources/config.properties` y recompilar.)

### 3.6 Dispositivo móvil con IP específica
1. Conecta el móvil a la **misma red Wi-Fi**.
2. IP fija: **Android** → Wi-Fi → (engrane de la red) → Avanzado → *Ajustes de IP: Estática*; **iPhone** → Wi-Fi → (i) → *Configurar IP: Manual*. Usa `192.168.1.20`, máscara `255.255.255.0`, puerta `192.168.1.1`.
   (Alternativa: reservar esa IP al móvil por su MAC en el router.)
3. Abre en el navegador del móvil: `http://192.168.1.12:8080/FrontendTickets/`. La presentación se hace desde este dispositivo.

---

## 4. Pruebas antes de presentar (marca cada una)

- [ ] Inicio muestra "Servicios en línea" (insignia verde).
- [ ] **Tickets**: crear (aparece con folio, p. ej. HD-001), filtrar por ID, editar, eliminar.
- [ ] **Usuarios, Empresas, Roles, Categorías, Estados, Prioridades**: insertar, editar, eliminar/desactivar, ver todos, buscar por ID.
- [ ] **Tablero FIFO**: reclamar con un especialista → avanzar a *En Proceso* → *Finalizado*. Probar que **no** deja saltar estados ni reclamar dos veces (lo valida la BD).
- [ ] **Notificaciones**: al reclamar, el especialista ve la alerta y puede marcarla leída.
- [ ] **Historial**: muestra cada cambio de estado de un ticket.
- [ ] Todo se ve bien en el móvil (vertical y horizontal).
- [ ] Apagar el servicio y comprobar que la web muestra un mensaje claro (no una página en blanco).

---

## 5. Entregables y su contenido

| Entregable | Archivo | Qué debe incluir |
|---|---|---|
| Script de la base de datos | `database/control_tickets_db.sql` | Ya listo. Probarlo en una instancia limpia. |
| Código de Servicios | `backend/BackendTickets/` | Fuentes + `lib/` con el driver JDBC (ya relativo al proyecto). |
| Código de Aplicación web | `frontend/FrontendTickets/` | Fuentes MVC (controlador / servicio / modelo / vistas JSP). |
| Manual de Usuario | `docs/MANUAL_USUARIO.md` → exportar a PDF | Pasos de cada pantalla **con capturas del móvil**. |
| Manual de Configuraciones | `docs/MANUAL_CONFIGURACION.md` → PDF | Red, IPs, SQL Server, GlassFish, firewall, URLs. |
| Manual Técnico | `docs/MANUAL_TECNICO.md` + `docs/DICCIONARIO_DB.md` → PDF | Arquitectura, MVC, SOAP, FIFO, diccionario de datos. |
| Video de defensa | (grabación) | Ver sección 6. |

Para exportar a PDF: abre el `.md` en VS Code (extensión *Markdown PDF*), o pégalo en Word/Google Docs y *Guardar como PDF*. Agrega portada con nombres, curso e ingeniero.
Capturas recomendadas: Inicio, Tablero con tickets en las tres columnas, lista de cada módulo, un formulario, una alerta de error de validación, Configuración con la prueba de conexión, y el WSDL en el navegador.

---

## 6. Video de defensa (5 integrantes)
Duración sugerida 10–15 min, cada integrante 2–3 min:
1. **BD:** modelo ER, diccionario, triggers (folio, FIFO, validación de estados, reclamo) y un ejemplo en SSMS.
2. **Servicios:** un `@WebService`, WSDL, cómo se conecta por JDBC y por qué devuelve texto.
3. **Web (MVC):** ruta de una petición: JSP → `CrudServlet` → `CrudService` → `SoapClient` → servicio → BD y de vuelta; validaciones; diseño responsive.
4. **Red:** los 3 servidores y el móvil, IPs, firewall.
5. **Demo completa** desde el móvil: crear ticket → reclamar → avanzar → ver historial/notificación.
Todos deben mostrar la cara/voz y poder responder preguntas del código.

---

## 7. Día de la entrega

**Lleva:** los 3 PC con cargador, router (o acceso a la red del salón), cables, móvil cargado, USB con los 2 WAR, el script SQL y los manuales en PDF.
**Orden de arranque:** 1) PC 1 SQL Server → 2) PC 2 GlassFish/BackendTickets (probar WSDL) → 3) PC 3 GlassFish/FrontendTickets → 4) *Probar conexión* en Configuración → 5) abrir desde el móvil.
**Plan B:** si falla la BD o los servicios, ejecuta `java herramientas/MockBackend.java` (puerto 8081) y en *Configuración* apunta a `http://localhost:8081/BackendTickets` para demostrar la web; explícalo con honestidad.

### Problemas frecuentes
| Síntoma | Causa probable | Solución |
|---|---|---|
| "No se pudo conectar con …/WSTickets" | URL o IP del servidor de servicios incorrecta, firewall | Revisar *Configuración*, abrir puerto 8080, probar el `?wsdl` |
| Un servicio da error de conexión a la BD | IP/puerto JDBC, TCP/IP deshabilitado, firewall 1433 | Pasos 3.3; probar `Test-NetConnection` |
| `WSUsuarios` falla y los demás no | Typo `t rustServerCertificate` en la URL | Aplicar `parches/WSUsuarios.java` |
| Tablero con acciones deshabilitadas | Falta el parche de `WSTickets` (no devuelve ID) | Aplicar `parches/WSTickets.java` |
| El móvil no abre la web | Redes distintas, aislamiento de clientes, firewall del PC 3 | Misma red, desactivar AP isolation, abrir 8080 |
| Tildes raras (Ã³) | Codificación | La web fuerza UTF-8; revisar que el script SQL esté en UTF-8 |
| "Transicion de estado invalida" | Intento de saltar de estado | Es la regla FIFO de la BD: avanzar de uno en uno |
