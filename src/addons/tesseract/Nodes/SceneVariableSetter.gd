## Internally used to set scene variables. Should not be added to any scenes.
class_name SceneVariableSetter extends Node

@export var mod_instance_name: String


func _ready() -> void:
	var node = get_parent()
	var mod_instance = TesseractAPI.mod_instances.get(mod_instance_name)

	if mod_instance:
		if not node.scene_file_path.is_empty() && mod_instance:
			var scene_variables:Dictionary = mod_instance.scene_variables.get(node.scene_file_path, {})
			for key:String in scene_variables:
				node.set(key, scene_variables[key])

	queue_free()
