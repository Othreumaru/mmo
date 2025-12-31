class_name EnemyPosition extends Packet

var id: int
var position: Vector3
var rotation: float

static func create(enemy_id: int, enemy_position: Vector3, enemy_rotation: float) -> EnemyPosition:
	var packet: EnemyPosition = EnemyPosition.new()
	packet.packet_type = PACKET_TYPE.ENEMY_POSITION
	packet.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	packet.id = enemy_id
	packet.position = enemy_position
	packet.rotation = enemy_rotation
	return packet

static func create_from_data(data: PackedByteArray) -> EnemyPosition:
	var packet: EnemyPosition = EnemyPosition.new()
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
