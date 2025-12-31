@tool
class_name PlayerSpawner

extends Node3D

@export var PLAYER_SCENE: PackedScene:
	set(value):
		PLAYER_SCENE = value
		if Engine.is_editor_hint():
			_update_editor_preview()

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_editor_preview()
		return

	NetworkHandler.on_peer_connected.connect(spawn_player)
	ClientNetworkGlobals.on_id_assigned.connect(spawn_player)
	ClientNetworkGlobals.on_remote_id_assigned.connect(spawn_player)


func _update_editor_preview() -> void:
	for child in get_children():
		child.queue_free()
	
	if PLAYER_SCENE == null:
		return
	
	var player = PLAYER_SCENE.instantiate()
	player.name = "PlayerPreview"
	add_child(player)


func spawn_player(id: int) -> void:
	var player = PLAYER_SCENE.instantiate()
	player.owner_id = id
	player.name = str(id)
	call_deferred("add_child", player)
