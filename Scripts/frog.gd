# frog.gd
extends CharacterBody2D

const GRAVITY := 600.0
const MAX_CHARGE := 1.0
var active := true          # Day 2: set by the ghost
var charge := 0.0
var facing := 1
var was_on_floor := true
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var sprite_faces_right := true
func _ready():
	add_to_group("frog")
	add_to_group("possessable")
	sprite.play("idle")

func _face(dir: float):
	if dir == 0:
		return
	facing = int(signf(dir))
	sprite.flip_h = (facing > 0) != sprite_faces_right

func possess(): 
	active = true
	
func release():
	active = false
	charge = 0.0
	sprite.scale = Vector2.ONE
	sprite.play("idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		# Pick rise/fall animation by vertical speed
		sprite.play("jumpe" if velocity.y < 0 else "falle")
	else:
		velocity.x = 0
		if active:
			if Input.is_action_pressed("jump"):
				charge = min(charge + delta, MAX_CHARGE)
				if sprite.animation != "charged":
					sprite.play("charged")
					_face(Input.get_axis("left", "right"))

			elif Input.is_action_just_released("jump"):
				var dir := Input.get_axis("left", "right")
				_face(dir)
				velocity = Vector2(dir * 90.0, -120.0 - 100.0 * charge)
				charge = 0.0
				sprite.play("jumpe")
				sprite.scale = Vector2(0.85, 1.2)
				create_tween().tween_property(sprite, "scale", Vector2.ONE, 0.15)
			elif sprite.animation != "pidle":
				sprite.play("pidle")
		elif sprite.animation != "idle":
			sprite.play("idle")
	move_and_slide()
	was_on_floor = is_on_floor()
