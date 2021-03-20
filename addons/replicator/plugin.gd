tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Replicator", "Node", load("replicator.gd"), preload("replicator_node_icon.svg"))
	add_custom_type("RemoteSpawner", "Node", load("remote_spawner.gd"), preload("replicator_node_icon.svg"))
	add_custom_type("PlayerLocationManager", "Node", load("player_location_manager.gd"), preload("replicator_node_icon.svg"))
	
	add_autoload_singleton("RemoteSpawner", "remote_spawner.gd")
	add_autoload_singleton("PlayerLocationManager", "player_location_manager.gd")


func _exit_tree():
	remove_custom_type("Replicator")
	remove_custom_type("RemoteSpawner")
	remove_custom_type("PlayerLocationManager")
	
	remove_autoload_singleton("RemoteSpawner")
	remove_autoload_singleton("PlayerLocationManager")
