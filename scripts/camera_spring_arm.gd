extends Node3D

@export var max_camera_distance = 10
@export var mouse_sensitivity = 0.005
@export_range(-90,0.0,0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(0.0,90.0,0.1, "radians_as_degrees") var max_vertical_angle: float = PI/4

@onready var spring_arm_3d: SpringArm3D = $SpringArm3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.y = wrapf(rotation.y,0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)
	
	if event.is_action_pressed("zoom_in"):
		spring_arm_3d.spring_length = clamp(spring_arm_3d.spring_length - 1, 0, max_camera_distance)
	if event.is_action_pressed("zoom_out"):
		spring_arm_3d.spring_length = clamp(spring_arm_3d.spring_length + 1, 0, max_camera_distance)
