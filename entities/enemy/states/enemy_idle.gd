extends State
class_name EnemyIdle

@export var idle_spot: Node3D
@export var enemy: CharacterBody3D
@export var speed: float = 2.0

var move_direction: Vector2
var wander_time: float

func randomize_wander():
	move_direction = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
	wander_time = randf_range(1,3)

func Enter():
	randomize_wander()
	
func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func Physics_Update(delta: float):
	if enemy:
		var dir_vec = move_direction * speed
		enemy.velocity.x = dir_vec.x
		enemy.velocity.z = dir_vec.y
	
