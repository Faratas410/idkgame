# Stillness

Prototype game project built with Godot 4.

## Running
1. Open the project folder in Godot 4.
2. Play the main scene (`scenes/main.tscn`).

## What’s included
- `project.godot` – Godot project configuration pointing to the main scene.
- `scenes/main.tscn` – Single scene with a `Node2D` root that spawns circles and carries the UI overlay for HUD text and the end-screen panel.
- `scripts/main.gd` – Game flow logic: spawns five moving circles, bounces them off the viewport edges, listens for SPACE/LMB disturbances to randomize velocities, detects collisions to trigger the end screen, shows time survived, number and timing of disturbances, displays “You didn’t have to.”, and handles `R` to restart.
- `scripts/circle.gd` – Simple drawable circle node that stores radius, color, and velocity, moves within bounds, and bounces off screen edges when asked to apply velocity.
