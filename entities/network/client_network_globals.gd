extends Node

signal on_id_assigned(id: int)
signal on_remote_id_assigned(remote_id: int)
signal on_player_position_updated(player_position: PlayerPosition)
signal on_enemy_position_updated(enemy_position: EnemyPosition)
signal on_enemy_spawned(enemy_spawn: EnemySpawn)

var id: int = -1
var remote_ids: Array[int] = []

func _ready() -> void:
	NetworkHandler.on_client_packet.connect(on_client_packet)

func on_client_packet(data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)

	match packet_type:
		Packet.PACKET_TYPE.ID_ASSIGNMENT:
			manage_ids(IDAssignment.create_from_data(data))
		Packet.PACKET_TYPE.PLAYER_POSITION:
			var packet: PlayerPosition = PlayerPosition.create_from_data(data)
			on_player_position_updated.emit(packet)
		Packet.PACKET_TYPE.ENEMY_POSITION:
			var packet: EnemyPosition = EnemyPosition.create_from_data(data)
			on_enemy_position_updated.emit(packet)
		Packet.PACKET_TYPE.ENEMY_SPAWN:
			var packet: EnemySpawn = EnemySpawn.create_from_data(data)
			on_enemy_spawned.emit(packet)
		_:
			print("Unknown packet type received: %d" % packet_type)

func manage_ids(packet: IDAssignment) -> void:
	if id == -1:
		id = packet.id
		remote_ids = packet.remote_ids
		on_id_assigned.emit(id)
		for remote_id in remote_ids:
			if remote_id == id:
				continue
			on_remote_id_assigned.emit(remote_id)
	else:
		remote_ids.append(packet.id)
		on_remote_id_assigned.emit(packet.id)