tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("RemoteSpawner", "res://addons/replicator/RemoteSpawner.gd")
	add_custom_type("Replicator", "Node", load("res://addons/replicator/Replicator.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))


func _exit_tree():
	remove_autoload_singleton("RemoteSpawner")
	remove_custom_type("Replicator")
