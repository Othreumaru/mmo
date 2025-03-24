extends CharacterBody3D

@onready var model: Node3D = $Visuals/Skeleton_Minion
@onready var animation_tree: AnimationTree = $AnimationTree

const SPEED = 5.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if velocity.length() > 0:
		animation_tree.set("parameters/conditions/idle", false)
		animation_tree.set("parameters/conditions/running", true)
		model.look_at(global_position + velocity, Vector3.UP)
	else:
		animation_tree.set("parameters/conditions/running", false)
		animation_tree.set("parameters/conditions/idle", true)
	
	move_and_slide()
