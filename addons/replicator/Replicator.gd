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

# spawn on clients when spawned on the server
export var replicate_spawning := false

# despawn on clients when despawned on the server
export var replicate_despawning := false

# spawn on newly joined clients
export var spawn_on_joining_peers := false

# use a generated Tween sibling to interpolate new members linearly
export var interpolate_changes := true

# log changes of members on the client
export var logging := false

const TYPES_WITH_EQUAL_APPROX_METHOD := [TYPE_VECTOR2, TYPE_RECT2, TYPE_VECTOR3, TYPE_TRANSFORM2D, TYPE_PLANE, TYPE_QUAT, TYPE_AABB, TYPE_BASIS, TYPE_TRANSFORM, TYPE_COLOR]

var already_replicated_once : Dictionary = {}
var last_replicated_values : Dictionary = {}

func _ready():
	for member in members_to_replicate.split("\n", false):
		var tween := Tween.new()
		tween.name = member
		add_child(tween)
	if is_network_master() and spawn_on_joining_peers:
		get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	if is_network_master() and replicate_automatically:
		var timer := Timer.new()
		timer.wait_time = replicate_interval
		timer.autostart = true
		timer.one_shot = false
		timer.connect("timeout", self, "_on_ReplicateTimer_timeout")
		add_child(timer)


func _notification(what):
	if not is_inside_tree() or not is_network_master():
		return
	
	match what:
		NOTIFICATION_ENTER_TREE:
			if replicate_spawning:
				RemoteSpawner.rpc("spawn", get_parent().name, get_parent().filename, get_parent().get_parent().get_path())
				yield(get_tree(), "idle_frame")
				replicate_members()
		NOTIFICATION_EXIT_TREE:
			if replicate_despawning:
				rpc("remove")


func _on_network_peer_connected(id):
	RemoteSpawner.rpc_id(id, "spawn", get_parent().name, get_parent().filename, get_parent().get_parent().get_path())


func _on_ReplicateTimer_timeout():
	if is_inside_tree():
		replicate_members()


func replicate_members(reliable := false) -> void:
	for member in members_to_replicate.split("\n"):
		if last_replicated_values.has(member):
			var is_equal : bool
			if typeof(get_parent().get(member)) in TYPES_WITH_EQUAL_APPROX_METHOD:
				is_equal = get_parent().get(member).is_equal_approx(last_replicated_values[member])
			else:
				is_equal = get_parent().get(member) == last_replicated_values[member]
			if is_equal:
				continue
		last_replicated_values[member] = get_parent().get(member)
		if reliable:
			rpc("replicate_member", member, get_parent().get(member))
		else:
			rpc_unreliable("replicate_member", member, get_parent().get(member))


puppet func remove() -> void:
	get_parent().queue_free()


puppet func replicate_member(member : String, value) -> void:
	if logging:
		print("%s of %s set to %s" % [member, get_parent().name, value])
	if already_replicated_once.has(member) and interpolate_changes:
		get_node(member).interpolate_property(get_parent(), member, get(member), value, replicate_interval)
		get_node(member).start()
	else:
		get_parent().set(member, value)
	already_replicated_once[member] = true
