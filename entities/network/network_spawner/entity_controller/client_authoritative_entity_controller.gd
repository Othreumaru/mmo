class_name ClientAuthoritativeEntityController
extends EntityController

func _init(an_owner_id: int, a_player_manager: NetworkPlayerManager, a_controlled_entity: Player) -> void:
	super (an_owner_id, a_player_manager, a_controlled_entity)
	controller_type = ControllerType.CLIENT_AUTHORITATIVE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not controlled_entity.is_on_floor():
		controlled_entity.velocity += controlled_entity.get_gravity() * delta
		
	if controlled_entity.is_on_floor():
		controlled_entity.jumps = controlled_entity.max_jumps

	# Handle jump.
	if controlled_entity.jumps && Input.is_action_just_pressed("jump"):
		controlled_entity.jumps = controlled_entity.jumps - 1
		controlled_entity.velocity.y = controlled_entity.JUMP_VELOCITY
		controlled_entity.jumping = true
		controlled_entity.animation_tree.set("parameters/conditions/jumping", true)
		controlled_entity.animation_tree.set("parameters/conditions/grounded", false)
	if controlled_entity.is_on_floor() && not controlled_entity.last_floor:
		controlled_entity.jumping = false
		controlled_entity.animation_tree.set("parameters/conditions/jumping", false)
		controlled_entity.animation_tree.set("parameters/conditions/grounded", true)
	if not controlled_entity.is_on_floor() && not controlled_entity.jumping:
		controlled_entity.animation_state.travel("Jump_Idle")
		controlled_entity.animation_tree.set("parameters/conditions/grounded", false)
	controlled_entity.last_floor = controlled_entity.is_on_floor()

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Rotates towards camera
	direction = direction.rotated(Vector3.UP, controlled_entity.camera.global_rotation.y)
	
	if direction:
		controlled_entity.velocity.x = direction.x * controlled_entity.SPEED
		controlled_entity.velocity.z = direction.z * controlled_entity.SPEED
	else:
		controlled_entity.velocity.x = move_toward(controlled_entity.velocity.x, 0, controlled_entity.SPEED)
		controlled_entity.velocity.z = move_toward(controlled_entity.velocity.z, 0, controlled_entity.SPEED)
		
	var vl = controlled_entity.velocity * controlled_entity.mage.transform.basis
	controlled_entity.animation_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / controlled_entity.SPEED)

	controlled_entity.move_and_slide()
	
	if controlled_entity.velocity.length() > 0:
		controlled_entity.mage.rotation.y = lerp_angle(controlled_entity.mage.rotation.y, controlled_entity.spring_arm.rotation.y, controlled_entity.rotation_speed * delta)

	PlayerPosition.create(owner_id, controlled_entity.global_position, controlled_entity.mage.rotation.y).send(NetworkHandler.server_peer)
