# Declaración de uso de inteligencia artificial

**Herramienta usada:** asistente de IA (Claude).

## Para qué se usó

El diseño del sistema (entidades, relaciones, reglas de negocio, manejo de autor
principal y coautores, y la especialización de Socio pedida en la corrección) es
del grupo. El asistente se usó como apoyo puntual en tareas sencillas:

- Resolver dudas de sintaxis de PostgreSQL (cómo se escribe un índice único
  parcial, `COUNT(*) FILTER`, `EXPLAIN (ANALYZE, BUFFERS)`).
- Revisar la redacción de comentarios y de la documentación.
- Sugerir una forma de garantizar la disyunción de la especialización de Socio
  con una clave foránea compuesta `(id_socio, tipo_socio)`.
- Proponer la forma de generar volumen de prueba con `generate_series` para la
  evidencia del índice.
- Aclarar dudas de teoría (dependencias funcionales, 3FN / BCNF).

## Cómo se verificó

- Todas las migraciones se ejecutaron en orden sobre una base vacía en
  PostgreSQL y corrieron sin errores.
- Los resultados de las consultas se compararon con un conteo a mano sobre la
  semilla (por ejemplo, préstamos de Ingeniería de Sistemas = 5 + 4 = 9).
- Cada restricción se probó con un dato inválido (`pruebas/pruebas_restricciones.sql`)
  y se confirmó el mensaje de rechazo del servidor.
- Los planes del índice se midieron nosotros mismos con `EXPLAIN ANALYZE`.
  Al medir encontramos que el primer índice propuesto (préstamos vencidos) no
  mejoraba nada porque ya existía un índice parcial equivalente; se descartó y
  se cambió por el de `fecha_prestamo`.
- Cada integrante revisó y puede explicar las partes del proyecto.

No se ingresaron datos personales reales en la herramienta: todos los datos de
socios y bibliotecarios son ficticios.
