class_name Player

extends CharacterBody3D

@export var camera: Camera3D
@export var mage: Node3D
@export var spring_arm: Node3D
@export var rotation_speed: float = 12
@export var max_jumps:= 2

@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")

const SPEED = 3.0
const JUMP_VELOCITY = 5
const FOLLOW_LERP_SPEED: float = 8.0

var owner_id: int
var last_network_position: Vector3 = Vector3.ZERO
var jumping: bool = false
var last_floor: bool = false
var jumps:= max_jumps
	
var is_authority: bool:
	get:
		return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

func _enter_tree() -> void:
	ServerNetworkGlobals.on_player_position.connect(on_server_player_position_updated)
	ClientNetworkGlobals.on_player_position_updated.connect(on_client_player_position_updated)


func _exit_tree() -> void:
	ServerNetworkGlobals.on_player_position.disconnect(on_server_player_position_updated)
	ClientNetworkGlobals.on_player_position_updated.disconnect(on_client_player_position_updated)

func on_server_player_position_updated(peer_id: int, player_position: PlayerPosition) -> void:
	if peer_id != owner_id:
		return

	global_position = player_position.position
	rotation.y = player_position.rotation

	PlayerPosition.create(owner_id, global_position, rotation.y).broadcast(NetworkHandler.connection)


func on_client_player_position_updated(player_position: PlayerPosition) -> void:
	if is_authority || owner_id != player_position.id:
		return

	var move_vector = player_position.position - last_network_position
	last_network_position = player_position.position

	global_position = global_position.lerp(player_position.position, FOLLOW_LERP_SPEED * get_process_delta_time())

	if move_vector.length() > 0:
		var normalized_move_vector = move_vector.normalized()
		var blend_vector = Vector2(normalized_move_vector.x, normalized_move_vector.z).rotated(-rotation.y)
		animation_tree.set("parameters/IWR/blend_position", blend_vector) 
	else:
		animation_tree.set("parameters/IWR/blend_position", Vector2.ZERO)

	rotation.y = lerp_angle(rotation.y, player_position.rotation, FOLLOW_LERP_SPEED * get_process_delta_time())

func _physics_process(delta: float) -> void:
	if !is_authority:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
		jumps = max_jumps

	# Handle jump.
	if jumps && Input.is_action_just_pressed("jump"):
		jumps = jumps - 1
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

	PlayerPosition.create(owner_id, global_position, mage.rotation.y).send(NetworkHandler.server_peer)
	
	if velocity.length() > 0:
		mage.rotation.y = lerp_angle(mage.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("melee_atack"):
		animation_state.travel("1H_Melee_Attack_Chop")
