class_name ServerNonAuthoritativeEntityController
extends EntityController

func _init(an_owner_id: int, a_player_manager: NetworkPlayerManager, a_controlled_entity: Player) -> void:
	super (an_owner_id, a_player_manager, a_controlled_entity)
	controller_type = ControllerType.SERVER_NON_AUTHORITATIVE
	player_manager.register_player(owner_id, _on_position_update)


func _on_position_update(new_position: PlayerPosition) -> void:
	controlled_entity.global_position = new_position.position
	controlled_entity.mage.rotation.y = new_position.rotation

	PlayerPosition.create(owner_id, controlled_entity.global_position, controlled_entity.mage.rotation.y).broadcast(NetworkHandler.connection)
