extends Node

var current_state: State
var states: Dictionary = {}

@export var initial_state: State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.Transitioned.connect(on_child_transition)
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state: State, new_state_name: String):
	if(state != current_state):
		return
		
	var new_state: State = state.get(new_state_name)
	if !new_state:
		return
		
	if current_state:
		current_state.Exit()
		
	new_state.Enter()
	current_state = new_state
