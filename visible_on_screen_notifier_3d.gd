extends VisibleOnScreenNotifier3D

# Called when the node enters the scene tree for the first time.
@export var character = Area3D
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	character.camera_visible = is_on_screen()
