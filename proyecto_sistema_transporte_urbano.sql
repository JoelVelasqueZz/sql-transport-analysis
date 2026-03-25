CREATE DATABASE sistema_buses;

USE sistema_buses;

CREATE TABLE Tipo_Vehiculo (
    id_tipo_vehiculo INT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    capacidad_vehiculo INT NOT NULL
);

-- Tabla de Rutas
CREATE TABLE Rutas (
    id_ruta INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    origen VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    distancia_km DECIMAL(8,2) NOT NULL,
    tiempo_estimado INT NOT NULL,
    id_tipo_vehiculo INT,
    FOREIGN KEY (id_tipo_vehiculo) REFERENCES Tipo_Vehiculo(id_tipo_vehiculo)
);

-- Tabla de Horarios
CREATE TABLE Horario (
    id_horario INT PRIMARY KEY,
    id_ruta INT,
    hora_salida TIME NOT NULL,
    frecuencia_min INT NOT NULL,
    tipo_dia VARCHAR(20),
    FOREIGN KEY (id_ruta) REFERENCES Rutas(id_ruta)
);

-- Tabla de Viajes
CREATE TABLE Viajes (
    id_viaje INT PRIMARY KEY,
    id_horario INT,
    fecha DATE NOT NULL,
    pasajeros_transportados INT NOT NULL,
    tiempo_real_min INT,
    retrasos_min INT,
    FOREIGN KEY (id_horario) REFERENCES Horario(id_horario)
);

-- Tabla de Costos de Operación
CREATE TABLE Costos_Operacion (
    id_costo INT PRIMARY KEY,
    id_ruta INT,
    fecha DATE NOT NULL,
    combustible DECIMAL(10,2),
    mantenimiento DECIMAL(10,2),
    conductor DECIMAL(10,2),
    costo_total DECIMAL(12,2),
    FOREIGN KEY (id_ruta) REFERENCES Rutas(id_ruta)
);

#REGISTROS INSERTADOS DE TODAS LAS TABLAS
INSERT INTO tipo_vehiculo (id_tipo_vehiculo, tipo, capacidad_vehiculo) VALUES
(1, "Autobus", 40),
(2, "Articulado", 80),
(3, "Mini bus", 25);


#INDICES INICIALES
CREATE INDEX idx_rutas_tipo ON rutas(id_tipo_vehiculo);
CREATE INDEX idx_horario_ruta ON horario(id_ruta);
CREATE INDEX idx_horario_hora ON horario(hora_salida);
CREATE INDEX idx_viajes_horario ON viajes(id_horario);
CREATE INDEX idx_viajes_fecha ON viajes(fecha);
CREATE INDEX idx_costos_fecha ON costos_operacion(fecha desc);
create INDEX idx_costos_ruta ON costos_operacion(id_ruta);



#VISTAS
CREATE VIEW Vista_Estado_Rutas AS
SELECT 
    r.nombre AS ruta,
    r.origen,
    r.destino,
    tv.tipo AS vehiculo,
    AVG(v.pasajeros_transportados) AS pasajeros_promedio,
    AVG(v.retrasos_min) AS retraso_promedio
FROM Rutas r
JOIN Tipo_Vehiculo tv ON r.id_tipo_vehiculo = tv.id_tipo_vehiculo
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
GROUP BY r.id_ruta, r.nombre, r.origen, r.destino, tv.tipo;


#CONSULTAS GENERADAS
#CONSULTA 1: COSTO TOTAL POR TIPO DE VEHICULO

SELECT 
    tv.tipo AS tipo_vehiculo,
    SUM(c.costo_total) AS costo_total_operacion
FROM Costos_Operacion c
INNER JOIN Rutas r ON c.id_ruta = r.id_ruta
INNER JOIN Tipo_Vehiculo tv ON r.id_tipo_vehiculo = tv.id_tipo_vehiculo
GROUP BY tv.tipo;

#CONSULTA 2: CUANTO ES EL PROMEDIO DEL COSTO DE OPERACION POR VIAJE
SELECT 
    tv.tipo AS tipo_vehiculo,
    AVG(c.costo_total) AS costo_promedio_operacion
FROM Costos_Operacion c
INNER JOIN Rutas r ON c.id_ruta = r.id_ruta
INNER JOIN Tipo_Vehiculo tv ON r.id_tipo_vehiculo = tv.id_tipo_vehiculo
GROUP BY tv.tipo;

#CONSULTA 3: Horas pico de tráfico
SELECT hora_salida, AVG(pasajeros_transportados) as promedio_pasajeros
FROM Viajes v
JOIN Horario h ON v.id_horario = h.id_horario
GROUP BY hora_salida
ORDER BY promedio_pasajeros DESC;

#CONSULTA 4: representa el promedio de pasajeros transportados
SELECT r.nombre, 
 AVG(c.costo_total) as costo_promedio,
 AVG(v.pasajeros_transportados) as ocupacion_promedio
FROM Rutas r
JOIN Costos_Operacion c ON r.id_ruta = c.id_ruta
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
GROUP BY r.id_ruta, r.nombre;

#CONSULTA 5: promedio de retrasos en rutas
SELECT r.nombre, AVG(v.retrasos_min) as retraso_promedio
FROM Rutas r
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
GROUP BY r.id_ruta, r.nombre
ORDER BY retraso_promedio DESC;

#CONSULTA 6: RUTAS QUE TIENEN MAYOR OCUPACION EN HORAS PICO
SELECT 
    r.id_ruta,
    r.nombre AS nombre_ruta,
    SUM(v.pasajeros_transportados) AS total_pasajeros
FROM Rutas r
INNER JOIN Horario h ON r.id_ruta = h.id_ruta
INNER JOIN Viajes v ON h.id_horario = v.id_horario
WHERE 
    ((h.hora_salida BETWEEN '06:00:00' AND '09:00:00')
     OR (h.hora_salida BETWEEN '17:00:00' AND '19:00:00'))
    AND h.frecuencia_min BETWEEN 8 AND 10
GROUP BY r.id_ruta, r.nombre
ORDER BY total_pasajeros DESC;

#CONSULTA 7: RUTAS  QUE REPRESENTAN MENOR USO DEL TRANSPORTE
SELECT 
    h.id_horario,
    h.hora_salida,
    r.nombre AS nombre_ruta,
    SUM(v.pasajeros_transportados) AS total_pasajeros
FROM Horario h
INNER JOIN Rutas r ON h.id_ruta = r.id_ruta
INNER JOIN Viajes v ON h.id_horario = v.id_horario
GROUP BY h.id_horario, h.hora_salida, r.nombre
ORDER BY total_pasajeros ASC
LIMIT 10;

#CONSULTA 8: TIEMPO PROMEDIO DE VIAJES
SELECT 
    AVG(tiempo_real_min) AS tiempo_promedio_min
FROM Viajes;

#CONSULTA 9: COSTO POR PASAJERO
SELECT 
    r.id_ruta,
    r.nombre AS nombre_ruta,
    SUM(c.costo_total) / SUM(v.pasajeros_transportados) AS costo_por_pasajero
FROM Rutas r
INNER JOIN Horario h ON r.id_ruta = h.id_ruta
INNER JOIN Viajes v ON h.id_horario = v.id_horario
INNER JOIN Costos_Operacion c ON r.id_ruta = c.id_ruta AND v.fecha = c.fecha
GROUP BY r.id_ruta, r.nombre
ORDER BY r.id_ruta;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));


#MÉTRICAS
SELECT 
    r.id_ruta,
    r.nombre AS nombre_ruta,
    AVG(v.tiempo_real_min) AS tiempo_promedio_min
FROM Viajes v
INNER JOIN Horario h ON v.id_horario = h.id_horario
INNER JOIN Rutas r ON h.id_ruta = r.id_ruta
GROUP BY r.id_ruta, r.nombre;


SELECT 
    r.id_ruta,
    r.nombre AS nombre_ruta,
    SUM(v.pasajeros_transportados) AS total_pasajeros
FROM Viajes v
INNER JOIN Horario h ON v.id_horario = h.id_horario
INNER JOIN Rutas r ON h.id_ruta = r.id_ruta
GROUP BY r.id_ruta, r.nombre
ORDER BY total_pasajeros DESC;



SELECT 
    r.id_ruta,
    r.nombre AS nombre_ruta,
    SUM(c.costo_total) / SUM(v.pasajeros_transportados) AS costo_por_pasajero
FROM Costos_Operacion c
INNER JOIN Rutas r ON c.id_ruta = r.id_ruta
INNER JOIN Horario h ON r.id_ruta = h.id_ruta
INNER JOIN Viajes v ON h.id_horario = v.id_horario AND c.fecha = v.fecha
GROUP BY r.id_ruta, r.nombre;

SELECT 
    tv.tipo AS tipo_vehiculo,
    SUM(v.pasajeros_transportados) / SUM(tv.capacidad_vehiculo) * 100 AS ocupacion_porcentaje
FROM Viajes v
INNER JOIN Horario h ON v.id_horario = h.id_horario
INNER JOIN Rutas r ON h.id_ruta = r.id_ruta
INNER JOIN Tipo_Vehiculo tv ON r.id_tipo_vehiculo = tv.id_tipo_vehiculo
GROUP BY tv.tipo;

#GRACIAS MISS ES LO MAXIMO.