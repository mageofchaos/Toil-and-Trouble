extends TextureProgressBar


@export var character: Area3D
@export var camera: Camera3D
func _ready() -> void:
	camera.get_viewport().get_camera_3d()
	self.visible = false
	if character and "max_health" in character:
		value = character.max_health
	if character and "current_health" in character:
		value = character.current_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not character or not camera:
		return
	
	#Update health value
	if character and "current_health" in character:
		value = character.current_health
	
	#convert the global pos of char to screenspace coords w/ some upward offset
	if character.camera_visible:
		var screen_pos = camera.unproject_position(character.global_position + Vector3(0, 1, 0))
		global_position = screen_pos
		global_position += Vector2(-get_rect().size.x / 2, 0)
		self.visible = true
		
		#adjust scale based on distance from camera
		var distance = camera.global_transform.origin.distance_to(character.global_transform.origin)
		var scale_factor = clamp(1.0 - distance / 100.0, 0.11, 2.0)
		scale = Vector2(scale_factor, scale_factor)
