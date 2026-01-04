class_name ClientNonAuthoritativeEntityController
extends EntityController

var last_network_position: Vector3 = Vector3.ZERO
var follow_lerp_speed: float = 8.0

func _init(an_owner_id: int, a_player_manager: NetworkPlayerManager, a_controlled_entity: Player) -> void:
	super (an_owner_id, a_player_manager, a_controlled_entity)
	controller_type = ControllerType.CLIENT_NON_AUTHORITATIVE
	player_manager.register_player(owner_id, _on_position_update)


func _on_position_update(player_position: PlayerPosition) -> void:
	var move_vector = player_position.position - last_network_position
	last_network_position = player_position.position

	controlled_entity.global_position = controlled_entity.global_position.lerp(player_position.position, follow_lerp_speed * get_process_delta_time())

	if move_vector.length() > 0:
		var normalized_move_vector = move_vector.normalized()
		var blend_vector = Vector2(normalized_move_vector.x, normalized_move_vector.z).rotated(-controlled_entity.mage.rotation.y)
		controlled_entity.animation_tree.set("parameters/IWR/blend_position", blend_vector)
	else:
		controlled_entity.animation_tree.set("parameters/IWR/blend_position", Vector2.ZERO)

	controlled_entity.mage.rotation.y = lerp_angle(controlled_entity.mage.rotation.y, player_position.rotation, follow_lerp_speed * get_process_delta_time())
