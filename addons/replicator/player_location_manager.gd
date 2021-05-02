extends Node
class_name PlayerLocationManager, "replicator_node_icon.svg"

"""
Singleton used to manage player locations

Player cameras have to be manually registered by each player.
They are used for distance-based replication optimization.
"""

export var enable_logging := false

var player_cameras : Dictionary = {}

func register(camera : Node, peer : int) -> void:
	player_cameras[peer] = camera.get_path()
	if enable_logging:
		print("Registered %s as camera of peer %s" % [camera.get_path(), peer])


func get_distance(from_node : Node, to_id : int) -> float:
	if not to_id in player_cameras:
		if enable_logging:
			print("No camera found for %s" % to_id)
		return -1.0
	var camera = multiplayer.root_node.get_node(player_cameras[to_id])
	var distance := -1.0
	if from_node is Spatial and camera is Spatial:
		distance = from_node.global_transform.origin.distance_to(
				camera.global_transform.origin)
	elif from_node is Node2D and camera is Node2D:
		distance = from_node.global_position.distance_to(camera.global_position)
	else:
		push_error("Types of %s (type %s) and camera %s (type %s) don't match, can't get distance"\
				% [from_node, from_node.get_class(), camera, camera.get_class()])
	if enable_logging:
		print("Distance from %s to %s is %s" % [from_node, to_id, distance])
	return distance
