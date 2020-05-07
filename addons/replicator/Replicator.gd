extends Node

"""
Replicator

Replicates parent deletion / reparenting
and the properties listed in [members].

Sets the rset mode of all members to replicated to remote so
they can be send to the clients from the server using rset().
"""

export(String, MULTILINE) var members_to_replicate := ""
export var replicate_automatically := false
export var replicate_interval := 0.2
export var replicate_spawning := false
export var replicate_despawning := false
export var spawn_on_joining_peers := false
export var interpolate_changes := true
export var logging := false

var old_values : Dictionary = {}

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
		timer.connect("timeout", self, "_on_SynchronizeTimer_timeout")
		add_child(timer)


func _notification(what):
	if not is_inside_tree():
		yield(self, "tree_entered")
	if not is_network_master():
		return
	
	match what:
		NOTIFICATION_ENTER_TREE:
			if replicate_spawning:
				RemoteSpawner.rpc("spawn", get_parent().name, get_parent().filename, get_parent().get_parent().get_path())
		NOTIFICATION_EXIT_TREE:
			if replicate_despawning:
				rpc("remove")


func _on_network_peer_connected(id):
	RemoteSpawner.rpc_id(id, "spawn", get_parent().name, get_parent().filename, get_parent().get_parent().get_path())


func _on_SynchronizeTimer_timeout():
	if is_inside_tree():
		sync_members()


func sync_members(reliable := false) -> void:
	for member in members_to_replicate.split("\n"):
		if old_values.has(member) and (get_parent().get(member) == old_values[member]):
			continue
		else:
			old_values[member] = get_parent().get(member)
		if reliable:
			rpc("sync_member", member, get_parent().get(member))
		else:
			rpc_unreliable("sync_member", member, get_parent().get(member))


puppet func remove() -> void:
	get_parent().queue_free()


puppet func sync_member(member : String, value) -> void:
	if logging:
		print("%s set to %s" % [member, value])
	if interpolate_changes:
		get_node(member).interpolate_property(get_parent(), member, get(member), value, replicate_interval)
		get_node(member).start()
	else:
		get_parent().set(member, value)
