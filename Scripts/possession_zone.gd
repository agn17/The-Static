# possess_zone.gd
extends Area2D

@export var prompt_offset := Vector2(0, -20)   # where the prompt floats, relative to the zone
@export var action := "interact"
@onready var prompt: Label = $Prompt
var _tween: Tween

func _ready():
	add_to_group("possess_zone")
	prompt.hide()
	prompt.z_index = 10

func show_prompt(on: bool):
	if on == prompt.visible:
		return
	prompt.visible = on
	if _tween:
		_tween.kill()
	if not on:
		return
	prompt.text = _key_text()
	prompt.reset_size()
	var base := prompt_offset - prompt.size / 2.0
	prompt.position = base
	_tween = create_tween().set_loops()           # gentle bob
	_tween.tween_property(prompt, "position:y", base.y - 2.0, 0.4)
	_tween.tween_property(prompt, "position:y", base.y, 0.4)

func _key_text() -> String:
	# Shows whatever key is bound, so rebinding in the Input Map just works
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "?"
	return events[0].as_text().get_slice(" (", 0)   # "E (Physical)" -> "E"
