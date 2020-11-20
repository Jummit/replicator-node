extends Node

"""
Singleton that manages replicated spawning
"""

export var enable_logging := false

func _ready():
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")


remote func spawn(node_name : String, network_master : int,
		scene_path : String, path : NodePath) -> void:
	if enable_logging:
		print("Spawning %s named %s on %s" %
				[scene_path, node_name, path])
	var instance : Node = load(scene_path).instance()
	instance.name = node_name
	instance.set_network_master(network_master)
	
	# use a path relative to multiplayer.root_node to make it possible
	# to run server and client on the same machine
	multiplayer.root_node.get_node(path).add_child(instance)
	
	# hide the instance as its position may not yet be
	# replicated to avoid seeing the instance at the origin
	if instance.has_method("show") and instance.has_method("hide"):
		instance.hide()
		yield(get_tree().create_timer(.01), "timeout")
		instance.show()


# node names are replicated in `spawn`,
# but there is no way to include "@"s in custom names
func _on_SceneTree_node_added(node : Node):
	node.name = node.name.replace("@", "")
