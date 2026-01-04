@tool
class_name PlayerSpawner

extends Node3D

@export var PLAYER_SCENE: PackedScene:
	set(value):
		PLAYER_SCENE = value
		if Engine.is_editor_hint():
			_update_editor_preview()

var player_manager: NetworkPlayerManager

func _ready() -> void:
	if !Engine.is_editor_hint():
		player_manager = NetworkPlayerManager.new()
		player_manager.name = "NetworkPlayerManager"
		add_child(player_manager)
	if Engine.is_editor_hint():
		_update_editor_preview()
		return

	NetworkHandler.on_peer_connected.connect(spawn_non_authoritative_player_on_server)
	ClientNetworkGlobals.on_id_assigned.connect(spawn_authoritative_player_on_client)
	ClientNetworkGlobals.on_remote_id_assigned.connect(spawn_non_authoritative_player_on_client)


func _update_editor_preview() -> void:
	for child in get_children():
		child.queue_free()
	
	if PLAYER_SCENE == null:
		return
	
	var player = PLAYER_SCENE.instantiate()
	player.name = "PlayerPreview"
	add_child(player)


func spawn_non_authoritative_player_on_server(id: int) -> void:
	var player = spawn_player(id)
	var controller = ServerNonAuthoritativeEntityController.new(id, player_manager, player)
	add_child(controller)


func spawn_authoritative_player_on_client(id: int) -> void:
	var player = spawn_player(id)
	var controller = ClientAuthoritativeEntityController.new(id, player_manager, player)
	add_child(controller)


func spawn_non_authoritative_player_on_client(id: int) -> void:
	var player = spawn_player(id)
	var controller = ClientNonAuthoritativeEntityController.new(id, player_manager, player)
	add_child(controller)

func spawn_player(id: int) -> Player:
	if PLAYER_SCENE == null:
		push_error("PLAYER_SCENE is not set")
		return

	var player = PLAYER_SCENE.instantiate()
	player.name = "Player: " + str(id)
	
	call_deferred("add_child", player)
	return player
