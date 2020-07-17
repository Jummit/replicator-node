tool
extends Node

"""
Replicates parent spawning, despawning and the properties listed in [members].

Supports interpolation, replicating properties at a specified interval
and replicating objects at joining peers.
"""

export var members := []

# spawn on puppet instances when spawned on the master instance
export var replicate_spawning := false

# despawn on puppet instances when despawned on the master instance
export var replicate_despawning := false

# despawn when the master disconnects
export var despawn_on_disconnect := false

# spawn on newly joined peers
export var spawn_on_joining_peers := false

# log changes of members on puppet instances
export var logging := false

var remote_spawner : Node
# store which members where replicated, to only interpolate if the master sent us a state
var already_replicated_once : Dictionary = {}
var last_replicated_values : Dictionary = {}

onready var subject : Node = get_parent()

const TYPES_WITH_EQUAL_APPROX_METHOD := [TYPE_VECTOR2, TYPE_RECT2, TYPE_VECTOR3, TYPE_TRANSFORM2D, TYPE_PLANE, TYPE_QUAT, TYPE_AABB, TYPE_BASIS, TYPE_TRANSFORM, TYPE_COLOR]
const ReplicatedMember = preload("res://addons/replicator/ReplicatedMember.gd")
var NO_MEMBER := ReplicatedMember.new()

func _ready():
	if Engine.editor_hint:
		return
	
	if multiplayer.network_peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		yield(multiplayer, "connected_to_server")
	
	if is_network_master():
		setup_master()
	else:
		setup_puppet()
	
	for member in members:
		setup_member(member)


func _process(_delta : float):
	update_configuration_warning()
	for i in range(members.size()):
		if not typeof(members[i]) == TYPE_OBJECT:
			members[i] = ReplicatedMember.new()
		else:
			members[i].resource_name = members[i].name


func _get_configuration_warning():
	if (replicate_spawning or spawn_on_joining_peers) and get_parent().filename.empty():
		return "Can't replicate spawning if not attached to the root node of the scene."
	return ""


func _on_tree_exiting():
	rpc("remove")


func _on_network_peer_connected(id : int):
	_log("Spawning %s on newly connected peer (%s)" % [subject.filename, id])
	remote_spawner.rpc_id(id, "spawn", get_parent().name, get_network_master(), get_parent().filename, multiplayer.root_node.get_path_to(get_parent().get_parent()))


func _on_network_peer_disconnected(id : int):
	if id == get_network_master():
		subject.queue_free()
		_log("%s despawned as master (%s) disconnected" % [subject.name, get_network_master()])


func _on_ReplicateTimer_timeout(member : ReplicatedMember):
	if is_inside_tree():
		replicate_member(member)


func setup_member(member : ReplicatedMember) -> void:
	if is_network_master():
		if member.replicate_automatically:
			var timer := Timer.new()
			timer.wait_time = member.replicate_interval
			timer.autostart = true
			timer.one_shot = false
			timer.connect("timeout", self, "_on_ReplicateTimer_timeout", [member])
			add_child(timer)
	else:
		var tween := Tween.new()
		tween.name = member.name
		add_child(tween)


func setup_master() -> void:
	remote_spawner = find_node_on_parents(self, "RemoteSpawner")
	
	if spawn_on_joining_peers and not subject.filename.empty():
		multiplayer.connect("network_peer_connected", self, "_on_network_peer_connected")
	if replicate_despawning:
		connect("tree_exiting", self, "_on_tree_exiting")
	if replicate_spawning:
		remote_spawner.rpc("spawn", get_parent().name, get_network_master(), get_parent().filename, multiplayer.root_node.get_path_to(get_parent().get_parent()))
		yield(get_tree(), "idle_frame")
		for member in members:
			replicate_member(member)


func setup_puppet() -> void:
	if despawn_on_disconnect:
		multiplayer.connect("network_peer_disconnected", self, "_on_network_peer_disconnected")


func replicate_member(member : ReplicatedMember) -> void:
	var last_value = last_replicated_values.get(member.name)
	var current_value = subject.get(member.name)
	if not _is_equal_approx(current_value, last_value):
		assert(get(member.name) == null)
		callv("rpc" if member.reliable else "rpc_unreliable", ["set_member_on_puppet", member.name, current_value])
		last_replicated_values[member.name] = current_value


puppet func set_member_on_puppet(member : String, value) -> void:
	_log("%s of %s set to %s" % [member, subject.name, value])
	var configuration := get_member_configuration(member)
	if already_replicated_once.has(member) and configuration.interpolate_changes:
		get_node(member).interpolate_property(subject, member, get(member), value, configuration.replicate_interval)
		get_node(member).start()
	else:
		subject.set(member, value)
		already_replicated_once[member] = true


# called when the master node exits the tree
puppet func remove() -> void:
	subject.queue_free()
	_log("Removed %s" % subject.name)


func get_member_configuration(member_name : String) -> ReplicatedMember:
	for member in members:
		if member.name == member_name:
			return member
	return NO_MEMBER


func _log(message : String) -> void:
	if logging:
		print(message)


static func _is_equal_approx(a, b) -> bool:
	if typeof(a) in TYPES_WITH_EQUAL_APPROX_METHOD and (typeof(a) == typeof(b)):
		return a.is_equal_approx(b)
	else:
		return a == b


static func find_node_on_parents(start_node : Node, node_name : String):
	if not start_node.get_parent():
		return false
	
	var node := start_node.get_parent().find_node(node_name, false, false)
	if node:
		return node
	
	return find_node_on_parents(start_node.get_parent(), node_name)
