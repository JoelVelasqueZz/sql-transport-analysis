-- =========================
-- CONFIGURACIÓN
-- =========================

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- =========================
-- RENTABILIDAD
-- =========================

-- Costo total por tipo de vehículo
SELECT 
    tv.tipo AS tipo_vehiculo,
    SUM(c.costo_total) AS costo_total_operacion
FROM Costos_Operacion c
JOIN Rutas r ON c.id_ruta = r.id_ruta
JOIN Tipo_Vehiculo tv ON r.id_tipo_vehiculo = tv.id_tipo_vehiculo
GROUP BY tv.tipo;

-- Promedio de costo de operación
SELECT 
    tv.tipo AS tipo_vehiculo,
    AVG(c.costo_total) AS costo_promedio_operacion
FROM Costos_Operacion c
JOIN Rutas r ON c.id_ruta = r.id_ruta
JOIN Tipo_Vehiculo tv ON r.id_tipo_vehiculo = tv.id_tipo_vehiculo
GROUP BY tv.tipo;

-- Costo por pasajero
SELECT 
    r.id_ruta,
    r.nombre AS nombre_ruta,
    SUM(c.costo_total) / SUM(v.pasajeros_transportados) AS costo_por_pasajero
FROM Rutas r
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
JOIN Costos_Operacion c ON r.id_ruta = c.id_ruta AND v.fecha = c.fecha
GROUP BY r.id_ruta, r.nombre
ORDER BY r.id_ruta;

-- =========================
-- DEMANDA
-- =========================

-- Horas pico
SELECT 
    h.hora_salida, 
    AVG(v.pasajeros_transportados) AS promedio_pasajeros
FROM Viajes v
JOIN Horario h ON v.id_horario = h.id_horario
GROUP BY h.hora_salida
ORDER BY promedio_pasajeros DESC;

-- Rutas con mayor ocupación en horas pico
SELECT 
    r.id_ruta,
    r.nombre AS nombre_ruta,
    SUM(v.pasajeros_transportados) AS total_pasajeros
FROM Rutas r
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
WHERE 
    ((h.hora_salida BETWEEN '06:00:00' AND '09:00:00')
     OR (h.hora_salida BETWEEN '17:00:00' AND '19:00:00'))
    AND h.frecuencia_min BETWEEN 8 AND 10
GROUP BY r.id_ruta, r.nombre
ORDER BY total_pasajeros DESC;

-- Horarios con menor uso
SELECT 
    h.id_horario,
    h.hora_salida,
    r.nombre AS nombre_ruta,
    SUM(v.pasajeros_transportados) AS total_pasajeros
FROM Horario h
JOIN Rutas r ON h.id_ruta = r.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
GROUP BY h.id_horario, h.hora_salida, r.nombre
ORDER BY total_pasajeros ASC
LIMIT 10;

-- =========================
-- EFICIENCIA
-- =========================

-- Tiempo promedio de viajes
SELECT 
    AVG(tiempo_real_min) AS tiempo_promedio_min
FROM Viajes;

-- Promedio por ruta
SELECT 
    r.nombre,
    AVG(c.costo_total) AS costo_promedio,
    AVG(v.pasajeros_transportados) AS ocupacion_promedio
FROM Rutas r
JOIN Costos_Operacion c ON r.id_ruta = c.id_ruta
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
GROUP BY r.id_ruta, r.nombre;

-- Promedio de retrasos
SELECT 
    r.nombre, 
    AVG(v.retrasos_min) AS retraso_promedio
FROM Rutas r
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
GROUP BY r.id_ruta, r.nombre
ORDER BY retraso_promedio DESC;

-- =========================
-- MÉTRICAS CLAVE
-- =========================

-- Tiempo promedio por ruta
SELECT 
    r.id_ruta,
    r.nombre,
    AVG(v.tiempo_real_min) AS tiempo_promedio
FROM Viajes v
JOIN Horario h ON v.id_horario = h.id_horario
JOIN Rutas r ON h.id_ruta = r.id_ruta
GROUP BY r.id_ruta, r.nombre;

-- Total pasajeros por ruta
SELECT 
    r.id_ruta,
    r.nombre,
    SUM(v.pasajeros_transportados) AS total_pasajeros
FROM Viajes v
JOIN Horario h ON v.id_horario = h.id_horario
JOIN Rutas r ON h.id_ruta = r.id_ruta
GROUP BY r.id_ruta, r.nombre
ORDER BY total_pasajeros DESC;

-- Ocupación por tipo de vehículo
SELECT 
    tv.tipo AS tipo_vehiculo,
    SUM(v.pasajeros_transportados) / SUM(tv.capacidad_vehiculo) * 100 AS ocupacion_porcentaje
FROM Viajes v
JOIN Horario h ON v.id_horario = h.id_horario
JOIN Rutas r ON h.id_ruta = r.id_ruta
JOIN Tipo_Vehiculo tv ON r.id_tipo_vehiculo = tv.id_tipo_vehiculo
GROUP BY tv.tipo;