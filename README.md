# Tarea 1 — Torneo de Gaming
### IIC2413 Bases de Datos · Primer Semestre 2026 · PUC Chile

---

## Integrantes

| Nombre | Número de Alumno |
|--------|-----------------|
| Pablo Arturo Rouliez Lagos | 25663070 |
| Daniel Raimundo Aboitiz Halabi | 24642681 |
| Sebastián Ignacio Cabrera Yañez | 25663984 |

---

## Requisitos previos

- PostgreSQL 14 o superior instalado y corriendo en `localhost:5432`
- Python 3.10 o superior

---

## Levantar la aplicación (máximo 5 comandos)

Ejecutar desde la raíz del proyecto (`tarea1 BDD/`):

```powershell
# 1. Crear la base de datos
& "C:\Program Files\PostgreSQL\18\bin\psql" -U postgres -c "CREATE DATABASE tarea1;"

# 2. Crear las tablas (DDL)
& "C:\Program Files\PostgreSQL\18\bin\psql" -U postgres -d tarea1 -f schema.sql

# 3. Cargar los datos sintéticos
& "C:\Program Files\PostgreSQL\18\bin\psql" -U postgres -d tarea1 -f data.sql

# 4. Instalar dependencias Python
pip install -r app\requirements.txt

# 5. Levantar el servidor web
cd app; python -m uvicorn main:app --reload
```

La aplicación quedará disponible en: **http://localhost:8000**

> **Nota:** Los comandos anteriores usan la ruta de PostgreSQL 18 en Windows.
> Ajusta según tu sistema operativo y versión instalada:
> - **Windows con otra versión:** reemplaza `18` por tu versión (ej. `16`, `17`)
> - **Mac/Linux:** `psql` debería estar en el PATH directamente, usa solo `psql -U postgres ...`

---

## Variables de entorno

La aplicación lee la configuración de conexión desde variables de entorno.
Si no se definen, usa los siguientes **valores por defecto**:

| Variable      | Default       | Descripción              |
|---------------|---------------|--------------------------|
| `DB_HOST`     | `localhost`   | Host de PostgreSQL       |
| `DB_PORT`     | `5432`        | Puerto de PostgreSQL     |
| `DB_USER`     | `postgres`    | Usuario de la BD         |
| `DB_PASSWORD` | `postgres`    | Contraseña del usuario   |
| `DB_NAME`     | `tarea1`      | Nombre de la base de datos |

Para usar valores distintos, exportar antes de levantar la app:

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="5432"
$env:DB_USER="postgres"
$env:DB_PASSWORD="mipassword"
$env:DB_NAME="tarea1"
cd app; python -m uvicorn main:app --reload
```

---

## Estructura del proyecto

```
tarea1 BDD/
├── schema.sql          # DDL: creación de tablas, triggers y constraints
├── data.sql            # Datos sintéticos (50 jugadores, 24 partidas, etc.)
├── README.md           # Este archivo
├── informe.pdf         # Parte A: análisis crítico del esquema LLM
├── llm-log.pdf         # Registro de uso de LLMs
└── app/
    ├── main.py         # Backend FastAPI con todas las rutas y SQL crudo
    ├── requirements.txt
    └── templates/
        ├── base.html
        ├── torneos.html
        ├── torneo_detalle.html
        ├── estadisticas.html
        ├── busqueda.html
        ├── sponsors.html
        └── inscripcion.html
```

---

## Páginas de la aplicación

| URL | Descripción |
|-----|-------------|
| `/torneos` | Listado de todos los torneos |
| `/torneos/{id}` | Detalle: tabla de posiciones, partidas, equipos y sponsors |
| `/estadisticas` | Ranking KOs/Restarts y evolución por fase de un equipo |
| `/busqueda` | Búsqueda de jugadores (gamertag / país) y equipos (nombre) |
| `/sponsors` | Sponsors que auspiciaron todos los torneos de un videojuego |
| `/inscripcion` | Formulario para inscribir un equipo en un torneo |

---

## Stack tecnológico

- **Base de datos:** PostgreSQL 14+
- **Backend:** Python · FastAPI · psycopg (v3)
- **Vistas:** Jinja2 (templates HTML renderizados desde el servidor)
- **Consultas:** SQL crudo explícito — sin ORM de ningún tipo
