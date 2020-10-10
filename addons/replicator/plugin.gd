tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Replicator", "Node", load("res://addons/replicator/replicator.gd"), preload("replicator_node_icon.svg"))
	add_custom_type("RemoteSpawner", "Node", load("res://addons/replicator/remote_spawner.gd"), preload("replicator_node_icon.svg"))
	add_custom_type("PlayerLocationManager", "Node", load("res://addons/replicator/player_location_manager.gd"), preload("replicator_node_icon.svg"))
	
	add_autoload_singleton("RemoteSpawner", "res://addons/replicator/remote_spawner.gd")
	add_autoload_singleton("PlayerLocationManager", "res://addons/replicator/player_location_manager.gd")


func _exit_tree():
	remove_custom_type("Replicator")
	remove_custom_type("RemoteSpawner")
	remove_custom_type("PlayerLocationManager")
	
	remove_autoload_singleton("RemoteSpawner")
	remove_autoload_singleton("PlayerLocationManager")
