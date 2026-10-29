Sistema de Gestión de Biblioteca Universitaria

Proyecto Integrador — Diseño de Bases de Datos Facultad — Gestión de préstamos, devoluciones, reservas y multas de material bibliográfico.

Integrantes:
Reinaldo Padilla Pedroza
Dair Quintero Ortiz
Sebastián Ospino Florez
Diego Amaya Verdecia

 Descripción del proyecto.
La biblioteca de la Facultad presta libros y material bibliográfico a estudiantes y docentes de los diferentes programas. Actualmente el registro de préstamos, devoluciones e inventario de ejemplares se lleva en una hoja de cálculo compartida, lo que genera inconsistencias en la disponibilidad real de los ejemplares, falta de control sobre socios con préstamos vencidos o multas pendientes, reservas que se pierden o duplican, y ausencia de un historial confiable de uso del material.

El sistema propuesto permite:

. Registrar el catálogo (libros, autores principales y coautores, ejemplares físicos con su estado).
. Gestionar socios (estudiantes y docentes) y bibliotecarios.
. Controlar préstamos y devoluciones garantizando que un ejemplar no se preste dos veces a la vez.
. Gestionar reservas solo cuando corresponda.
. Calcular y registrar multas por retraso o daño.
. Producir reportes básicos (ejemplares disponibles, socios en mora, libros más prestados).

## Entrega 2 — Implementación (PostgreSQL 16+)

| Carpeta / archivo | Contenido |
|---|---|
| `migraciones/` | DDL en scripts numerados `001`–`006`, ejecutables en orden sobre una base vacía |
| `datos/semilla.sql` | Datos ficticios coherentes (5 filas o más por tabla) |
| `consultas/banco_consultas.sql` | 11 consultas de negocio comentadas |
| `pruebas/pruebas_restricciones.sql` | 17 datos inválidos que el servidor debe rechazar + contraprueba de CASCADE |
| `indices/evidencia_indice.sql` | EXPLAIN ANALYZE antes / después del índice de la migración 005 |
| `evidencias/` | Salida real de los tres scripts anteriores |
| `diagramas/` | Diagrama actualizado (`.svg` editable y `.png`) |
| `DECLARACION_IA.md` | Para qué se usó IA y cómo se verificó |
| `Documentación/Entrega 2/` | Documento de la entrega (`.docx` y `.pdf`) |

### Cómo reconstruir la base

Requisitos: PostgreSQL 16+ con `psql` en el PATH. La conexión se configura con
`PGHOST`, `PGPORT`, `PGUSER` y el archivo `pgpass.conf` de cada integrante;
**ningún archivo del repositorio contiene contraseñas**.

```powershell
.\ejecutar_todo.ps1
psql -d biblioteca -f consultas/banco_consultas.sql
psql -d biblioteca -v ON_ERROR_STOP=0 -f pruebas/pruebas_restricciones.sql
psql -d biblioteca -f indices/evidencia_indice.sql
```

Una migración aplicada no se edita: cualquier corrección va en la siguiente (`007_...sql`).
