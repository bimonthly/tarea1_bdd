"""
IIC2413 Bases de Datos - Tarea 1: Torneo de Gaming
Backend: FastAPI + psycopg (v3) + Jinja2
TODAS las consultas a BD son SQL crudo — sin ORM.
"""

import os
from contextlib import contextmanager
from pathlib import Path

import psycopg
from psycopg import errors as pg_errors
from psycopg.rows import dict_row

from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates

# ──────────────────────────────────────────────────────────────
# Conexión a la base de datos
# Lee desde variables de entorno con valores por defecto.
# ──────────────────────────────────────────────────────────────
def _conninfo() -> str:
    return (
        f"host={os.getenv('DB_HOST', 'localhost')} "
        f"port={os.getenv('DB_PORT', '5432')} "
        f"user={os.getenv('DB_USER', 'postgres')} "
        f"password={os.getenv('DB_PASSWORD', 'postgres')} "
        f"dbname={os.getenv('DB_NAME', 'tarea1')} "
        f"client_encoding=UTF8"
    )


@contextmanager
def get_db():
    """Context manager que abre y cierra la conexión automáticamente."""
    conn = psycopg.connect(_conninfo(), row_factory=dict_row, autocommit=True)
    try:
        yield conn
    finally:
        conn.close()


# ──────────────────────────────────────────────────────────────
# FastAPI + Jinja2
# ──────────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).parent
app = FastAPI(title="Gaming Tournaments - IIC2413")
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))


# ──────────────────────────────────────────────────────────────
# RUTA RAÍZ → redirige a /torneos
# ──────────────────────────────────────────────────────────────
@app.get("/", response_class=RedirectResponse)
async def root():
    return RedirectResponse(url="/torneos")


# ──────────────────────────────────────────────────────────────
# 1. PÁGINA DE TORNEOS — listado general
# ──────────────────────────────────────────────────────────────
@app.get("/torneos", response_class=HTMLResponse)
async def torneos(request: Request):
    with get_db() as conn:
        torneos_list = conn.execute("""
            SELECT t.id,
                   t.nombre,
                   t.videojuego,
                   t.fecha_inicio,
                   t.fecha_fin,
                   t.prize_pool_usd,
                   t.max_equipos,
                   COUNT(i.id) AS equipos_inscritos
            FROM torneos t
            LEFT JOIN inscripciones i ON i.torneo_id = t.id
            GROUP BY t.id
            ORDER BY t.fecha_inicio DESC
        """).fetchall()

    return templates.TemplateResponse(request, "torneos.html", {"torneos": torneos_list})


# ──────────────────────────────────────────────────────────────
# 2. PÁGINA DE TORNEOS — detalle de un torneo
#    Muestra: tabla de posiciones (fase grupos), partidas,
#    equipos inscritos y sponsors.
# ──────────────────────────────────────────────────────────────
@app.get("/torneos/{torneo_id}", response_class=HTMLResponse)
async def torneo_detalle(request: Request, torneo_id: int):
    with get_db() as conn:

        # Información básica del torneo
        torneo = conn.execute(
            "SELECT * FROM torneos WHERE id = %s",
            (torneo_id,)
        ).fetchone()

        if not torneo:
            return HTMLResponse("Torneo no encontrado.", status_code=404)

        # Tabla de posiciones — solo fase_grupos
        # Puntuación: 3 pts victoria, 1 empate, 0 derrota
        standings = conn.execute("""
            WITH resultados AS (
                SELECT equipo_a_id AS equipo_id,
                       puntaje_a   AS gf,
                       puntaje_b   AS gc
                FROM partidas
                WHERE torneo_id = %s AND fase = 'fase_grupos'

                UNION ALL

                SELECT equipo_b_id,
                       puntaje_b,
                       puntaje_a
                FROM partidas
                WHERE torneo_id = %s AND fase = 'fase_grupos'
            )
            SELECT e.nombre,
                   COUNT(*)                                                        AS jugadas,
                   SUM(CASE WHEN gf > gc THEN 1 ELSE 0 END)                      AS ganadas,
                   SUM(CASE WHEN gf = gc THEN 1 ELSE 0 END)                      AS empatadas,
                   SUM(CASE WHEN gf < gc THEN 1 ELSE 0 END)                      AS perdidas,
                   SUM(CASE WHEN gf > gc THEN 3
                            WHEN gf = gc THEN 1
                            ELSE 0 END)                                           AS puntos
            FROM resultados r
            JOIN equipos e ON e.id = r.equipo_id
            GROUP BY e.id, e.nombre
            ORDER BY puntos DESC, ganadas DESC
        """, (torneo_id, torneo_id)).fetchall()

        # Todas las partidas del torneo, ordenadas cronológicamente
        partidas = conn.execute("""
            SELECT p.fecha_hora,
                   p.fase,
                   ea.nombre AS equipo_a,
                   p.puntaje_a,
                   eb.nombre AS equipo_b,
                   p.puntaje_b
            FROM partidas p
            JOIN equipos ea ON ea.id = p.equipo_a_id
            JOIN equipos eb ON eb.id = p.equipo_b_id
            WHERE p.torneo_id = %s
            ORDER BY p.fecha_hora
        """, (torneo_id,)).fetchall()

        # Equipos inscritos en el torneo
        equipos = conn.execute("""
            SELECT e.nombre,
                   j.gamertag AS capitan,
                   (SELECT COUNT(*) FROM jugadores WHERE equipo_id = e.id) AS num_jugadores
            FROM inscripciones i
            JOIN equipos   e ON e.id = i.equipo_id
            JOIN jugadores j ON j.id = e.capitan_id
            WHERE i.torneo_id = %s
            ORDER BY e.nombre
        """, (torneo_id,)).fetchall()

        # Sponsors del torneo con monto aportado
        sponsors = conn.execute("""
            SELECT s.nombre,
                   s.industria,
                   st.monto_usd
            FROM sponsors_torneos st
            JOIN sponsors s ON s.id = st.sponsor_id
            WHERE st.torneo_id = %s
            ORDER BY st.monto_usd DESC
        """, (torneo_id,)).fetchall()

    return templates.TemplateResponse(request, "torneo_detalle.html", {
        "torneo":    torneo,
        "standings": standings,
        "partidas":  partidas,
        "equipos":   equipos,
        "sponsors":  sponsors,
    })


# ──────────────────────────────────────────────────────────────
# 3. PÁGINA DE ESTADÍSTICAS
#    a) Ranking jugadores por ratio KOs/Restarts (min 2 partidas)
#    b) Evolución por fase de un equipo (grupos vs eliminatorias)
# ──────────────────────────────────────────────────────────────
@app.get("/estadisticas", response_class=HTMLResponse)
async def estadisticas(
    request: Request,
    torneo_id: int = None,
    equipo_id: int = None,
):
    with get_db() as conn:

        # Lista de torneos para el selector
        torneos_list = conn.execute(
            "SELECT id, nombre FROM torneos ORDER BY nombre"
        ).fetchall()

        torneo_sel = ranking = equipos_list = evolucion = equipo_sel = None

        if torneo_id:
            torneo_sel = conn.execute(
                "SELECT id, nombre FROM torneos WHERE id = %s", (torneo_id,)
            ).fetchone()

            # Ranking: ratio KOs/Restarts, mínimo 2 partidas en el torneo
            # NULLIF(restarts, 0) evita división por cero → NULL = ratio infinito
            # ORDER BY ratio DESC NULLS FIRST: ratio infinito va primero
            ranking = conn.execute("""
                SELECT j.gamertag,
                       e.nombre                                                    AS equipo,
                       SUM(ei.kos)                                                 AS total_kos,
                       SUM(ei.restarts)                                            AS total_restarts,
                       SUM(ei.assists)                                             AS total_assists,
                       COUNT(DISTINCT ei.partida_id)                              AS partidas,
                       ROUND(
                           SUM(ei.kos)::numeric / NULLIF(SUM(ei.restarts), 0),
                       2)                                                          AS ratio
                FROM estadisticas_individuales ei
                JOIN jugadores j ON j.id = ei.jugador_id
                JOIN equipos   e ON e.id = j.equipo_id
                JOIN partidas  p ON p.id = ei.partida_id
                WHERE p.torneo_id = %s
                GROUP BY j.id, j.gamertag, e.nombre
                HAVING COUNT(DISTINCT ei.partida_id) >= 2
                ORDER BY ratio DESC NULLS FIRST
            """, (torneo_id,)).fetchall()

            # Equipos del torneo para el selector de evolución
            equipos_list = conn.execute("""
                SELECT e.id, e.nombre
                FROM inscripciones i
                JOIN equipos e ON e.id = i.equipo_id
                WHERE i.torneo_id = %s
                ORDER BY e.nombre
            """, (torneo_id,)).fetchall()

            if equipo_id:
                equipo_sel = conn.execute(
                    "SELECT id, nombre FROM equipos WHERE id = %s", (equipo_id,)
                ).fetchone()

                # Evolución por fase: promedio de stats por jugador
                # Agrupa en "Fase de Grupos" vs "Fases Eliminatorias" (semifinal + final)
                evolucion = conn.execute("""
                    SELECT
                        CASE WHEN p.fase = 'fase_grupos'
                             THEN 'Fase de Grupos'
                             ELSE 'Fases Eliminatorias'
                        END                                              AS etapa,
                        ROUND(AVG(ei.kos)::numeric,      2)             AS avg_kos,
                        ROUND(AVG(ei.restarts)::numeric, 2)             AS avg_restarts,
                        ROUND(AVG(ei.assists)::numeric,  2)             AS avg_assists,
                        COUNT(DISTINCT ei.partida_id)                   AS partidas
                    FROM estadisticas_individuales ei
                    JOIN partidas  p ON p.id  = ei.partida_id
                    JOIN jugadores j ON j.id  = ei.jugador_id
                    WHERE p.torneo_id = %s
                      AND j.equipo_id = %s
                      AND p.fase IN ('fase_grupos', 'semifinal', 'final')
                    GROUP BY 1
                    ORDER BY 1 DESC
                """, (torneo_id, equipo_id)).fetchall()

    return templates.TemplateResponse(request, "estadisticas.html", {
        "torneos":    torneos_list,
        "torneo_id":  torneo_id,
        "torneo_sel": torneo_sel,
        "ranking":    ranking or [],
        "equipos":    equipos_list or [],
        "equipo_id":  equipo_id,
        "equipo_sel": equipo_sel,
        "evolucion":  evolucion or [],
    })


# ──────────────────────────────────────────────────────────────
# 4. PÁGINA DE BÚSQUEDA
#    Busca jugadores por gamertag o país, equipos por nombre.
#    Usa ILIKE para búsqueda case-insensitive.
# ──────────────────────────────────────────────────────────────
@app.get("/busqueda", response_class=HTMLResponse)
async def busqueda(request: Request, q: str = "", tipo: str = "gamertag"):
    jugadores = []
    equipos_res = []

    if q:
        patron = f"%{q}%"
        with get_db() as conn:

            if tipo == "gamertag":
                jugadores = conn.execute("""
                    SELECT j.gamertag,
                           j.nombre_real,
                           j.pais,
                           j.fecha_nacimiento,
                           e.nombre AS equipo
                    FROM jugadores j
                    JOIN equipos e ON e.id = j.equipo_id
                    WHERE j.gamertag ILIKE %s
                    ORDER BY j.gamertag
                """, (patron,)).fetchall()

            elif tipo == "pais":
                jugadores = conn.execute("""
                    SELECT j.gamertag,
                           j.nombre_real,
                           j.pais,
                           j.fecha_nacimiento,
                           e.nombre AS equipo
                    FROM jugadores j
                    JOIN equipos e ON e.id = j.equipo_id
                    WHERE j.pais ILIKE %s
                    ORDER BY j.pais, j.gamertag
                """, (patron,)).fetchall()

            elif tipo == "equipo":
                equipos_res = conn.execute("""
                    SELECT e.nombre,
                           e.fecha_creacion,
                           j.gamertag                                         AS capitan,
                           COUNT(jug.id)                                      AS num_jugadores
                    FROM equipos e
                    JOIN jugadores j   ON j.id   = e.capitan_id
                    JOIN jugadores jug ON jug.equipo_id = e.id
                    WHERE e.nombre ILIKE %s
                    GROUP BY e.id, e.nombre, e.fecha_creacion, j.gamertag
                    ORDER BY e.nombre
                """, (patron,)).fetchall()

    return templates.TemplateResponse(request, "busqueda.html", {
        "q":       q,
        "tipo":    tipo,
        "jugadores":  jugadores,
        "equipos":    equipos_res,
    })


# ──────────────────────────────────────────────────────────────
# 5. PÁGINA DE SPONSORS
#    Lista sponsors que auspiciaron TODOS los torneos
#    de un videojuego específico, con el monto total aportado.
# ──────────────────────────────────────────────────────────────
@app.get("/sponsors", response_class=HTMLResponse)
async def sponsors_page(request: Request, videojuego: str = ""):
    with get_db() as conn:

        # Obtener videojuegos únicos para el selector
        videojuegos = [
            r["videojuego"]
            for r in conn.execute(
                "SELECT DISTINCT videojuego FROM torneos ORDER BY videojuego"
            ).fetchall()
        ]

        sponsors_list = []
        if videojuego:
            # Sponsors que auspiciaron TODOS los torneos del juego seleccionado
            # HAVING COUNT(DISTINCT t.id) = subquery garantiza la cobertura total
            sponsors_list = conn.execute("""
                SELECT s.nombre,
                       s.industria,
                       SUM(st.monto_usd) AS total_aportado
                FROM sponsors s
                JOIN sponsors_torneos st ON st.sponsor_id = s.id
                JOIN torneos t           ON t.id = st.torneo_id
                WHERE t.videojuego = %s
                GROUP BY s.id, s.nombre, s.industria
                HAVING COUNT(DISTINCT t.id) = (
                    SELECT COUNT(*) FROM torneos WHERE videojuego = %s
                )
                ORDER BY total_aportado DESC
            """, (videojuego, videojuego)).fetchall()

    return templates.TemplateResponse(request, "sponsors.html", {
        "videojuegos": videojuegos,
        "videojuego":  videojuego,
        "sponsors":    sponsors_list,
    })


# ──────────────────────────────────────────────────────────────
# 6. FORMULARIO DE INSCRIPCIÓN (GET)
# ──────────────────────────────────────────────────────────────
@app.get("/inscripcion", response_class=HTMLResponse)
async def inscripcion_get(request: Request):
    with get_db() as conn:
        equipos = conn.execute(
            "SELECT id, nombre FROM equipos ORDER BY nombre"
        ).fetchall()
        torneos = conn.execute(
            "SELECT id, nombre, max_equipos FROM torneos ORDER BY nombre"
        ).fetchall()

    return templates.TemplateResponse(request, "inscripcion.html", {
        "equipos": equipos,
        "torneos": torneos,
        "mensaje": None,
        "error":   False,
    })


# ──────────────────────────────────────────────────────────────
# 6. FORMULARIO DE INSCRIPCIÓN (POST)
#    Intenta insertar la inscripción.
#    El trigger trg_cupo_torneo en la BD rechaza si está lleno.
# ──────────────────────────────────────────────────────────────
@app.post("/inscripcion", response_class=HTMLResponse)
async def inscripcion_post(
    request:   Request,
    equipo_id: int = Form(...),
    torneo_id: int = Form(...),
):
    mensaje = None
    error   = False

    try:
        with get_db() as conn:
            conn.execute(
                """
                INSERT INTO inscripciones (equipo_id, torneo_id, fecha_inscripcion)
                VALUES (%s, %s, CURRENT_DATE)
                """,
                (equipo_id, torneo_id),
            )
        mensaje = "¡Equipo inscrito exitosamente en el torneo!"

    except pg_errors.RaiseException:
        # El trigger trg_cupo_torneo levanta esta excepción cuando el torneo está lleno
        error   = True
        mensaje = "Inscripción rechazada: el torneo ya alcanzó su número máximo de equipos."

    except pg_errors.UniqueViolation:
        # Constraint UNIQUE (equipo_id, torneo_id) en la tabla inscripciones
        error   = True
        mensaje = "Error: ese equipo ya está inscrito en ese torneo."

    except Exception as e:
        error   = True
        mensaje = f"Error inesperado: {str(e)}"

    # Recargar listas para re-renderizar el formulario
    with get_db() as conn:
        equipos = conn.execute(
            "SELECT id, nombre FROM equipos ORDER BY nombre"
        ).fetchall()
        torneos = conn.execute(
            "SELECT id, nombre, max_equipos FROM torneos ORDER BY nombre"
        ).fetchall()

    return templates.TemplateResponse(request, "inscripcion.html", {
        "equipos": equipos,
        "torneos": torneos,
        "mensaje": mensaje,
        "error":   error,
    })
