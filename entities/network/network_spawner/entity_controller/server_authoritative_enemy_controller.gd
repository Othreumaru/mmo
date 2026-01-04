class_name ServerAuthoritativeEnemyController
extends Node

var enemy_id: int = -1
var spawner_id: int = -1
var controlled_enemy: CharacterBody3D = null
var enemy_manager: NetworkEnemyManager = null

var position_update_timer: float = 0.0
var position_update_rate: float = 0.05 # 20 updates per second

func _init(a_spawner_id: int, an_enemy_id: int, an_enemy_manager: NetworkEnemyManager, a_controlled_enemy: CharacterBody3D) -> void:
	spawner_id = a_spawner_id
	enemy_id = an_enemy_id
	enemy_manager = an_enemy_manager
	controlled_enemy = a_controlled_enemy
	# Server has authority - enemy can run its AI
	if controlled_enemy.has_method("set"):
		controlled_enemy.is_authoritative = true


func _physics_process(delta: float) -> void:
	position_update_timer += delta
	
	if position_update_timer >= position_update_rate:
		position_update_timer = 0.0
		_broadcast_position()


func _broadcast_position() -> void:
	var rotation_y = 0.0
	if controlled_enemy.has_node("Visuals/Skeleton_Minion"):
		var model = controlled_enemy.get_node("Visuals/Skeleton_Minion")
		rotation_y = model.rotation.y
	
	EnemyPosition.create(spawner_id, enemy_id, controlled_enemy.global_position, rotation_y).broadcast(NetworkHandler.connection)
