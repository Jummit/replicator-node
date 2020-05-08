extends Node

func _ready():
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")


# node names are replicated in `spawn()`,
# but there is no way to include @s in custom names
func _on_SceneTree_node_added(node):
	node.name = node.name.replace("@", "")


puppet func spawn(node_name : String, scene_path : String, path : NodePath) -> void:
	print("Spawned instance of %s with the name of %s as child of %s" % [scene_path, node_name, path])
	var instance : Node = load(scene_path).instance()
	instance.name = node_name
	get_node(path).add_child(instance)

	# hide the instance because its position may not yet
	# be replicated to avoid seeing the instance at 0, 0
	if instance.has_method("show") and instance.has_method("hide"):
		instance.hide()
		yield(get_tree().create_timer(.01), "timeout")
		instance.show()
