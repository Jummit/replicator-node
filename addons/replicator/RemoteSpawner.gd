extends Node

func _ready():
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")


func _on_SceneTree_node_added(node):
	node.name = node.name.replace("@", "")


puppet func spawn(node_name : String, scene_path : String, path : NodePath) -> void:
	var instance : Node = load(scene_path).instance()
	instance.name = node_name
	get_node(path).add_child(instance)
