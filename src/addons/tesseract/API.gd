## Bridge between your game & mods.
##
## This is where you can set options for your game to determine how mods will interact with it.
##
## Set [param game_api_version] to distinguish between major API versions (E.g. if you changed signal map, asset map or your project file structure).
## Set [param asset_map] to provide assets that mods can use.
## Set [param signal_map] to provide signals that mods can call.
extends Node

## Tesseract API version.
const api_version:int = 1

## Assets available to mods. This is only used in [AssetLinker].
var asset_map:Dictionary[String,Variant] = {}
## Signals available to mods.
var signal_map:Dictionary[String,Signal] = {}

#region config

var config := ConfigFile.new()

## Current version of the game's API.
var game_api_version: Variant:
	set(value):
		game_api_version = value
		config.set_value('game', 'api_version', value)
	get():
		return config.get_value('game', 'api_version')

## Path to load PCKs from. If is an empty string, PCK loading is disabled.
var patches_path: String:
	set(value):
		patches_path = value
		config.set_value('game', 'patches_path', value)
	get():
		return config.get_value('game', 'patches_path', '')

## Path to load mods from. If is an empty string, Tesseract mod loading is disabled.
var mods_path: String:
	set(value):
		patches_path = value
		config.set_value('game', 'mods_path', value)
	get():
		return config.get_value('game', 'mods_path', '')

## Path to load all mods into.
## If path ends with "*" will put the mod into a sub-directory with the name of the mod (or file name if details are unavailable)
var load_mods_into_path: String:
	set(value):
		load_mods_into_path = value
		config.set_value('game', 'load_mods_into_path', value)
	get():
		return config.get_value('game', 'load_mods_into_path', '')

## If true, Tesseract will load in mods that don't have any configuration, name, or other details.
## These mods will not be accesible to the game in any way.
var allow_mods_without_details: bool:
	set(value):
		allow_mods_without_details = value
		config.set_value('game', 'allow_mods_without_details', value)
	get():
		return config.get_value('game', 'allow_mods_without_details', false)

var allow_mod_scripts: bool:
	set(value):
		allow_mod_scripts = value
		config.set_value('game', 'allow_mod_scripts', value)
	get():
		return config.get_value('game', 'allow_mod_scripts', true)

#endregion

var config_loaded:bool = false
## Every loaded mod instance.
var mod_instances:Dictionary[String,TesseractMod] = {}


func _init() -> void:
	var err:Error = config.load('res://addons/tesseract/plugin.cfg')
	if err != OK:
		return
	config_loaded = true


func _ready() -> void:
	if not config_loaded:
		print("YTUHUIh")
		TesseractErrorServer.error.emit(1)


## Set API variables via Dictionary.
func init(options:Dictionary[String,Variant]) -> void:
	for key:String in options:
		set(key, options[key])


func load_mods() -> void:
	# Get PCK patch paths.
	if not patches_path.is_empty():
		var pck_paths := PackedStringArray()
		if not DirAccess.dir_exists_absolute(mods_path): DirAccess.make_dir_recursive_absolute(patches_path)
		TesseractUtils.walk_dir(patches_path, func(file_path:String) -> void:
			pck_paths.append(file_path)
		)
		# Load PCK mods in alphabetical order.
		pck_paths.sort()
		for path:String in pck_paths:
			var succeeded:bool = ProjectSettings.load_resource_pack(path, true)
			if not succeeded:
				continue

	# Get mod paths.
	if not mods_path.is_empty():
		var mod_paths := PackedStringArray()
		if not DirAccess.dir_exists_absolute(mods_path): DirAccess.make_dir_recursive_absolute(mods_path)
		for dir_path:String in DirAccess.get_directories_at(mods_path):
			mod_paths.append(mods_path+'/'+dir_path)

		# Load mods in alphabetical order.
		mod_paths.sort()
		for mod_path:String in mod_paths:
			# Get mod config.
			var mod_config_path:String = mod_path+'/MOD.cfg'
			var mod_config := ConfigFile.new()
			var mod_config_err:Error = mod_config.load(mod_config_path)
			if mod_config_err != OK:
				TesseractErrorServer.warning.emit(1, [mod_path])
				if not allow_mods_without_details: continue

			# Get game configuration for mods of this type.
			var mod_type:String = mod_config.get_value('TesseractMod', 'type', '')
			var mod_type_section:String = 'MOD TYPE: %s' % mod_type

			var cfg_game_api_version = config.get_value(mod_type_section, 'api_version', game_api_version)
			var cfg_load_into_path:String = config.get_value(mod_type_section, 'load_mods_into_path', load_mods_into_path)
			var cfg_allow_mod_scripts:bool = config.get_value(mod_type_section, 'allow_mod_scripts', allow_mod_scripts)
			var for_game_versions:Array[Variant] = mod_config.get_value('TesseractMod', 'for_game_versions', [cfg_game_api_version])
			var for_tesseract_versions:Array[Variant] = mod_config.get_value('TesseractMod', 'for_tesseract_versions', [api_version])
			if cfg_game_api_version not in for_game_versions:
				TesseractErrorServer.warning.emit(2, [mod_path])
				continue
			if api_version not in for_tesseract_versions :
				TesseractErrorServer.warning.emit(3, [mod_path])
				continue

			# Get mod script.
			var mod_script_path:String = mod_path+'/INIT.gd'
			var mod_script
			if cfg_allow_mod_scripts && FileAccess.file_exists(mod_script_path):
				mod_script = load(mod_script_path) as GDScript
			# If none found or is invalid, use backup script.
			if mod_script is not GDScript or mod_script.get_base_script() != TesseractMod:
				mod_script = load('res://addons/tesseract/ModScript.gd')
			var mod_instance = mod_script.new() as TesseractMod

			# Set config values to the mod instance.
			mod_instance.config = mod_config
			for key:String in mod_config.get_section_keys('TesseractMod'):
				mod_instance.set(key, mod_config.get_value('TesseractMod', key))

			# Walk through all resources in the mod & load them.
			var resources:Array[Resource] = []
			TesseractUtils.walk_dir(mod_path, func(file_path:String) -> void:
				var relative_path:String = file_path.trim_prefix(mod_path+'/')
				if relative_path in ['INIT.gd','MOD.cfg']: return
				var res_path:String = 'res://'+cfg_load_into_path+('' if cfg_load_into_path.ends_with('/') else '/')+'%s' % relative_path
				var ext:String = file_path.split('.')[-1]
				# Load resource.
				if ext in ['tres','res','tscn','scn','gd','gdshader','gdshaderinc','theme','material']:
					var res = load(file_path)
					if res is Script && not cfg_allow_mod_scripts: return
					if res is PackedScene:
						_load_mod_scene(mod_instance, res, res_path, file_path)
					elif res:
						_load_mod_resource(mod_instance, res, res_path)
				# Load image.
				elif ext in ['svg','png','jpg','jpeg']:
					var res = Image.load_from_file(file_path)
					if res:
						res.take_over_path(res_path)
						if not mod_instance.resources.has(res): mod_instance.resources.append(res)
				# Load config.
				elif ext in ['cfg']:
					var res = ConfigFile.new()
					_load_mod_cfg(mod_instance, res, res_path, file_path)
			)
			# Initialize mod.
			mod_instance.init()
			mod_instances.set(mod_instance.name, mod_instance)


func _load_mod_resource(mod_instance:TesseractMod, res:Resource, res_path:String) -> void:
	res.take_over_path(res_path)
	if not mod_instance.resources.has(res): mod_instance.resources.append(res)


func _load_mod_scene(mod_instance:TesseractMod, res:PackedScene, res_path:String, file_path:String) -> void:
	var scene_instance:Node = res.instantiate()
	# Merge scenes.
	if scene_instance is SceneMerger:
		# Get base scene.
		var base_scene = load(res_path) as PackedScene
		if base_scene is not PackedScene: return
		var base_scene_instance:Node = base_scene.instantiate()
		# Add included nodes.
		for node:Node in scene_instance.included_nodes:
			if not node: continue
			var node_path:NodePath = scene_instance.get_path_to(node)
			# Get base nodes.
			var base_node = base_scene_instance.get_node_or_null(node_path)
			var base_parent = base_scene_instance.get_node_or_null(scene_instance.get_path_to(node.get_parent()))
			if not base_parent: continue
			# Replace old node with new node.
			var base_node_index:int = -1
			var base_node_has_unique_name:bool = false
			# Remove old node.
			if base_node:
				base_node_index = base_node.get_index()
				base_node_has_unique_name = base_node.unique_name_in_owner
				base_node.unique_name_in_owner = false
				base_parent.remove_child(base_node)
				base_node.queue_free()
			# Add new node.
			node.get_parent().remove_child(node)
			node.owner = null # Unset owner.
			base_parent.add_child(node)
			base_parent.move_child(node, base_node_index) # Set proper order.
			node.owner = base_parent # Set owner to base parent.
			# Add unique name if the base node was using one.
			if base_node_has_unique_name:
				node.unique_name_in_owner = true

		# Remove nodes.
		for node_path:String in scene_instance.remove_node_paths:
			var node = base_scene_instance.get_node_or_null(node_path) as Node
			if not node: continue
			node.get_parent().remove_child(node)
			node.queue_free()

		# Pack the merged scene.
		res.pack(base_scene_instance)


	res.take_over_path(res_path)
	if not mod_instance.resources.has(res): mod_instance.resources.append(res)


func _load_mod_cfg(mod_instance:TesseractMod, res:ConfigFile, res_path:String, file_path:String) -> void:
	var res_err:Error = res.load(file_path)
	if res_err == OK:
		if res.has_section('SceneVariables'):
			var scene_path:String = res_path.trim_suffix('.cfg')
			mod_instance.scene_variables.set(scene_path, {})
			for key:String in res.get_section_keys('SceneVariables'):
				mod_instance.scene_variables[scene_path].set(key, res.get_value('SceneVariables',key))
			var scene = load(scene_path)
			if scene is PackedScene:
				var variable_setter := SceneVariableSetter.new()
				variable_setter.name = 'SceneVariableSetter'
				variable_setter.mod_instance_name = mod_instance.name
				var scene_instance:Node = scene.instantiate()
				scene_instance.add_child(variable_setter)
				variable_setter.owner = scene_instance
				scene.pack(scene_instance)
				scene.take_over_path(scene_path)
				if not mod_instance.resources.has(scene): mod_instance.resources.append(scene)
