# Godot Replicator Node Plugin

Adds a `Replicator` node that can replicates properties with interpolation and spawning and deletion of nodes between server and client without any code.

## Usage

Add a Replicator node to the node that has properties you want to replicate with all clients. This could be a `RigidBody` for example.

Write the properties you want to replicate in the `Replicators` `Members To Replicate` text field. For example, if you want to replicate the position and rotation of a `RigidBody`, type in `transform`.

Every line should be a new property.

| Exported Property       | What it does                                                      |
| -----------------       | ------------                                                      |
| Replicate Automatically | Call `replicate_members` in a specified interval                  |
| Replicate Interval      | The interval at which to call `replicate_members`                 |
| Replicate Spawning      | Spawn on clients when spawned on the server                       |
| Replicate Despawning    | Despawn on clients when despawned on the server                   |
| Spawn On Joining Peers  | Spawn on newly joined clients                                     |
| Interpolate Changes     | Use a generated Tween sibling to interpolate new members linearly |
| Logging                 | Log changes of members on the client                              |

## How it works

The Replicator node uses Godot's high level networking API.

It adds Tween siblings if `interpolate_changes` is true, which interpolate the old value to the new value when replicating, and a timer which calls `replicate_members` on timeout.

The plugin adds an autoload singleton called "RemoteSpawner" to spawn nodes on newly joined peers.

It also removes "@"s from nodes names to be able to replicate node names, as it's impossible to use "@"s when setting a node name.

Example: `@Bullet@2@` becomes `Bullet2`
