extends CharacterBody2D


var charge:=0.0
var active:=true
const Gravity:=600.0
const MAX_CHARGE:=1.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("frog")
	add_to_group("possessable")

func possessable(): active=true
func release():
	active=false
	charge=0.0
	animated_sprite_2d.scale=Vector2.ONE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += Gravity* delta
	else:
		velocity.x=0
		if active:
			if Input.is_action_pressed("jump"):
				charge = min(charge + delta, MAX_CHARGE)
				animated_sprite_2d.scale.y = 1.0 - 0.3 * charge      # squash while charging
			elif Input.is_action_just_released("jump"):
				var dir := Input.get_axis("left", "right")
				velocity = Vector2(dir * 90.0, -120.0 - 100.0 * charge)
				charge = 0.0
				animated_sprite_2d.scale = Vector2(0.8, 1.3)          # stretch on launch
				create_tween().tween_property(animated_sprite_2d, "scale", Vector2.ONE, 0.2)
	move_and_slide()
	
