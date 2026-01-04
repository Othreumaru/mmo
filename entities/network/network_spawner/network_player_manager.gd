class_name NetworkPlayerManager
extends Node

var players: Dictionary = {} # owner_id -> Callable

func _ready() -> void:
	ServerNetworkGlobals.on_player_position.connect(_on_server_player_position)
	ClientNetworkGlobals.on_player_position_updated.connect(_on_client_player_position_updated)


func _exit_tree() -> void:
	ServerNetworkGlobals.on_player_position.disconnect(_on_server_player_position)
	ClientNetworkGlobals.on_player_position_updated.disconnect(_on_client_player_position_updated)


func register_player(owner_id: int, callable: Callable) -> void:
	players[owner_id] = callable


func unregister_player(owner_id: int) -> void:
	players.erase(owner_id)


func _on_server_player_position(peer_id: int, player_position: PlayerPosition) -> void:
	if players.has(peer_id):
		players[peer_id].call(player_position)


func _on_client_player_position_updated(player_position: PlayerPosition) -> void:
	if players.has(player_position.id):
		players[player_position.id].call(player_position)
