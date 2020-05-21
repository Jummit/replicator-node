extends Node

"""
Replicates parent spawning, despawning and the properties listed in [members].

Supports interpolation, replicating properties at a specified interval
and replicating objects at joining peers.
"""

export(String, MULTILINE) var members_to_replicate := ""

# call `replicate_members` in a specified interval
export var replicate_automatically := false

# the interval at which to call `replicate_members`
export var replicate_interval := 0.2

# spawn on puppet instances when spawned on the master instance
export var replicate_spawning := false

# despawn on puppet instances when despawned on the master instance
export var replicate_despawning := false

# despawn when the master disconnects
export var despawn_on_disconnect := false

# spawn on newly joined peers
export var spawn_on_joining_peers := false

# use a generated Tween sibling to interpolate new members linearly
export var interpolate_changes := true

# log changes of members on puppet instances
export var logging := false

const TYPES_WITH_EQUAL_APPROX_METHOD := [TYPE_VECTOR2, TYPE_RECT2, TYPE_VECTOR3, TYPE_TRANSFORM2D, TYPE_PLANE, TYPE_QUAT, TYPE_AABB, TYPE_BASIS, TYPE_TRANSFORM, TYPE_COLOR]

var already_replicated_once : Dictionary = {}
var last_replicated_values : Dictionary = {}

onready var subject : Node = get_parent()

func _ready():
	for member in members_to_replicate.split("\n", false):
		var tween := Tween.new()
		tween.name = member
		add_child(tween)
	if is_network_master() and spawn_on_joining_peers and not subject.filename.empty():
		get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	if not is_network_master() and despawn_on_disconnect:
		get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	if is_network_master() and replicate_automatically:
		var timer := Timer.new()
		timer.wait_time = replicate_interval
		timer.autostart = true
		timer.one_shot = false
		timer.connect("timeout", self, "_on_ReplicateTimer_timeout")
		add_child(timer)


func _notification(what):
	if not (is_inside_tree() and is_network_master()):
		return
	
	match what:
		NOTIFICATION_ENTER_TREE:
			if replicate_spawning:
				RemoteSpawner.rpc("spawn", get_parent().name, get_network_master(), get_parent().filename, get_parent().get_parent().get_path())
				yield(get_tree(), "idle_frame")
				replicate_members()
		NOTIFICATION_EXIT_TREE:
			if replicate_despawning:
				rpc("remove")


func _on_network_peer_connected(id):
	_log("Spawned %s on newly connected peer %s" % [subject.filename, id])
	RemoteSpawner.rpc_id(id, "spawn", subject.name, get_network_master(), subject.filename, subject.get_parent().get_path())


func _on_network_peer_disconnected(id):
	if id == get_network_master():
		subject.queue_free()
		_log("%s despawned as master (%s) disconnected" % [subject.name, get_network_master()])


func _on_ReplicateTimer_timeout():
	if is_inside_tree():
		replicate_members()


func replicate_members(reliable := false) -> void:
	for member in members_to_replicate.split("\n"):
		var last_value = last_replicated_values.get(member)
		var current_value = subject.get(member)
		if not _is_equal_approx(current_value, last_value):
			callv("rpc" if reliable else "rpc_unreliable", ["replicate_member", member, current_value])
			last_replicated_values[member] = current_value


puppet func replicate_member(member : String, value) -> void:
	_log("%s of %s set to %s" % [member, subject.name, value])
	if already_replicated_once.has(member) and interpolate_changes:
		get_node(member).interpolate_property(subject, member, get(member), value, replicate_interval)
		get_node(member).start()
	else:
		subject.set(member, value)
	already_replicated_once[member] = true


puppet func remove() -> void:
	subject.queue_free()
	_log("Removed %s" % subject.name)


func _log(message : String) -> void:
	if logging:
		print(message)


func _is_equal_approx(a, b) -> bool:
	if a == null or b == null:
		return false
	else:
		return a.is_equal_approx(b) if typeof(a) in TYPES_WITH_EQUAL_APPROX_METHOD else a == b
