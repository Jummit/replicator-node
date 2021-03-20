tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("RemoteSpawner", "remote_spawner.gd")
	add_autoload_singleton("PlayerLocationManager", "player_location_manager.gd")


func _exit_tree():
	remove_autoload_singleton("RemoteSpawner")
	remove_autoload_singleton("PlayerLocationManager")
