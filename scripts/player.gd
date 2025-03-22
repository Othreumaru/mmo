extends CharacterBody3D

@export var camera: Camera3D
@export var mage: Node3D
@export var spring_arm: Node3D
@export var rotation_speed: float = 12

@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")

const SPEED = 3.0
const JUMP_VELOCITY = 5

var jumping: bool = false
var last_floor: bool = false
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if is_on_floor() && Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jumping = true
		animation_tree.set("parameters/conditions/jumping", true)
		animation_tree.set("parameters/conditions/grounded", false)
	if is_on_floor() && not last_floor:
		jumping = false
		animation_tree.set("parameters/conditions/jumping", false)
		animation_tree.set("parameters/conditions/grounded", true)
	if not is_on_floor() && not jumping:
		animation_state.travel("Jump_Idle")
		animation_tree.set("parameters/conditions/grounded", false)
	last_floor = is_on_floor()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Rotates towards camera
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	var vl = velocity * mage.transform.basis
	animation_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / SPEED)

	move_and_slide()
	
	if velocity.length() > 0:
		mage.rotation.y = lerp_angle(mage.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("melee_atack"):
		animation_state.travel("1H_Melee_Attack_Chop")
