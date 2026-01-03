class_name EntityController
extends Node

var controller_type: ControllerType = ControllerType.SERVER_AUTHORITATIVE
var controlled_entity: Player = null
var player_manager: NetworkPlayerManager = null
var owner_id: int = -1

enum ControllerType {
	SERVER_AUTHORITATIVE,
	SERVER_NON_AUTHORITATIVE,
	CLIENT_AUTHORITATIVE,
	CLIENT_NON_AUTHORITATIVE
}

func _init(an_owner_id: int, a_player_manager: NetworkPlayerManager, a_controlled_entity: Player) -> void:
	owner_id = an_owner_id
	player_manager = a_player_manager
	controlled_entity = a_controlled_entity
