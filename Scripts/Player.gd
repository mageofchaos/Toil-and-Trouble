extends CharacterBody3D


var speed
const WALK_SPEED = 6.5
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

#bobbing vars
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#fov vars
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var gravity = 9.8
var CooldownArmingSword = 0
var WeaponSelect = 0
var lr_diagonal_used = 0
var rl_diagonal_used = 0
const MAX_WEAPONS = 1 #Maximum is 2
const MIN_WEAPONS = 0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var anim_player = $AnimationPlayer
@onready var arming_sword = $Head/Camera3D/ArmingSwordPivot/ArmingSword
@onready var arming_hitbox = $Head/Camera3D/ArmingSwordPivot/ArmingSword/Hitbox
@onready var test_enemy = $"../Test_Enemy"
@onready var armingsword_pivot = $Head/Camera3D/ArmingSwordPivot
@onready var shield_pivot = $Head/Camera3D/ShieldPivot

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	WeaponSelect = 0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89.9999), deg_to_rad(89.9999))

func _process(delta):
	if CooldownArmingSword > 0:
		CooldownArmingSword -= 1
		print(CooldownArmingSword)
	if CooldownArmingSword == 0:
		lr_diagonal_used = 0
		rl_diagonal_used = 0
	if Input.is_action_just_pressed("attack 1") and (not Input.is_action_pressed("block")) and WeaponSelect == 0:
		if CooldownArmingSword == 0:
			anim_player.play("arm-attack")
			arming_hitbox.monitoring = true
			CooldownArmingSword = 20
	if Input.is_action_just_pressed("attack 2") and WeaponSelect == 0:
		if CooldownArmingSword == 0:
			anim_player.play("arm-attack_vert")
			arming_hitbox.monitoring = true
			CooldownArmingSword = 30
	if Input.is_action_pressed("block") and Input.is_action_just_pressed("attack 1") and WeaponSelect != 1:
				anim_player.play("parry")
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	#handle esc key
	if Input.is_action_just_released("menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	#headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "arm-attack":
		arming_hitbox.monitoring = false
		anim_player.play("idle")
	if anim_name == "arm-attack_vert":
		arming_hitbox.monitoring = false
		anim_player.play("idle")
	if anim_name == "parry":
		anim_player.play("RESET")


func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		print("enemy hit")
		if area == test_enemy:
			test_enemy.current_health -= 1
			print("health is", test_enemy.current_health)
