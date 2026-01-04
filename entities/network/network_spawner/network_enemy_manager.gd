class_name NetworkEnemyManager
extends Node

# Dictionary mapping: "spawner_id:enemy_id" -> Callable
var enemies: Dictionary = {}

func _ready() -> void:
	ServerNetworkGlobals.on_enemy_position.connect(_on_server_enemy_position)
	ClientNetworkGlobals.on_enemy_position_updated.connect(_on_client_enemy_position_updated)


func _exit_tree() -> void:
	ServerNetworkGlobals.on_enemy_position.disconnect(_on_server_enemy_position)
	ClientNetworkGlobals.on_enemy_position_updated.disconnect(_on_client_enemy_position_updated)


func register_enemy(spawner_id: int, enemy_id: int, callable: Callable) -> void:
	var key = "%d:%d" % [spawner_id, enemy_id]
	enemies[key] = callable


func unregister_enemy(spawner_id: int, enemy_id: int) -> void:
	var key = "%d:%d" % [spawner_id, enemy_id]
	enemies.erase(key)


func _on_server_enemy_position(_peer_id: int, enemy_position: EnemyPosition) -> void:
	var key = "%d:%d" % [enemy_position.spawner_id, enemy_position.id]
	if enemies.has(key):
		enemies[key].call(enemy_position)


func _on_client_enemy_position_updated(enemy_position: EnemyPosition) -> void:
	var key = "%d:%d" % [enemy_position.spawner_id, enemy_position.id]
	if enemies.has(key):
		enemies[key].call(enemy_position)
