extends Node2D

@export var signal_volume := 0.6      # 0-1, how far residents hear it
@export var fear_value := 10.0
@export var cooldown := 4.0
@export var sound: AudioStream

var possessed := false
var ready_to_use := true
@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var ani_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("possessable")

func possess():
	possessed = true
	ani_sprite.modulate = Color(3, 3, 3)                      # possession flash
	create_tween().tween_property(ani_sprite, "modulate", Color.WHITE, 0.25)
	ani_sprite.play("active")

func release():
	possessed = false
	ani_sprite.play("default")

func _process(_delta):
	if possessed and Input.is_action_just_pressed("signal"):
		trigger()

func trigger():
	if not ready_to_use:
		return
	ready_to_use = false

	if sound:
		audio.stream = sound
		audio.play()
		print("length: ", sound.get_length(), "  playing: ", audio.playing)
	_shake()
	Game.signal_emitted.emit(global_position, signal_volume, fear_value, self)
	await get_tree().create_timer(cooldown).timeout
	ready_to_use = true
	
func _shake():
	var t := create_tween()
	for i in 8:
		t.tween_property(ani_sprite, "position",
			Vector2(randf_range(-2, 2), randf_range(-1, 1)), 0.04)
	t.tween_property(ani_sprite, "position", Vector2.ZERO, 0.04)
	ani_sprite.play("act")
