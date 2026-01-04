class_name EnemySpawn extends Packet

var spawner_id: int
var enemy_id: int

static func create(a_spawner_id: int, an_enemy_id: int) -> EnemySpawn:
	var packet: EnemySpawn = EnemySpawn.new()
	packet.packet_type = PACKET_TYPE.ENEMY_SPAWN
	packet.flag = ENetPacketPeer.FLAG_RELIABLE
	packet.spawner_id = a_spawner_id
	packet.enemy_id = an_enemy_id
	return packet


static func create_from_data(data: PackedByteArray) -> EnemySpawn:
	var packet: EnemySpawn = EnemySpawn.new()
	packet.decode(data)
	return packet


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(3)
	data.encode_u8(1, spawner_id)
	data.encode_u8(2, enemy_id)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	spawner_id = data.decode_u8(1)
	enemy_id = data.decode_u8(2)
