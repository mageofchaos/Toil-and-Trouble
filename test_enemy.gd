extends Area3D

static var max_health = 3
static var current_health = 3
static var camera_visible
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_health <= 0:
		_die()

func _die():
	queue_free()
