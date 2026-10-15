extends CanvasLayer

func _ready():
	Game.level_complete.connect(func(): $WinLabel.show())

func _process(_delta):
	$ProgressBar.value = Game.fear
