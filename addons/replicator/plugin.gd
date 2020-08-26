tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Replicator", "Node", load("res://addons/replicator/replicator.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))
	add_custom_type("RemoteSpawner", "Node", load("res://addons/replicator/remote_spawner.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))
	add_custom_type("PlayerLocationManager", "Node", load("res://addons/replicator/player_location_manager.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))


func _exit_tree():
	remove_custom_type("Replicator")
	remove_custom_type("RemoteSpawner")
	remove_custom_type("PlayerLocationManager")
