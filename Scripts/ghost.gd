# ghost.gd
extends Node2D

enum State { FREE, IN_FROG, IN_DEVICE }
var state := State.FREE
var host: Node2D = null

@export var speed := 60.0
@export var tether_radius := 40.0
@export var sprite_faces_right := true   # untick if your ghost art faces left

var tether_center := Vector2.ZERO
var nearby: Array[Area2D] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector: Area2D = $Detector

func _ready():
	tether_center = global_position
	sprite.play("idle")
	detector.area_entered.connect(_on_zone_entered)
	detector.area_exited.connect(_on_zone_exited)
	await get_tree().process_frame
	enter(get_tree().get_first_node_in_group("frog"))   # game starts inside the frog

# ---------- Possess zones and prompts ----------

func _on_zone_entered(zone: Area2D):
	if zone.is_in_group("possess_zone") and zone not in nearby:
		nearby.append(zone)

func _on_zone_exited(zone: Area2D):
	nearby.erase(zone)
	zone.show_prompt(false)

func _nearest_zone() -> Area2D:
	var best: Area2D = null
	var best_d := INF
	for z in nearby:
		var d := z.global_position.distance_to(global_position)
		if d < best_d:
			best = z
			best_d = d
	return best

func _update_prompts():
	# Only the nearest zone shows a prompt, and only while the ghost is free
	var best: Area2D = _nearest_zone() if state == State.FREE else null
	for z in nearby:
		z.show_prompt(z == best)

# ---------- Main loop ----------

func _physics_process(delta):
	if state == State.FREE:
		var dir := Input.get_vector("left", "right", "up", "down")
		global_position += dir * speed * delta

		# Tether clamp
		var offset := global_position - tether_center
		if offset.length() > tether_radius:
			global_position = tether_center + offset.limit_length(tether_radius)

		# Animation and facing
		if dir != Vector2.ZERO:
			if sprite.animation != "drift":
				sprite.play("drift")
			if dir.x != 0:
				sprite.flip_h = (dir.x > 0) != sprite_faces_right
		elif sprite.animation != "idle":
			sprite.play("idle")
	else:
		# Possessing: stick to the host so the camera follows it
		global_position = host.global_position

	_update_prompts()

	if Input.is_action_just_pressed("interact"):
		if state == State.FREE:
			var zone := _nearest_zone()
			if zone:
				enter(zone.get_parent())
		else:
			exit()

	queue_redraw()

# ---------- Possession ----------

func enter(target: Node2D):
	host = target
	state = State.IN_FROG if target.is_in_group("frog") else State.IN_DEVICE
	host.possess()
	visible = false
	for z in nearby:
		z.show_prompt(false)

func exit():
	host.release()
	global_position = host.global_position + Vector2(0, -8)
	tether_center = global_position          # fresh tether on every exit
	host = null
	state = State.FREE
	visible = true
	sprite.play("idle")

# ---------- Tether ring ----------

func _draw():
	if state != State.FREE:
		return
	var edge := (global_position - tether_center).length() / tether_radius
	var alpha := lerpf(0.15, 0.8, edge * edge)
	draw_arc(to_local(tether_center), tether_radius, 0, TAU, 48,
		Color(0.6, 0.9, 1, alpha), 1.0)
