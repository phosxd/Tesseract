## Used to tell the game what nodes should be merged with the scene.
@tool
class_name SceneMerger extends Node

## Includes every Node inside the scene.
@export_tool_button('Include all Nodes') var include_all_nodes_button = _on_include_all_nodes_pressed
## Nodes to include when merging.
## The path of the node is significant & represents the actual path of the node in the merged scene. Use standard [Node] nodes as parents to emulate the end node's desired path.
@export var included_nodes:Array[Node] = []
## Nodes that will be removed from the merged scene.
@export var remove_node_paths:Array[String] = []
## Nodes that will be reordered to the given relative index.
@export var reorder_node_paths:Dictionary[String,int] = {}

## Scene properties that will be applied. If the property on the target scene does not exist, does nothing.
@export var scene_properties:Dictionary[String,Variant] = {}


func _on_include_all_nodes_pressed() -> void:
	included_nodes = find_children('*')
