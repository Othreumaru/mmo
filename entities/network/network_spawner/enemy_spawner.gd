@tool
class_name EnemySpawner

extends Node3D

@export var ENEMY_SCENE: PackedScene:
	set(value):
		ENEMY_SCENE = value
		if Engine.is_editor_hint():
			_update_editor_preview()

@export var spawner_id: int = 0

var enemy_manager: NetworkEnemyManager
var next_enemy_id: int = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		_update_editor_preview()
		return

	if !Engine.is_editor_hint():
		enemy_manager = NetworkEnemyManager.new()
		enemy_manager.name = "NetworkEnemyManager"
		add_child(enemy_manager)

	# Example: spawn enemies when needed
	# spawn_enemy() can be called from game logic
	if NetworkHandler.is_server:
		for i in range(5):
			spawn_enemy()
		# Listen for new peer connections to send existing enemies
		NetworkHandler.on_peer_connected.connect(_on_peer_connected)
	else:
		# Clients listen for enemy spawn packets
		ClientNetworkGlobals.on_enemy_spawned.connect(_on_enemy_spawned)


func _update_editor_preview() -> void:
	for child in get_children():
		child.queue_free()
	
	if ENEMY_SCENE == null:
		return
	
	var enemy = ENEMY_SCENE.instantiate()
	enemy.name = "EnemyPreview"
	add_child(enemy)


func spawn_enemy() -> CharacterBody3D:
	if ENEMY_SCENE == null:
		push_error("ENEMY_SCENE is not set")
		return null
	
	var enemy = ENEMY_SCENE.instantiate()
	var enemy_id = next_enemy_id
	next_enemy_id += 1
	
	enemy.name = "Enemy_%d_%d" % [spawner_id, enemy_id]
	call_deferred("add_child", enemy)
	
	# On server, create authoritative controller and broadcast spawn
	if NetworkHandler.is_server:
		var controller = ServerAuthoritativeEnemyController.new(spawner_id, enemy_id, enemy_manager, enemy)
		call_deferred("add_child", controller)
		# Broadcast enemy spawn to all clients
		EnemySpawn.create(spawner_id, enemy_id).broadcast(NetworkHandler.connection)
	# On client, create non-authoritative controller  
	else:
		var controller = ClientNonAuthoritativeEnemyController.new(spawner_id, enemy_id, enemy_manager, enemy)
		call_deferred("add_child", controller)
	
	return enemy


func _on_peer_connected(peer_id: int) -> void:
	# Send all existing enemies to the newly connected client
	for i in range(next_enemy_id):
		var packet = EnemySpawn.create(spawner_id, i)
		packet.send(NetworkHandler.client_peers[peer_id])


func _on_enemy_spawned(enemy_spawn: EnemySpawn) -> void:
	# Client received enemy spawn packet from server
	if enemy_spawn.spawner_id == spawner_id:
		# Only spawn if we don't already have this enemy
		var enemy_name = "Enemy_%d_%d" % [enemy_spawn.spawner_id, enemy_spawn.enemy_id]
		if !has_node(enemy_name):
			spawn_enemy_with_id(enemy_spawn.enemy_id)


func spawn_enemy_with_id(enemy_id: int) -> CharacterBody3D:
	if ENEMY_SCENE == null:
		push_error("ENEMY_SCENE is not set")
		return null
	
	var enemy = ENEMY_SCENE.instantiate()
	enemy.name = "Enemy_%d_%d" % [spawner_id, enemy_id]
	call_deferred("add_child", enemy)
	
	# Update next_enemy_id if needed
	if enemy_id >= next_enemy_id:
		next_enemy_id = enemy_id + 1
	
	# Create non-authoritative controller on client
	var controller = ClientNonAuthoritativeEnemyController.new(spawner_id, enemy_id, enemy_manager, enemy)
	call_deferred("add_child", controller)
	
	return enemy
