class_name ServerAuthoritativeEntityController
extends EntityController

func _init( an_owner_id: int, a_player_manager: NetworkPlayerManager, a_controlled_entity: Player) -> void:
	super(an_owner_id, a_player_manager, a_controlled_entity)
	controller_type = ControllerType.SERVER_AUTHORITATIVE
 