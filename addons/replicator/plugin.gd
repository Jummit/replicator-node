tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("RemoteSpawner", "res://addons/replicator/RemoteSpawner.gd")
	add_autoload_singleton("PlayerLocationManager", "res://addons/replicator/PlayerLocationManager.gd")
	add_custom_type("Replicator", "Node", load("res://addons/replicator/Replicator.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))
	add_custom_type("RemoteSpawner", "Node", load("res://addons/replicator/RemoteSpawner.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))
	add_custom_type("PlayerLocationManager", "Node", load("res://addons/replicator/PlayerLocationManager.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))


func _exit_tree():
	remove_autoload_singleton("RemoteSpawner")
	remove_autoload_singleton("PlayerLocationManager")
	remove_custom_type("Replicator")
	remove_custom_type("RemoteSpawner")
	remove_custom_type("PlayerLocationManager")
