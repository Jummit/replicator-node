extends Node
class_name RemoteSpawner, "replicator_node_icon.svg"

"""
Singleton that manages replicated spawning
"""

export var enable_logging := false

func _ready():
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")


func replicate_node(node : Node, peer := 0) -> void:
	assert(node.filename, "Can't spawn node that isn't root of the scene")
	rpc_id(peer, "spawn", node.name, node.get_network_master(), node.filename,
		get_path_to(node.get_parent()))


remote func spawn(node_name : String, network_master : int,
		scene : String, parent : NodePath) -> void:
	if enable_logging:
		print("Spawning %s named %s on %s" % [scene, node_name, parent])
	# Todo: cache scenes.
	var instance : Node = load(scene).instance()
	instance.name = node_name
	instance.set_network_master(network_master)
	
	# Use a path relative to multiplayer.root_node to make it possible
	# to run server and client on the same machine.
	get_node(parent).add_child(instance)
	
	# Hide the instance as its position may not yet be
	# replicated to avoid seeing the instance at the origin.
	# Todo: move this to `Replicator`.
	if instance.has_method("show") and instance.has_method("hide"):
		instance.hide()
		yield(get_tree().create_timer(.01), "timeout")
		instance.show()


# Node names are replicated in `spawn`,
# but there is no way to include "@"s in custom names.
func _on_SceneTree_node_added(node : Node):
	node.name = node.name.replace("@", "")
