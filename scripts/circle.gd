extends Node2D

@export var radius: float = 18.0
var velocity: Vector2 = Vector2.ZERO
var color: Color = Color.WHITE

func _ready() -> void:
    set_process(false)
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, color)

func set_degradation_color(new_color: Color) -> void:
    color = new_color
    queue_redraw()

func apply_velocity(delta: float, bounds: Rect2) -> void:
    position += velocity * delta
    var bounced := false

    if position.x - radius <= bounds.position.x:
        position.x = bounds.position.x + radius
        velocity.x = abs(velocity.x)
        bounced = true
    elif position.x + radius >= bounds.position.x + bounds.size.x:
        position.x = bounds.position.x + bounds.size.x - radius
        velocity.x = -abs(velocity.x)
        bounced = true

    if position.y - radius <= bounds.position.y:
        position.y = bounds.position.y + radius
        velocity.y = abs(velocity.y)
        bounced = true
    elif position.y + radius >= bounds.position.y + bounds.size.y:
        position.y = bounds.position.y + bounds.size.y - radius
        velocity.y = -abs(velocity.y)
        bounced = true

    if bounced:
        queue_redraw()
