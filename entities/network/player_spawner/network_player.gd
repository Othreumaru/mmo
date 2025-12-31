class_name NetworkPlayer
extends Node3D

var player: Player

@export var follow_lerp_speed: float = 8.0

var owner_id: int
var last_network_position: Vector3 = Vector3.ZERO
var is_authority: bool:
	get:
		return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

func _enter_tree() -> void:
	ServerNetworkGlobals.on_player_position.connect(on_server_player_position_updated)
	ClientNetworkGlobals.on_player_position_updated.connect(on_client_player_position_updated)


func _exit_tree() -> void:
	ServerNetworkGlobals.on_player_position.disconnect(on_server_player_position_updated)
	ClientNetworkGlobals.on_player_position_updated.disconnect(on_client_player_position_updated)


func on_server_player_position_updated(peer_id: int, player_position: PlayerPosition) -> void:
	if peer_id != owner_id:
		return

	player.global_position = player_position.position
	player.mage.rotation.y = player_position.rotation

	PlayerPosition.create(owner_id, player.global_position, player.mage.rotation.y).broadcast(NetworkHandler.connection)

func on_client_player_position_updated(player_position: PlayerPosition) -> void:
	if is_authority || owner_id != player_position.id:
		return

	var move_vector = player_position.position - last_network_position
	last_network_position = player_position.position

	player.global_position = player.global_position.lerp(player_position.position, follow_lerp_speed * get_process_delta_time())

	if move_vector.length() > 0:
		var normalized_move_vector = move_vector.normalized()
		var blend_vector = Vector2(normalized_move_vector.x, normalized_move_vector.z).rotated(-player.mage.rotation.y)
		player.animation_tree.set("parameters/IWR/blend_position", blend_vector) 
	else:
		player.animation_tree.set("parameters/IWR/blend_position", Vector2.ZERO)

	player.mage.rotation.y = lerp_angle(player.mage.rotation.y, player_position.rotation, follow_lerp_speed * get_process_delta_time())

func _physics_process(delta: float) -> void:
	if !is_authority or player == null:
		return

	player.update_player_physics(delta)
	PlayerPosition.create(owner_id, player.global_position, player.mage.rotation.y).send(NetworkHandler.server_peer)
