extends Node2D

const CIRCLE_COUNT := 5
const BASE_SPEED := 120.0
const SPEED_VARIATION := 32.0
const DISTURBANCE_PAUSE := 0.06
const TENSION_STEP := 1.03
const SPAWN_PADDING := 36.0

@onready var ui_layer: CanvasLayer = $UI
@onready var hud_label: Label = $UI/HudLabel
@onready var end_panel: Panel = $UI/EndPanel
@onready var result_time: Label = $UI/EndPanel/VBoxContainer/TimeLabel
@onready var result_disturbances: Label = $UI/EndPanel/VBoxContainer/DisturbanceLabel
@onready var result_last: Label = $UI/EndPanel/VBoxContainer/LastDisturbanceLabel
@onready var end_message: Label = $UI/EndPanel/VBoxContainer/MessageLabel

var circles: Array[Node2D] = []
var rng := RandomNumberGenerator.new()
var game_running := true
var start_time := 0.0
var end_time := 0.0
var disturbance_count := 0
var last_disturbance_time := -1.0
var tension_multiplier := 1.0
var disturbing := false

func _ready() -> void:
    rng.randomize()
    start_time = _get_now()
    _spawn_circles()
    _update_hud()

func _process(delta: float) -> void:
    if not game_running:
        return

    var bounds := Rect2(Vector2.ZERO, get_viewport_rect().size)
    for circle in circles:
        circle.apply_velocity(delta, bounds)

    _check_collisions()
    _update_hud()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE and game_running:
            _disturb_circles()
        elif event.keycode == KEY_R:
            get_tree().reload_current_scene()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and game_running:
        _disturb_circles()

func _spawn_circles() -> void:
    var circle_scene := preload("res://scripts/circle.gd")
    var bounds := get_viewport_rect().grow(-SPAWN_PADDING)

    for i in CIRCLE_COUNT:
        var circle: Node2D = circle_scene.new()
        circle.radius = 18.0
        circle.color = Color.from_hsv(rng.randf(), 0.35, 1.0)
        circle.velocity = _random_velocity()
        circle.position = _find_free_position(circle.radius, bounds)
        add_child(circle)
        circles.append(circle)

func _find_free_position(radius: float, bounds: Rect2) -> Vector2:
    var attempts := 0
    while attempts < 40:
        attempts += 1
        var pos := Vector2(
            rng.randf_range(bounds.position.x + radius, bounds.position.x + bounds.size.x - radius),
            rng.randf_range(bounds.position.y + radius, bounds.position.y + bounds.size.y - radius)
        )
        var overlaps := false
        for other in circles:
            if pos.distance_to(other.position) <= radius + other.radius + 4.0:
                overlaps = true
                break
        if not overlaps:
            return pos
    return bounds.position + bounds.size * 0.5

func _random_velocity() -> Vector2:
    var angle := rng.randf_range(0.0, TAU)
    var speed := BASE_SPEED + rng.randf_range(-SPEED_VARIATION, SPEED_VARIATION)
    return Vector2.RIGHT.rotated(angle) * speed

func _check_collisions() -> void:
    for i in circles.size():
        for j in range(i + 1, circles.size()):
            var a := circles[i]
            var b := circles[j]
            if a.position.distance_to(b.position) <= a.radius + b.radius:
                _end_game()
                return

func _disturb_circles() -> void:
    if disturbing:
        return
    disturbing = true
    disturbance_count += 1
    last_disturbance_time = _get_now() - start_time
    tension_multiplier *= TENSION_STEP
    await get_tree().create_timer(DISTURBANCE_PAUSE).timeout
    for circle in circles:
        var angle := deg_to_rad(rng.randi_range(-50, 50))
        var multiplier := rng.randf_range(1.015, 1.13)
        circle.velocity = circle.velocity.rotated(angle) * multiplier * tension_multiplier
    disturbing = false

func _end_game() -> void:
    if not game_running:
        return
    game_running = false
    end_time = _get_now()
    end_panel.visible = true
    _populate_results()

func _populate_results() -> void:
    var survived := end_time - start_time
    result_time.text = "Time survived: %.2f s" % survived
    result_disturbances.text = "Disturbances: %d" % disturbance_count
    if last_disturbance_time >= 0.0:
        result_last.text = "Last disturbance at: %.2f s" % last_disturbance_time
    else:
        result_last.text = "Last disturbance at: (none)"
    end_message.text = "You didn’t have to."

func _update_hud() -> void:
    var elapsed := _get_now() - start_time
    hud_label.text = "Survive. SPACE / LMB: disturb | R: restart\nTime: %.2f s | Disturbances: %d" % [elapsed, disturbance_count]

func _get_now() -> float:
    return Time.get_ticks_msec() / 1000.0
