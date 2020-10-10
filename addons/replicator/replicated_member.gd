extends Resource

# the name of the property
export var name := ""
# if the property should be smoothly interpolated when a new value is received
export var interpolate_changes := true
# if the property should be automatically
# replicated in the specified `replicate_interval`
export var replicate_automatically := false
# if `replicate_automatically` is true,
# how many seconds to wait to send the next snapshot
export var replicate_interval := 0.2
# weather to use NetworkedMultiplayerPeer.TRANSFER_MODE_RELIABLE
# instead of NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE
export var reliable := false
# weather to log when an update is received on a puppet peer
export var logging := false
# if `replicate_automatically` is true,
# maximum difference between snapshots that is interpolated
export var max_interpolation_distance := INF
