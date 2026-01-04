extends Node

signal on_player_position(peer_id: int, player_position: PlayerPosition)
signal on_enemy_position(peer_id: int, enemy_position: EnemyPosition)
signal on_enemy_spawn_request(peer_id: int, enemy_spawn: EnemySpawn)

var peer_ids: Array[int]

func _ready() -> void:
	NetworkHandler.on_peer_connected.connect(on_peer_connected)
	NetworkHandler.on_peer_disconnected.connect(on_peer_disconnected)
	NetworkHandler.on_server_packet.connect(on_server_packet)

func on_peer_connected(peer_id: int) -> void:
	peer_ids.append(peer_id)

	IDAssignment.create(peer_id, peer_ids).broadcast(NetworkHandler.connection)

func on_peer_disconnected(peer_id: int) -> void:
	peer_ids.erase(peer_id)

	# TODO: create and broadcast a packet to inform clients of the disconnection

func on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)

	match packet_type:
		Packet.PACKET_TYPE.PLAYER_POSITION:
			var packet: PlayerPosition = PlayerPosition.create_from_data(data)
			on_player_position.emit(peer_id, packet)
		Packet.PACKET_TYPE.ENEMY_POSITION:
			var packet: EnemyPosition = EnemyPosition.create_from_data(data)
			on_enemy_position.emit(peer_id, packet)
		Packet.PACKET_TYPE.ENEMY_SPAWN:
			var packet: EnemySpawn = EnemySpawn.create_from_data(data)
			on_enemy_spawn_request.emit(peer_id, packet)
		_:
			print("Unknown packet type received from peer %d: %d" % [peer_id, packet_type])