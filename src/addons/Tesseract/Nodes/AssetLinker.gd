## Grabs an asset from the game or mod & applies it to a node property.
## Useful if your mod does not have access to scripts & you need to apply an arbitrary asset.
class_name AssetLinker extends Node

## Path of the asset in the game.
@export var game_asset_path: String
## Path of the asset in the mod.
@export var mod_asset_path: String

## Node to link the asset to.
@export var node: Node
## Node property to link the asset to.
@export var node_property: String

@export_storage var mod_id: String


func _ready() -> void:
	if not node or node_property.is_empty(): return

	var asset
	if not game_asset_path.is_empty():
		asset = load(game_asset_path)
	elif not mod_asset_path.is_empty():
		var mod = TesseractAPI.mod_instances.get(mod_id)
		if mod is TesseractMod:
			asset = mod.resources.get(mod_asset_path)

	if asset != null: node.set(node_property, asset)
