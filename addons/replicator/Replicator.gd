extends Node

"""
Replicator

Replicates parent properties listed in [members].
Sets the rset mode of every member in [members] to remote
so they can be send to the clients from the server using rset().
This may be changed later for more flexibility.
"""

export(String, MULTILINE) var members_to_replicate : String


func _ready():
	for member in members_to_replicate.split("\n"):
		get_parent().rset_config(member, MultiplayerAPI.RPC_MODE_REMOTE)


func sync_members():
	for member in members_to_replicate.split("\n"):
		get_parent().rset(member, get_parent().get(member))


func _process(_delta):
	if get_tree().is_network_server():
		sync_members()
