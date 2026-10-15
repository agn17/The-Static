extends Node

signal signal_emitted(pos: Vector2, volume: float, fear: float, device: Node)
signal level_complete

var fear := 0.0
var last_device: Node = null
var done := false

func add_fear(amount: float, device: Node):
	if done:
		return
	if device == last_device:
		amount *= 0.5                       # repeating the same device scares less
	last_device = device
	fear = clampf(fear + amount, 0.0, 100.0)
	if fear >= 100.0:
		done = true
		level_complete.emit()

func _process(delta):
	if not done:
		fear = maxf(0.0, fear - 1.5 * delta)    # slow drain
