## 🔗 Repositorio

https://github.com/JoelVelasqueZz/sql-transport-analysis

# 🚍 Optimización de Redes de Transporte Urbano (SQL + BI)

Proyecto de análisis de datos enfocado en la optimización de rutas de transporte urbano mediante modelado de bases de datos y consultas SQL.

---

## 🚀 Objetivo

Analizar patrones de uso del transporte para mejorar la eficiencia operativa, reducir costos y optimizar la experiencia del usuario.

---

## 🧠 Tecnologías utilizadas

* MySQL
* SQL (JOINs, agregaciones, subqueries)
* Modelado de bases de datos (ERD)
* Normalización (1FN, 2FN, 3FN)
* Optimización con índices
* Vistas SQL

---

## 🗄️ Diseño de la base de datos

Se diseñó un modelo relacional con las siguientes entidades:

* Rutas
* Horario
* Viajes
* Tipo_Vehiculo
* Costos_Operacion

El modelo permite analizar tanto la operación como la rentabilidad del sistema.

---

## 📊 Análisis realizados

Se desarrollaron consultas SQL para responder preguntas clave de negocio:

### 🔹 Demanda

* Rutas con mayor ocupación en horas pico
* Horarios con menor uso

### 🔹 Eficiencia operativa

* Tiempo promedio de viaje
* Promedio de retrasos

### 🔹 Rentabilidad

* Costo por pasajero
* Costos operativos por tipo de vehículo

---

## 📈 Ejemplo de KPI clave

```sql
SELECT 
    r.nombre,
    SUM(c.costo_total) / SUM(v.pasajeros_transportados) AS costo_por_pasajero
FROM Rutas r
JOIN Horario h ON r.id_ruta = h.id_ruta
JOIN Viajes v ON h.id_horario = v.id_horario
JOIN Costos_Operacion c ON r.id_ruta = c.id_ruta AND v.fecha = c.fecha
GROUP BY r.id_ruta;
```

---

## ⚡ Optimización implementada

* Creación de índices en columnas clave
* Optimización de consultas con JOINs eficientes
* Uso de vistas para simplificar análisis
* Reducción de tiempos de consulta

---

## 📁 Estructura del proyecto

* `proyecto_sistema_transporte_urbano.sql` → creación de base de datos
* `queries.sql` → consultas y análisis
* `docs/` → informe y presentación

---

## 📈 Resultados

* Identificación de rutas con alta demanda
* Reducción potencial de costos operativos
* Mejora en planificación de rutas y horarios
* Base para toma de decisiones basada en datos

---

## 👨‍💻 Autor

Joel Velásquez
GitHub: https://github.com/JoelVelasqueZz
