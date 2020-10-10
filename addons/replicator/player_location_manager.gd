extends Node

export var enable_logging := false

var player_cameras : Dictionary = {}

func _ready():
	multiplayer.connect("network_peer_connected", self, "_on_network_peer_connected")


func register(player_camera : Node) -> void:
	rpc("_register_player_camera", multiplayer.root_node.get_path_to(player_camera))


func get_distance(from_node : Node, to_id : int) -> float:
	var to : Node = player_cameras.get(to_id)
	if not to:
		return -1.0
	if from_node is Spatial and to is Spatial:
		return from_node.global_transform.origin.distance_to(to.global_transform.origin)
	elif from_node is Node2D and to is Node2D:
		return from_node.global_position.distance_to(to.global_position)
	return -1.0


func _on_network_peer_connected(id : int) -> void:
	if id == multiplayer.get_network_unique_id():
		return
	var my_camera : Node = player_cameras.get(multiplayer.get_network_unique_id())
	if my_camera:
		rpc_id(id, "_register_player_camera", multiplayer.root_node.get_path_to(my_camera))


remotesync func _register_player_camera(player_camera_path : NodePath) -> void:
	if enable_logging and not multiplayer.get_network_unique_id() == multiplayer.get_rpc_sender_id():
		print("Registering %s as camera of peer %s" % [player_camera_path, multiplayer.get_rpc_sender_id()])
	player_cameras[multiplayer.get_rpc_sender_id()] = multiplayer.root_node.get_node(player_camera_path)
