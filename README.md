# Godot Replicator Node Plugin

This plugin adds a `Replicator` node that replicates properties to clients without needing to write code.

## How to use

Add a Replicator node to the node that has properties you want to synchronize with all clients. This could be a `RigidBody` for example.

Write the properties you want to replicate in the `Replicators` `Members To Replicate` text field. For example, if you want to replicate the position and rotation of a `RigidBody`, type in `transform`.

Every line should be a new property.

## When to use

Only use this to replicate properties from the server to all clients, not the other way around.
