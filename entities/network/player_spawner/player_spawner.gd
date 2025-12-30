@tool
class_name PlayerSpawner

extends Node3D

@export var PLAYER_SCENE: PackedScene;

func _ready() -> void:
	if Engine.is_editor_hint():
		if PLAYER_SCENE == null:
			return
		spawn_player(1)
		return

	NetworkHandler.on_peer_connected.connect(spawn_player)
	ClientNetworkGlobals.on_id_assigned.connect(spawn_player)
	ClientNetworkGlobals.on_remote_id_assigned.connect(spawn_player)


func spawn_player(id: int) -> void:
	var player = PLAYER_SCENE.instantiate()
	player.owner_id = id
	player.name = str(id)
	call_deferred("add_child", player)
