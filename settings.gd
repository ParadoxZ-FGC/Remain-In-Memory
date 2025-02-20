extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide() 

func entry():
	show()
	
func leave():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass#show() 
