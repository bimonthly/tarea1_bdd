-- ============================================================
-- IIC2413 Bases de Datos - Tarea 1: Torneo de Gaming
-- schema.sql - DDL completo para PostgreSQL 14+
-- ============================================================

-- Limpiar si ya existen (orden inverso a dependencias)
DROP TABLE IF EXISTS estadisticas_individuales CASCADE;
DROP TABLE IF EXISTS partidas CASCADE;
DROP TABLE IF EXISTS inscripciones CASCADE;
DROP TABLE IF EXISTS sponsors_torneos CASCADE;
DROP TABLE IF EXISTS sponsors CASCADE;
DROP TABLE IF EXISTS jugadores CASCADE;
DROP TABLE IF EXISTS equipos CASCADE;
DROP TABLE IF EXISTS torneos CASCADE;

-- ============================================================
-- TORNEOS
-- ============================================================
CREATE TABLE torneos (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    videojuego      VARCHAR(100) NOT NULL,
    fecha_inicio    DATE         NOT NULL,
    fecha_fin       DATE         NOT NULL,
    prize_pool_usd  NUMERIC(12,2) NOT NULL CHECK (prize_pool_usd >= 0),
    max_equipos     INTEGER      NOT NULL DEFAULT 8 CHECK (max_equipos = 8),
    CONSTRAINT torneos_fechas_check CHECK (fecha_fin >= fecha_inicio)
);

-- ============================================================
-- EQUIPOS
-- ============================================================
CREATE TABLE equipos (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    fecha_creacion  DATE         NOT NULL,
    -- capitan_id se agrega luego para evitar dependencia circular
    capitan_id      INTEGER      -- FK definida abajo
);

-- ============================================================
-- JUGADORES
-- ============================================================
CREATE TABLE jugadores (
    id              SERIAL PRIMARY KEY,
    gamertag        VARCHAR(50)  NOT NULL UNIQUE,
    nombre_real     VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    fecha_nacimiento DATE        NOT NULL,
    pais            VARCHAR(60)  NOT NULL,
    equipo_id       INTEGER      NOT NULL,
    CONSTRAINT fk_jugadores_equipo FOREIGN KEY (equipo_id)
        REFERENCES equipos (id) ON DELETE RESTRICT
);

-- Ahora sí agregamos la FK de capitán (jugador debe existir primero)
ALTER TABLE equipos
    ADD CONSTRAINT fk_equipos_capitan FOREIGN KEY (capitan_id)
        REFERENCES jugadores (id) ON DELETE RESTRICT;

-- El capitán debe pertenecer al equipo (CHECK no alcanza para esto,
-- se valida a nivel de aplicación y con trigger)
CREATE OR REPLACE FUNCTION check_capitan_en_equipo()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.capitan_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM jugadores
            WHERE id = NEW.capitan_id AND equipo_id = NEW.id
        ) THEN
            RAISE EXCEPTION 'El capitán (id=%) no pertenece al equipo (id=%)',
                NEW.capitan_id, NEW.id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_capitan_en_equipo
BEFORE INSERT OR UPDATE ON equipos
FOR EACH ROW EXECUTE FUNCTION check_capitan_en_equipo();

-- ============================================================
-- SPONSORS
-- ============================================================
CREATE TABLE sponsors (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    industria   VARCHAR(80)  NOT NULL
);

-- ============================================================
-- SPONSORS <-> TORNEOS  (monto por torneo)
-- ============================================================
CREATE TABLE sponsors_torneos (
    sponsor_id  INTEGER NOT NULL,
    torneo_id   INTEGER NOT NULL,
    monto_usd   NUMERIC(12,2) NOT NULL CHECK (monto_usd >= 0),
    PRIMARY KEY (sponsor_id, torneo_id),
    CONSTRAINT fk_st_sponsor FOREIGN KEY (sponsor_id) REFERENCES sponsors (id) ON DELETE CASCADE,
    CONSTRAINT fk_st_torneo  FOREIGN KEY (torneo_id)  REFERENCES torneos (id)  ON DELETE CASCADE
);

-- ============================================================
-- INSCRIPCIONES  (equipo <-> torneo)
-- ============================================================
CREATE TABLE inscripciones (
    id          SERIAL PRIMARY KEY,
    equipo_id   INTEGER NOT NULL,
    torneo_id   INTEGER NOT NULL,
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (equipo_id, torneo_id),
    CONSTRAINT fk_ins_equipo FOREIGN KEY (equipo_id) REFERENCES equipos (id) ON DELETE RESTRICT,
    CONSTRAINT fk_ins_torneo FOREIGN KEY (torneo_id) REFERENCES torneos (id) ON DELETE RESTRICT
);

-- Trigger: bloquear inscripción si torneo ya alcanzó max_equipos
CREATE OR REPLACE FUNCTION check_cupo_torneo()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    inscritos   INTEGER;
    max_eq      INTEGER;
BEGIN
    SELECT COUNT(*) INTO inscritos
    FROM inscripciones
    WHERE torneo_id = NEW.torneo_id;

    SELECT max_equipos INTO max_eq
    FROM torneos
    WHERE id = NEW.torneo_id;

    IF inscritos >= max_eq THEN
        RAISE EXCEPTION 'El torneo (id=%) ya alcanzó su límite de % equipos.',
            NEW.torneo_id, max_eq;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_cupo_torneo
BEFORE INSERT ON inscripciones
FOR EACH ROW EXECUTE FUNCTION check_cupo_torneo();

-- ============================================================
-- PARTIDAS
-- ============================================================
CREATE TABLE partidas (
    id              SERIAL PRIMARY KEY,
    torneo_id       INTEGER      NOT NULL,
    equipo_a_id     INTEGER      NOT NULL,
    equipo_b_id     INTEGER      NOT NULL,
    fecha_hora      TIMESTAMP    NOT NULL,
    puntaje_a       INTEGER      CHECK (puntaje_a >= 0),
    puntaje_b       INTEGER      CHECK (puntaje_b >= 0),
    fase            VARCHAR(20)  NOT NULL
                        CHECK (fase IN ('fase_grupos','cuartos','semifinal','final')),
    CONSTRAINT fk_par_torneo   FOREIGN KEY (torneo_id)   REFERENCES torneos (id) ON DELETE RESTRICT,
    CONSTRAINT fk_par_equipo_a FOREIGN KEY (equipo_a_id) REFERENCES equipos (id) ON DELETE RESTRICT,
    CONSTRAINT fk_par_equipo_b FOREIGN KEY (equipo_b_id) REFERENCES equipos (id) ON DELETE RESTRICT,
    CONSTRAINT partidas_equipos_distintos CHECK (equipo_a_id <> equipo_b_id)
);

-- ============================================================
-- ESTADÍSTICAS INDIVIDUALES  (por jugador por partida)
-- ============================================================
CREATE TABLE estadisticas_individuales (
    id          SERIAL PRIMARY KEY,
    partida_id  INTEGER NOT NULL,
    jugador_id  INTEGER NOT NULL,
    kos         INTEGER NOT NULL DEFAULT 0 CHECK (kos >= 0),
    restarts    INTEGER NOT NULL DEFAULT 0 CHECK (restarts >= 0),
    assists     INTEGER NOT NULL DEFAULT 0 CHECK (assists >= 0),
    UNIQUE (partida_id, jugador_id),
    CONSTRAINT fk_ei_partida FOREIGN KEY (partida_id) REFERENCES partidas (id) ON DELETE CASCADE,
    CONSTRAINT fk_ei_jugador FOREIGN KEY (jugador_id) REFERENCES jugadores (id) ON DELETE RESTRICT
);
