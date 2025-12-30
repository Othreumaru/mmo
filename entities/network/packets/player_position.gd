class_name PlayerPosition extends Packet

var id: int
var position: Vector3
var rotation: float

static func create(player_id: int, player_position: Vector3, player_rotation: float) -> PlayerPosition:
	var packet: PlayerPosition = PlayerPosition.new()
	packet.packet_type = PACKET_TYPE.PLAYER_POSITION
	packet.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	packet.id = player_id
	packet.position = player_position
	packet.rotation = player_rotation
	return packet

static func create_from_data(data: PackedByteArray) -> PlayerPosition:
	var packet: PlayerPosition = PlayerPosition.new()
	packet.decode(data)
	return packet

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(18)
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, position.z)
	data.encode_float(14, rotation)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector3(data.decode_float(2), data.decode_float(6), data.decode_float(10))
	rotation = data.decode_float(14)