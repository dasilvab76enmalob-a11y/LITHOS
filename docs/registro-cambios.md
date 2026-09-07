# Registro de cambios

Historial de modificaciones realizadas en el proyecto (útil para seguimiento y revisiones).

---

## 2026-05-11 — Personaje: jitter con exploración (snap 2D)

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `src/common/scripts/Player.gd` | Tras `move_and_slide()`, se asigna `global_position = global_position.snapped(Vector2.ONE)` para alinear el `CharacterBody2D` a la rejilla de mundo en píxeles enteros. |

### Notas

- **Motivo del problema:** con `2d/snap/snap_2d_transforms_to_pixel` activo en `project.godot`, el dibujo del sprite se cuantiza a píxeles mientras la posición física podía quedar en subpíxeles y la cámara seguía en flotantes; el personaje parecía temblar (más en diagonal).
- **Por qué esta opción:** encaja con un RPG táctico con exploración: se mantienen píxeles nítidos y lectura clara en el mapa sin desactivar el snap global del proyecto; la cámara sigue al cuerpo ya alineado, sin volver al redondeo solo en cámara que desincronizaba escenario y sprite.
- **Alternativas** si en combate táctico en cuadrícula necesitas otro paso de rejilla: ajustar solo en esas escenas o usar `snapped` con `Vector2(tile_size, tile_size)` vía export.

---

## 2026-05-11 — Cámara: jitter en diagonal

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `src/common/scripts/Player.gd` | La cámara cercana (`Camera2D`) deja de asignarse con `global_position.round()` y pasa a usar `global_position` sin redondeo, para evitar saltos de 1 píxel por frame que hacían “temblar” el escenario, sobre todo en movimiento diagonal. |

### Notas

- El redondeo forzaba la vista a una rejilla entera mientras el cuerpo se movía en subpíxeles; al seguir el vector real del personaje, el encuadre se desplaza de forma continua.
- Si más adelante se necesita pixel snap solo para sprites, conviene resolverlo en el nodo o en ajustes del proyecto, no cuantizando la cámara cada `_physics_process`.

---

## 2026-05-11 — Movimiento diagonal y script de Cinder

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `src/common/scripts/Player.gd` | Tras construir el vector de dirección con signos por eje, se aplica `.normalized()` antes de multiplicar por `current_speed`, de modo que la magnitud de la velocidad sea la misma en diagonal que en ejes cardinales (evita el factor √2). |
| `src/personajes/cinder/escenas/cinder_animation.tscn` | Se añade `ext_resource` al script `cinder_animation.gd` y `script = ExtResource(...)` en el nodo raíz `CharacterBody2D` (`Player`), alineado con `core_animation.tscn`, para que `_ready` y `_physics_process` de `Player` se ejecuten al reproducir la escena. |

### Archivos creados

| Archivo | Propósito |
|---------|-----------|
| `docs/registro-cambios.md` | Este documento: registro centralizado de cambios y rutas de archivos afectados. |

### Notas

- **Player.gd**: El input lógico (`input` / `_resolve_input`) no cambia; solo la velocidad física pasa a ser uniforme en todas las direcciones activas.
- **Cinder**: Sin el script en la escena, Godot no instanciaba la lógica de `extends Player`.

---

### Cómo usar este registro

Añade una nueva sección con fecha al inicio del documento cuando hagas cambios relevantes, listando tablas similares de archivos modificados o creados y una breve nota del motivo.
