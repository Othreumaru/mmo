@tool
class_name EnemySpawner

extends Node3D

@export var ENEMY_SCENE: PackedScene:
	set(value):
		ENEMY_SCENE = value
		if Engine.is_editor_hint():
			_update_editor_preview()


func _ready() -> void:
	if Engine.is_editor_hint():
		_update_editor_preview()
		return

	spawn_enemy(1) # Example spawn for testing


func _update_editor_preview() -> void:
	for child in get_children():
		child.queue_free()
	
	if ENEMY_SCENE == null:
		return
	
	var enemy = ENEMY_SCENE.instantiate()
	enemy.name = "EnemyPreview"
	add_child(enemy)


func spawn_enemy(id: int) -> void:
	var enemy = ENEMY_SCENE.instantiate()
	enemy.name = str(id)
	call_deferred("add_child", enemy)
