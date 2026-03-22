## Used to tell the game what nodes should be merged with the scene.
class_name SceneMerger extends Node

## Nodes to include when merging.
## The path of the node is significant & represents the actual path of the node in the merged scene. Use standard [Node] nodes as parents to emulate the end node's desired path.
@export var included_nodes:Array[Node] = []
## Nodes that will be removed from the merged scene.
@export var remove_node_paths:Array[String]


func merge(scene_instance:Node) -> void:
	for node:Node in included_nodes:
		print(node.get_path_to(self))
