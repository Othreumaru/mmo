class_name EnemyPosition extends Packet

var spawner_id: int
var id: int
var position: Vector3
var rotation: float

static func create(a_spawner_id: int, enemy_id: int, enemy_position: Vector3, enemy_rotation: float) -> EnemyPosition:
	var packet: EnemyPosition = EnemyPosition.new()
	packet.packet_type = PACKET_TYPE.ENEMY_POSITION
	packet.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	packet.spawner_id = a_spawner_id
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
	data.resize(19)
	data.encode_u8(1, spawner_id)
	data.encode_u8(2, id)
	data.encode_float(3, position.x)
	data.encode_float(7, position.y)
	data.encode_float(11, position.z)
	data.encode_float(15, rotation)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	spawner_id = data.decode_u8(1)
	id = data.decode_u8(2)
	position = Vector3(data.decode_float(3), data.decode_float(7), data.decode_float(11))
	rotation = data.decode_float(15)
