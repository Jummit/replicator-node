extends Node

"""
Singleton used to manage player locations

Player cameras have to be manually registered by each player.
They are used for distance-based replication optimization.
"""

export var enable_logging := false

var player_cameras : Dictionary = {}

func _ready() -> void:
	multiplayer.connect("network_peer_connected", self, "_on_network_peer_connected")


func register(player_camera : Node) -> void:
	rpc("_register_player_camera", player_camera)


func get_distance(from_node : Node, to_id : int) -> float:
	if not to_id in player_cameras:
		return -1.0
	var camera = player_cameras[to_id]
	if from_node is Spatial and camera is Spatial:
		return from_node.global_transform.origin.distance_to(
				camera.global_transform.origin)
	elif from_node is Node2D and camera is Node2D:
		return from_node.global_position.distance_to(camera.global_position)
	return -1.0


func _on_network_peer_connected(id : int) -> void:
	if id == multiplayer.get_network_unique_id():
		return
	if multiplayer.get_network_unique_id() in player_cameras:
		rpc_id(id, "_register_player_camera",
				player_cameras[multiplayer.get_network_unique_id()])


remotesync func _register_player_camera(player_camera_path : NodePath) -> void:
	if enable_logging and not multiplayer.get_network_unique_id() ==\
			multiplayer.get_rpc_sender_id():
		print("Registering %s as camera of peer %s" % [player_camera_path,
				multiplayer.get_rpc_sender_id()])
	player_cameras[multiplayer.get_rpc_sender_id()] =\
			multiplayer.root_node.get_node(player_camera_path)
