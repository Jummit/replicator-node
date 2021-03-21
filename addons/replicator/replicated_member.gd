extends Resource
class_name ReplicatedMember, "replicator_node_icon.svg"

"""
Member resource to be used in a `Replicator`

Holds information about which member should
be replicated how.
"""

# The name of the property.
export var name := ""
# If the property should be smoothly interpolated when a new value is received.
export var interpolate_changes := false
# If the property should be automatically
# Replicated in the specified `replicate_interval`.
export var replicate_automatically := false
# If `replicate_automatically` is true,
# How many seconds to wait to send the next snapshot.
export var replicate_interval := 0.2
# Whether to use `NetworkedMultiplayerPeer.TRANSFER_MODE_RELIABLE`
# Instead of `NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE`.
export var reliable := false
# Whether to log when an update is received on a puppet peer.
export var logging := false
# If `replicate_automatically` is true,
# Maximum difference between snapshots that is interpolated.
export var max_interpolation_distance := INF
# The minimum difference a packet needs to have from the current value to.
# Be accepted.
export var min_replication_difference := 0.0

# How likely it is that this member will be replicated.
var importance := 0.0
