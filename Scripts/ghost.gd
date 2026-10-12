extends Node2D

@export var speed := 60.0
@export var tether_radius := 40.0
var tether_center := Vector2.ZERO

func _ready():
	tether_center = global_position

func _physics_process(delta):
	var dir := Input.get_vector("left", "right", "up", "down")
	global_position += dir * speed * delta
	var offset := global_position - tether_center
	if offset.length() > tether_radius:
		global_position = tether_center + offset.limit_length(tether_radius)
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, 3, Color(1, 1, 1, 0.8))
	var edge := (global_position - tether_center).length() / tether_radius
	var alpha := lerpf(0.15, 0.8, edge * edge)        # ring brightens near the edge
	draw_arc(to_local(tether_center), tether_radius, 0, TAU, 48, Color(0.6, 0.9, 1, alpha), 1.0)
