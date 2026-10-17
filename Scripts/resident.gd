extends CharacterBody2D

enum S { IDLE, CURIOUS, INVESTIGATING, SPOOKED, RETURNING }
var state := S.IDLE
var state_time := 0.0
var target_x := 0.0
var target_device: Node = null
var pending_fear := 0.0
var home_x:= 0.0

@export var walk_speed := 30.0
@export var hearing_scale := 600.0        # volume * this = hearing distance in px
@export var sprite_faces_right := true
@export var huh_sound: AudioStream
@export var gasp_sound: AudioStream

@onready var bubble: Label = $Bubble
@onready var voice: AudioStreamPlayer2D = $Voice
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready():
	home_x= global_position.x
	bubble.text = ""
	Game.signal_emitted.connect(_on_signal)
	_play("idle")

func _play(anim: String):
	if sprite and sprite.animation != anim and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func _set_state(s: S):
	state = s
	state_time = 0.0

func _on_signal(pos: Vector2, volume: float, fear: float, device: Node):
	if state == S.SPOOKED:
		return
	if global_position.distance_to(pos) > volume * hearing_scale:
		return
	target_x = pos.x
	target_device = device
	pending_fear = fear
	bubble.text = "?"
	_say(huh_sound)
	_set_state(S.CURIOUS)

func _say(stream: AudioStream):
	if stream:
		voice.stream = stream
		voice.play()

func _physics_process(delta):
	state_time += delta
	if not is_on_floor():
		velocity.y += 600.0 * delta

	match state:
		S.IDLE:
			velocity.x = 0
			_play("idle")
		S.CURIOUS:
			velocity.x = 0
			_play("idle")
			_face(target_x - global_position.x)
			if state_time > 0.8:
				_set_state(S.INVESTIGATING)
		S.INVESTIGATING:
			var dx := target_x - global_position.x
			if absf(dx) < 12.0:
				_arrive()
			else:
				velocity.x = signf(dx) * walk_speed
				_face(dx)
				_play("walk")
		S.SPOOKED:
			velocity.x = 0
			_play("scared")
			if state_time > 1.5:
				bubble.text = ""
				_set_state(S.RETURNING)
		S.RETURNING:
			var dx:= home_x-global_position.x
			if state_time<3.0:
				velocity.x=0.0
				_play("idle")
			elif absf(dx)<4.0:
				velocity.x=0.0
				_set_state(S.IDLE)
			else:
				velocity.x=signf(dx)*walk_speed*0.7
				_face(dx)
				_play("walk")

	move_and_slide()

func _face(dx: float):
	if sprite and dx != 0:
		sprite.flip_h = (dx > 0) != sprite_faces_right

func _arrive():
	velocity.x = 0
	bubble.text = "!"
	_say(gasp_sound)
	Game.add_fear(pending_fear, target_device)   # fear lands when they find nothing
	_set_state(S.SPOOKED)
