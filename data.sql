-- ============================================================
-- IIC2413 Bases de Datos - Tarea 1: Torneo de Gaming
-- data.sql - Datos sintéticos coherentes para PostgreSQL 14+
-- ============================================================
\encoding UTF8

-- ============================================================
-- 1. TORNEOS  (3 torneos; T1 tiene cupo completo de 8 equipos)
-- ============================================================
INSERT INTO torneos (id, nombre, videojuego, fecha_inicio, fecha_fin, prize_pool_usd, max_equipos) VALUES
(1, 'Liga Mundial Valorant 2026',      'Valorant',       '2026-01-10', '2026-02-28', 100000.00, 8),
(2, 'Torneo Regional League of Legends', 'League of Legends', '2026-03-01', '2026-05-31',  40000.00, 8),
(3, 'Copa Latinoamérica CS2 2026',     'Counter-Strike 2','2026-04-01', '2026-06-30',  25000.00, 8);

SELECT setval('torneos_id_seq', 3);

-- ============================================================
-- 2. EQUIPOS  (10 equipos; capitan_id se actualiza tras insertar jugadores)
-- ============================================================
INSERT INTO equipos (id, nombre, fecha_creacion, capitan_id) VALUES
( 1, 'NightOwls Gaming',  '2023-06-01', NULL),
( 2, 'Storm Riders',      '2023-07-15', NULL),
( 3, 'Pixel Warriors',    '2023-08-20', NULL),
( 4, 'Iron Wolves',       '2023-09-10', NULL),
( 5, 'Cyber Dragons',     '2023-10-05', NULL),
( 6, 'Shadow Force',      '2023-11-12', NULL),
( 7, 'Neon Vipers',       '2024-01-08', NULL),
( 8, 'Frost Giants',      '2024-02-14', NULL),
( 9, 'Thunder Hawks',     '2024-03-22', NULL),
(10, 'Solar Flares',      '2024-04-30', NULL);

SELECT setval('equipos_id_seq', 10);

-- ============================================================
-- 3. JUGADORES  (5 por equipo = 50 jugadores)
-- ============================================================
INSERT INTO jugadores (id, gamertag, nombre_real, email, fecha_nacimiento, pais, equipo_id) VALUES
-- Equipo 1: NightOwls Gaming
( 1, 'NightHawk',      'Carlos Mendoza',    'carlos@nightowls.gg',  '2001-03-15', 'Chile',     1),
( 2, 'ShadowByte',     'Ana García',        'ana@nightowls.gg',     '2000-07-22', 'México',    1),
( 3, 'VoidRunner',     'Luis Torres',       'luis@nightowls.gg',    '2002-01-10', 'Chile',     1),
( 4, 'GhostFrame',     'María López',       'maria@nightowls.gg',   '1999-11-30', 'Argentina', 1),
( 5, 'NullPointer',    'Diego Rojas',       'diego@nightowls.gg',   '2003-05-18', 'Chile',     1),
-- Equipo 2: Storm Riders
( 6, 'StormBreaker',   'Matías Pérez',      'matias@storm.gg',      '2001-08-12', 'Chile',     2),
( 7, 'ThunderFist',    'Valentina Cruz',    'val@storm.gg',         '2000-04-25', 'Colombia',  2),
( 8, 'RainDancer',     'Andrés Muñoz',      'andres@storm.gg',      '2002-09-03', 'Perú',      2),
( 9, 'LightningBolt',  'Camila Soto',       'camila@storm.gg',      '1999-12-15', 'Chile',     2),
(10, 'CloudSurfer',    'Felipe Vega',       'felipe@storm.gg',      '2003-02-28', 'Uruguay',   2),
-- Equipo 3: Pixel Warriors
(11, 'PixelKnight',    'Sofía Ramírez',     'sofia@pixel.gg',       '2001-06-20', 'Chile',     3),
(12, 'BitCrusher',     'Tomás Herrera',     'tomas@pixel.gg',       '2000-10-08', 'México',    3),
(13, 'VoxelMage',      'Isabela Santos',    'isa@pixel.gg',         '2002-03-14', 'Brasil',    3),
(14, 'RenderBlade',    'Javier Morales',    'javier@pixel.gg',      '1999-07-29', 'Argentina', 3),
(15, 'FrameRate',      'Natalia Díaz',      'natalia@pixel.gg',     '2003-08-11', 'Chile',     3),
-- Equipo 4: Iron Wolves
(16, 'IronFang',       'Ricardo Flores',    'ricardo@ironwolves.gg','2001-01-05', 'Chile',     4),
(17, 'SteelClaw',      'Gabriela Torres',   'gabi@ironwolves.gg',   '2000-09-17', 'Venezuela', 4),
(18, 'MetalHowl',      'Sebastián Reyes',   'sebas@ironwolves.gg',  '2002-05-23', 'Chile',     4),
(19, 'ForgeWolf',      'Amanda Castro',     'amanda@ironwolves.gg', '1999-04-12', 'Colombia',  4),
(20, 'RustBite',       'Emilio Vargas',     'emilio@ironwolves.gg', '2003-11-07', 'Perú',      4),
-- Equipo 5: Cyber Dragons
(21, 'CyberFang',      'Alejandro Jiménez', 'alex@cyber.gg',        '2001-02-18', 'Chile',     5),
(22, 'DataBreath',     'Patricia Ortega',   'pat@cyber.gg',         '2000-06-30', 'México',    5),
(23, 'QuantumClaw',    'Jorge Medina',      'jorge@cyber.gg',       '2002-10-25', 'Argentina', 5),
(24, 'NanoScale',      'Luisa Fernández',   'luisa@cyber.gg',       '1999-03-08', 'Brasil',    5),
(25, 'ByteFire',       'Nicolás Guerrero',  'nico@cyber.gg',        '2003-07-15', 'Chile',     5),
-- Equipo 6: Shadow Force
(26, 'ShadowStrike',   'Renata Blanco',     'renata@shadowforce.gg','2001-09-22', 'Chile',     6),
(27, 'DarkMatter',     'Eduardo Silva',     'edu@shadowforce.gg',   '2000-01-14', 'Uruguay',   6),
(28, 'VoidBlade',      'Francisca Moreno',  'fran@shadowforce.gg',  '2002-07-30', 'Chile',     6),
(29, 'PhantomRush',    'Cristóbal Acosta',  'cristo@shadowforce.gg','1999-10-19', 'Argentina', 6),
(30, 'EclipseKick',    'Daniela Ruiz',      'dani@shadowforce.gg',  '2003-04-03', 'Colombia',  6),
-- Equipo 7: Neon Vipers
(31, 'NeonFang',       'Benjamín Salinas',  'ben@neonvipers.gg',    '2001-11-28', 'Chile',     7),
(32, 'GlowStrike',     'Catalina Espinoza', 'cata@neonvipers.gg',   '2000-03-16', 'Perú',      7),
(33, 'LaserCoil',      'Rodrigo Navarro',   'rod@neonvipers.gg',    '2002-08-04', 'Chile',     7),
(34, 'PrismaticBite',  'Fernanda Ríos',     'fer@neonvipers.gg',    '1999-06-21', 'México',    7),
(35, 'HoloSlash',      'Gonzalo Parra',     'gonza@neonvipers.gg',  '2003-12-09', 'Chile',     7),
-- Equipo 8: Frost Giants
(36, 'IceCrusher',     'Sebastián Lagos',   'seblag@frost.gg',      '2001-04-07', 'Chile',     8),
(37, 'FrostBite',      'Constanza Fuentes', 'cons@frost.gg',        '2000-08-23', 'Argentina', 8),
(38, 'BlizzardAxe',    'Álvaro Castillo',   'alvaro@frost.gg',      '2002-02-11', 'Chile',     8),
(39, 'GlacierSmash',   'Tamara Olivares',   'tamara@frost.gg',      '1999-09-04', 'Venezuela', 8),
(40, 'ArcticRoar',     'Pablo Guzmán',      'pablo@frost.gg',       '2003-06-18', 'Chile',     8),
-- Equipo 9: Thunder Hawks
(41, 'ThunderWing',    'Isidora Carrasco',  'isi@thunder.gg',       '2001-07-14', 'Chile',     9),
(42, 'StormTalon',     'Máximo Bravo',      'maxi@thunder.gg',      '2000-11-02', 'Colombia',  9),
(43, 'LightningFeather','Antonia Vidal',    'anto@thunder.gg',      '2002-04-19', 'Chile',     9),
(44, 'ThunderEye',     'Francisco Donoso',  'fran2@thunder.gg',     '1999-01-27', 'Perú',      9),
(45, 'SkyStrike',      'Valentín Cortés',   'valen@thunder.gg',     '2003-09-30', 'Chile',     9),
-- Equipo 10: Solar Flares
(46, 'SolarFlame',     'Rocío Tapia',       'rocio@solar.gg',       '2001-05-09', 'Chile',    10),
(47, 'PlasmaWave',     'Ignacio Vera',      'igna@solar.gg',        '2000-12-21', 'Argentina',10),
(48, 'FusionBurst',    'Verónica Aguilar',  'vero@solar.gg',        '2002-06-15', 'Chile',    10),
(49, 'StarBlazer',     'Mateo Contreras',   'mateo@solar.gg',       '1999-08-13', 'México',   10),
(50, 'CoronaStrike',   'Simón Alvarado',    'simon@solar.gg',       '2003-10-27', 'Chile',    10);

SELECT setval('jugadores_id_seq', 50);

-- Asignar capitanes (primer jugador de cada equipo)
UPDATE equipos SET capitan_id =  1 WHERE id = 1;
UPDATE equipos SET capitan_id =  6 WHERE id = 2;
UPDATE equipos SET capitan_id = 11 WHERE id = 3;
UPDATE equipos SET capitan_id = 16 WHERE id = 4;
UPDATE equipos SET capitan_id = 21 WHERE id = 5;
UPDATE equipos SET capitan_id = 26 WHERE id = 6;
UPDATE equipos SET capitan_id = 31 WHERE id = 7;
UPDATE equipos SET capitan_id = 36 WHERE id = 8;
UPDATE equipos SET capitan_id = 41 WHERE id = 9;
UPDATE equipos SET capitan_id = 46 WHERE id = 10;

-- ============================================================
-- 4. SPONSORS  (5)
-- ============================================================
INSERT INTO sponsors (id, nombre, industria) VALUES
(1, 'TechNova Corp',     'Tecnología'),
(2, 'RedBull Gaming',    'Bebidas'),
(3, 'HyperX Gear',       'Periféricos'),
(4, 'Puma Esports',      'Ropa'),
(5, 'AWS Cloud Play',    'Tecnología');

SELECT setval('sponsors_id_seq', 5);

-- Asociación sponsor-torneo con montos
INSERT INTO sponsors_torneos (sponsor_id, torneo_id, monto_usd) VALUES
(1, 1, 30000.00),
(2, 1, 20000.00),
(3, 1, 15000.00),
(4, 1, 10000.00),
(5, 1,  8000.00),
(1, 2, 12000.00),
(3, 2,  8000.00),
(5, 2,  6000.00),
(2, 3,  7000.00),
(4, 3,  5000.00);

-- ============================================================
-- 5. INSCRIPCIONES
-- T1 (max_equipos=8): equipos 1-8   → torneo lleno (terminado)
-- T2 (max_equipos=8): equipos 1,2,3,4,5,6,9,10 → torneo lleno (en curso)
--    Grupo A (1,3,9,10): round-robin completado
--    Grupo B (2,4,5,6): partidas pendientes
-- T3 (max_equipos=8): equipos 1,2,3,5,7 → torneo NO lleno (en curso, 5/8)
-- ============================================================
INSERT INTO inscripciones (equipo_id, torneo_id, fecha_inscripcion) VALUES
-- Torneo 1 (lleno)
(1, 1, '2026-01-05'), (2, 1, '2026-01-05'), (3, 1, '2026-01-06'),
(4, 1, '2026-01-06'), (5, 1, '2026-01-07'), (6, 1, '2026-01-07'),
(7, 1, '2026-01-08'), (8, 1, '2026-01-08'),
-- Torneo 2 (lleno: 8 equipos)
(1, 2, '2026-02-25'), (3, 2, '2026-02-25'),
(9, 2, '2026-02-26'), (10, 2, '2026-02-26'),
(2, 2, '2026-02-27'), (4, 2, '2026-02-27'),
(5, 2, '2026-02-28'), (6, 2, '2026-02-28'),
-- Torneo 3 (no lleno: 5/8 equipos)
(2, 3, '2026-03-25'), (5, 3, '2026-03-25'), (7, 3, '2026-03-26'),
(1, 3, '2026-03-26'), (3, 3, '2026-03-27');

-- ============================================================
-- INTENTO DE INSCRIPCIÓN FALLIDA
-- Equipo 9 intenta inscribirse en Torneo 1 (ya lleno con 8 equipos)
-- El trigger trg_cupo_torneo debe rechazarlo.
-- ============================================================
DO $$
BEGIN
    INSERT INTO inscripciones (equipo_id, torneo_id, fecha_inscripcion)
    VALUES (9, 1, '2026-01-09');
    RAISE NOTICE 'ERROR: la inscripción no debería haberse completado.';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'INSCRIPCIÓN RECHAZADA (correcto): %', SQLERRM;
END;
$$;

-- ============================================================
-- 6. PARTIDAS
-- T1: Grupo A (eq 1-4, 6 partidas) + Grupo B (eq 5-8, 6 partidas)
--     + 2 Semifinales + 1 Final  =  15 partidas  (TERMINADO)
-- T2: Grupo A (eq 1,3,9,10, 6 partidas) + Grupo B (eq 2,4,5,6, 6 partidas)
--     = 12 partidas de fase de grupos; semis y final pendientes (EN CURSO)
-- T3: Sin partidas (torneo en fase de inscripción, NO LLENO)
-- ============================================================
INSERT INTO partidas (id, torneo_id, equipo_a_id, equipo_b_id, fecha_hora, puntaje_a, puntaje_b, fase) VALUES
-- Torneo 1 – Grupo A
( 1, 1, 1, 2, '2026-01-15 15:00', 2, 1, 'fase_grupos'),
( 2, 1, 1, 3, '2026-01-15 17:00', 3, 0, 'fase_grupos'),
( 3, 1, 1, 4, '2026-01-16 15:00', 2, 0, 'fase_grupos'),
( 4, 1, 2, 3, '2026-01-16 17:00', 2, 1, 'fase_grupos'),
( 5, 1, 2, 4, '2026-01-17 15:00', 3, 1, 'fase_grupos'),
( 6, 1, 3, 4, '2026-01-17 17:00', 1, 0, 'fase_grupos'),
-- Torneo 1 – Grupo B
( 7, 1, 5, 6, '2026-01-22 15:00', 2, 1, 'fase_grupos'),
( 8, 1, 5, 7, '2026-01-22 17:00', 3, 1, 'fase_grupos'),
( 9, 1, 5, 8, '2026-01-23 15:00', 2, 0, 'fase_grupos'),
(10, 1, 6, 7, '2026-01-23 17:00', 2, 0, 'fase_grupos'),
(11, 1, 6, 8, '2026-01-24 15:00', 1, 0, 'fase_grupos'),
(12, 1, 7, 8, '2026-01-24 17:00', 2, 1, 'fase_grupos'),
-- Torneo 1 – Semifinales (1º GrupoA vs 2º GrupoB, 1º GrupoB vs 2º GrupoA)
(13, 1, 1, 6, '2026-02-10 15:00', 2, 1, 'semifinal'),
(14, 1, 5, 2, '2026-02-10 18:00', 2, 1, 'semifinal'),
-- Torneo 1 – Final
(15, 1, 1, 5, '2026-02-28 17:00', 3, 2, 'final'),
-- Torneo 2 – Grupo A (equipos 1,3,9,10)
(16, 2,  1,  3, '2026-03-05 15:00', 2, 0, 'fase_grupos'),
(17, 2,  1,  9, '2026-03-05 17:00', 3, 1, 'fase_grupos'),
(18, 2,  1, 10, '2026-03-07 15:00', 2, 1, 'fase_grupos'),
(19, 2,  3,  9, '2026-03-07 17:00', 1, 0, 'fase_grupos'),
(20, 2,  3, 10, '2026-03-10 15:00', 2, 2, 'fase_grupos'),
(21, 2,  9, 10, '2026-03-10 17:00', 1, 2, 'fase_grupos'),
-- Torneo 2 – Grupo B (equipos 2,4,5,6)
(25, 2,  2,  4, '2026-03-12 15:00', 2, 1, 'fase_grupos'),
(26, 2,  2,  5, '2026-03-12 17:00', 1, 2, 'fase_grupos'),
(27, 2,  2,  6, '2026-03-13 15:00', 3, 1, 'fase_grupos'),
(28, 2,  4,  5, '2026-03-13 17:00', 0, 2, 'fase_grupos'),
(29, 2,  4,  6, '2026-03-14 15:00', 1, 1, 'fase_grupos'),
(30, 2,  5,  6, '2026-03-14 17:00', 2, 0, 'fase_grupos');

SELECT setval('partidas_id_seq', 30);

-- ============================================================
-- 7. ESTADÍSTICAS INDIVIDUALES  (kos, restarts, assists)
-- Cubre los 10 jugadores participantes en cada una de las 24 partidas
-- ============================================================
INSERT INTO estadisticas_individuales (partida_id, jugador_id, kos, restarts, assists) VALUES
-- Partida 1 (T1 GrupoA: NightOwls vs StormRiders, 2-1)
(1, 1,6,1,4),(1, 2,5,2,3),(1, 3,4,1,2),(1, 4,3,2,3),(1, 5,5,0,2),
(1, 6,3,3,2),(1, 7,4,2,1),(1, 8,2,3,2),(1, 9,3,2,1),(1,10,2,2,2),
-- Partida 2 (T1 GrupoA: NightOwls vs PixelWarriors, 3-0)
(2, 1,7,1,3),(2, 2,5,1,4),(2, 3,6,0,3),(2, 4,4,1,2),(2, 5,6,1,2),
(2,11,2,4,1),(2,12,3,3,2),(2,13,1,4,1),(2,14,2,3,2),(2,15,2,4,1),
-- Partida 3 (T1 GrupoA: NightOwls vs IronWolves, 2-0)
(3, 1,5,0,4),(3, 2,4,2,3),(3, 3,5,1,2),(3, 4,3,1,3),(3, 5,4,1,2),
(3,16,2,4,1),(3,17,3,3,1),(3,18,1,3,2),(3,19,2,4,0),(3,20,1,3,1),
-- Partida 4 (T1 GrupoA: StormRiders vs PixelWarriors, 2-1)
(4, 6,5,1,3),(4, 7,4,2,2),(4, 8,5,1,2),(4, 9,3,1,3),(4,10,4,0,2),
(4,11,3,3,2),(4,12,2,3,1),(4,13,3,2,2),(4,14,2,3,1),(4,15,1,3,2),
-- Partida 5 (T1 GrupoA: StormRiders vs IronWolves, 3-1)
(5, 6,6,1,3),(5, 7,5,1,4),(5, 8,4,2,2),(5, 9,5,0,3),(5,10,4,1,2),
(5,16,2,3,2),(5,17,3,2,1),(5,18,2,4,1),(5,19,1,3,1),(5,20,2,3,2),
-- Partida 6 (T1 GrupoA: PixelWarriors vs IronWolves, 1-0)
(6,11,4,2,3),(6,12,3,1,2),(6,13,4,2,2),(6,14,3,1,3),(6,15,3,2,2),
(6,16,3,3,1),(6,17,2,2,2),(6,18,2,3,1),(6,19,3,3,1),(6,20,1,3,2),
-- Partida 7 (T1 GrupoB: CyberDragons vs ShadowForce, 2-1)
(7,21,6,1,3),(7,22,5,2,2),(7,23,4,1,3),(7,24,5,0,2),(7,25,4,2,2),
(7,26,3,3,2),(7,27,4,2,1),(7,28,3,3,2),(7,29,2,2,2),(7,30,2,3,1),
-- Partida 8 (T1 GrupoB: CyberDragons vs NeonVipers, 3-1)
(8,21,7,1,3),(8,22,5,1,4),(8,23,6,1,2),(8,24,4,2,3),(8,25,5,0,2),
(8,31,3,3,1),(8,32,2,4,2),(8,33,3,3,1),(8,34,2,4,2),(8,35,1,3,1),
-- Partida 9 (T1 GrupoB: CyberDragons vs FrostGiants, 2-0)
(9,21,5,0,4),(9,22,4,1,3),(9,23,5,1,2),(9,24,4,1,3),(9,25,6,0,2),
(9,36,2,4,1),(9,37,1,3,2),(9,38,2,4,1),(9,39,1,3,1),(9,40,2,3,2),
-- Partida 10 (T1 GrupoB: ShadowForce vs NeonVipers, 2-0)
(10,26,5,1,3),(10,27,4,2,2),(10,28,5,1,3),(10,29,3,1,2),(10,30,4,1,2),
(10,31,2,3,2),(10,32,3,3,1),(10,33,2,4,1),(10,34,1,3,2),(10,35,2,3,1),
-- Partida 11 (T1 GrupoB: ShadowForce vs FrostGiants, 1-0)
(11,26,4,1,3),(11,27,3,2,2),(11,28,4,1,2),(11,29,3,2,3),(11,30,4,0,2),
(11,36,2,4,1),(11,37,1,3,1),(11,38,2,4,2),(11,39,1,3,1),(11,40,2,3,1),
-- Partida 12 (T1 GrupoB: NeonVipers vs FrostGiants, 2-1)
(12,31,5,2,3),(12,32,4,1,2),(12,33,5,1,3),(12,34,3,2,2),(12,35,4,2,2),
(12,36,3,3,2),(12,37,2,3,1),(12,38,3,3,2),(12,39,2,4,1),(12,40,1,3,2),
-- Partida 13 (T1 Semifinal: NightOwls vs ShadowForce, 2-1)
(13, 1,7,1,4),(13, 2,6,2,3),(13, 3,5,1,3),(13, 4,4,2,2),(13, 5,6,1,2),
(13,26,4,3,2),(13,27,3,3,2),(13,28,4,2,1),(13,29,3,3,2),(13,30,2,3,1),
-- Partida 14 (T1 Semifinal: CyberDragons vs StormRiders, 2-1)
(14,21,7,1,3),(14,22,6,2,3),(14,23,5,1,2),(14,24,6,0,3),(14,25,5,1,2),
(14, 6,4,3,2),(14, 7,3,3,2),(14, 8,4,2,1),(14, 9,3,3,2),(14,10,2,3,1),
-- Partida 15 (T1 Final: NightOwls vs CyberDragons, 3-2)
(15, 1,8,1,4),(15, 2,7,2,3),(15, 3,6,1,3),(15, 4,5,2,3),(15, 5,7,1,2),
(15,21,6,2,3),(15,22,5,2,3),(15,23,6,1,2),(15,24,5,2,2),(15,25,7,1,2),
-- Partida 16 (T2: NightOwls vs PixelWarriors, 2-0)
(16, 1,6,1,3),(16, 2,5,1,3),(16, 3,4,2,2),(16, 4,4,1,2),(16, 5,5,0,2),
(16,11,2,4,1),(16,12,3,3,2),(16,13,2,4,1),(16,14,1,3,1),(16,15,2,3,2),
-- Partida 17 (T2: NightOwls vs ThunderHawks, 3-1)
(17, 1,7,1,3),(17, 2,5,2,3),(17, 3,6,1,2),(17, 4,4,1,3),(17, 5,5,1,2),
(17,41,3,3,2),(17,42,2,3,1),(17,43,3,2,2),(17,44,2,3,1),(17,45,1,4,1),
-- Partida 18 (T2: NightOwls vs SolarFlares, 2-1)
(18, 1,5,1,3),(18, 2,4,2,2),(18, 3,5,1,3),(18, 4,4,2,2),(18, 5,4,0,2),
(18,46,3,3,2),(18,47,4,2,1),(18,48,3,3,2),(18,49,2,3,1),(18,50,3,2,2),
-- Partida 19 (T2: PixelWarriors vs ThunderHawks, 1-0)
(19,11,4,2,3),(19,12,3,2,2),(19,13,4,1,2),(19,14,3,2,3),(19,15,4,1,2),
(19,41,2,3,2),(19,42,3,3,1),(19,43,2,3,1),(19,44,1,4,2),(19,45,2,3,1),
-- Partida 20 (T2: PixelWarriors vs SolarFlares, 2-2)
(20,11,4,2,2),(20,12,3,2,2),(20,13,4,1,3),(20,14,3,2,2),(20,15,3,2,2),
(20,46,4,2,2),(20,47,3,2,2),(20,48,4,1,2),(20,49,3,2,1),(20,50,3,2,2),
-- Partida 21 (T2: ThunderHawks vs SolarFlares, 1-2)
(21,41,2,3,2),(21,42,3,2,1),(21,43,2,3,2),(21,44,1,4,1),(21,45,2,3,1),
(21,46,4,1,3),(21,47,5,2,2),(21,48,4,1,2),(21,49,3,2,2),(21,50,4,1,2),
-- Partida 25 (T2 GrupoB: StormRiders vs IronWolves, 2-1)
(25, 6,5,1,3),(25, 7,4,2,2),(25, 8,5,1,3),(25, 9,3,1,2),(25,10,4,0,2),
(25,16,2,3,2),(25,17,3,2,1),(25,18,2,3,1),(25,19,1,3,1),(25,20,2,2,2),
-- Partida 26 (T2 GrupoB: StormRiders vs CyberDragons, 1-2)
(26, 6,3,3,2),(26, 7,4,2,1),(26, 8,3,3,2),(26, 9,2,2,1),(26,10,3,2,2),
(26,21,6,1,3),(26,22,5,2,3),(26,23,5,1,2),(26,24,4,2,2),(26,25,5,0,2),
-- Partida 27 (T2 GrupoB: StormRiders vs ShadowForce, 3-1)
(27, 6,6,1,3),(27, 7,5,1,3),(27, 8,5,2,2),(27, 9,4,1,3),(27,10,5,0,2),
(27,26,3,3,2),(27,27,2,3,2),(27,28,3,2,1),(27,29,2,3,2),(27,30,2,3,1),
-- Partida 28 (T2 GrupoB: IronWolves vs CyberDragons, 0-2)
(28,16,1,4,1),(28,17,2,3,1),(28,18,1,4,2),(28,19,2,3,1),(28,20,1,3,1),
(28,21,6,1,3),(28,22,5,1,2),(28,23,5,1,3),(28,24,4,1,2),(28,25,5,0,3),
-- Partida 29 (T2 GrupoB: IronWolves vs ShadowForce, 1-1)
(29,16,3,2,2),(29,17,2,2,2),(29,18,3,3,1),(29,19,2,2,2),(29,20,2,3,1),
(29,26,3,2,2),(29,27,2,3,2),(29,28,3,2,2),(29,29,2,2,1),(29,30,2,3,2),
-- Partida 30 (T2 GrupoB: CyberDragons vs ShadowForce, 2-0)
(30,21,6,1,3),(30,22,5,2,3),(30,23,5,1,2),(30,24,4,2,2),(30,25,5,0,2),
(30,26,2,4,1),(30,27,1,3,1),(30,28,2,4,2),(30,29,1,3,1),(30,30,2,3,2);

SELECT setval('estadisticas_individuales_id_seq', 270);
