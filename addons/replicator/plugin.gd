tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Replicator", "Node", preload("res://addons/replicator/Replicator.gd"), preload("res://addons/replicator/replicator_node_icon.svg"))


func _exit_tree():
	remove_custom_type("Replicator")
