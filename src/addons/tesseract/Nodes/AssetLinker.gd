## Grabs an asset from the game & applies it to a node property.
## Useful if your mod does not have access to scripts & you need to apply an arbitrary asset.
class_name AssetLinker extends Node

## Name of the asset to link. Ignored if [param asset_path] is used.
@export var asset_name: String
## Path to the asset to link.
@export var asset_path: String

## Node to link the asset to.
@export var node: Node
## Node property to link the asset to.
@export var node_property: String


func _ready() -> void:
	if not node or node_property.is_empty(): return

	var asset
	if asset_path:
		asset = load(asset_path)
	else:
		asset = TesseractAPI.asset_map.get(asset_name)

	if asset != null: node.set(node_property, asset)
