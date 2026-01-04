extends CharacterBody3D

@onready var model: Node3D = $Visuals/Skeleton_Minion
@onready var animation_tree: AnimationTree = $AnimationTree

const SPEED = 5.0

# Set to false on clients to prevent AI from running
var is_authoritative: bool = true

func _physics_process(delta: float) -> void:
	# Only run AI logic on authoritative instance (server)
	if !is_authoritative:
		# On clients, just update animations based on velocity
		_update_animations()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_update_animations()
	move_and_slide()


func _update_animations() -> void:
	if velocity.length() > 0:
		animation_tree.set("parameters/conditions/idle", false)
		animation_tree.set("parameters/conditions/running", true)
		model.look_at(global_position + velocity, Vector3.UP)
	else:
		animation_tree.set("parameters/conditions/running", false)
		animation_tree.set("parameters/conditions/idle", true)
