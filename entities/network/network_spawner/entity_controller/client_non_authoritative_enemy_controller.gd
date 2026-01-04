class_name ClientNonAuthoritativeEnemyController
extends Node

var enemy_id: int = -1
var spawner_id: int = -1
var controlled_enemy: CharacterBody3D = null
var enemy_manager: NetworkEnemyManager = null

var last_network_position: Vector3 = Vector3.ZERO
var follow_lerp_speed: float = 8.0

func _init(a_spawner_id: int, an_enemy_id: int, an_enemy_manager: NetworkEnemyManager, a_controlled_enemy: CharacterBody3D) -> void:
	spawner_id = a_spawner_id
	enemy_id = an_enemy_id
	enemy_manager = an_enemy_manager
	controlled_enemy = a_controlled_enemy
	# Client does not have authority - disable AI
	if controlled_enemy.has_method("set"):
		controlled_enemy.is_authoritative = false
	enemy_manager.register_enemy(spawner_id, enemy_id, _on_position_update)


func _exit_tree() -> void:
	enemy_manager.unregister_enemy(spawner_id, enemy_id)


func _process(delta: float) -> void:
	if last_network_position != Vector3.ZERO:
		controlled_enemy.global_position = controlled_enemy.global_position.lerp(last_network_position, follow_lerp_speed * delta)


func _on_position_update(enemy_position: EnemyPosition) -> void:
	last_network_position = enemy_position.position
	
	if controlled_enemy.has_node("Visuals/Skeleton_Minion"):
		var model = controlled_enemy.get_node("Visuals/Skeleton_Minion")
		model.rotation.y = lerp_angle(model.rotation.y, enemy_position.rotation, follow_lerp_speed * get_process_delta_time())
