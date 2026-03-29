## Main interface between your game & Tesseract.
##
## Call [param load_mods] to load all mods at once, or you can call [param load_mod] to load mods individually.
##[br]
##[br]Set [param signal_map] to provide signals that mods can call.
extends Node

## Tesseract API version.
const api_version:int = 1
const resource_extensions:Array[String] = [
	# Standard resource.
	'tres','res',
	# Scene.
	'tscn',
	'scn',
	# Script.
	'gd',
	# Shader.
	'gdshader',
	'gdshaderinc',
	# Theme / stylebox.
	'theme',
	'stylebox',
	# Material.
	'material',
	# Misc.
	'anim',
	'occ',
	'shape',
	'json',
]
const audio_extensions:Array[String] = ['wav','mp3','ogg','flac']
const image_extensions:Array[String] = ['svg','png','jpg','jpeg']

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

var blocked_script_keywords: Array:
	set(value):
		blocked_script_keywords = value
		config.set_value('game', 'blocked_script_keywords', value)
	get():
		return config.get_value('game', 'blocked_script_keywords', [])

#endregion

var config_loaded:bool = false
## Every loaded mod instance.
var mod_instances:Dictionary[String,TesseractMod] = {}
var _resource_trace:Array[Dictionary] = []
var _can_trace_resources:bool = true


func _init() -> void:
	var err:Error = config.load('res://addons/Tesseract/plugin.cfg')
	if err != OK:
		return
	config_loaded = true


func _ready() -> void:
	if not config_loaded:
		TesseractErrorServer.error.emit(1)


## Set API variables via Dictionary.
func init(options:Dictionary[String,Variant]) -> void:
	for key:String in options:
		set(key, options[key])


## Load all mods & PCK patches.
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
			load_mod(mod_path)


## Load a mod from the [param path].
func load_mod(path:String) -> void:
	# Get mod config.
	var mod_config_path:String = path+'/MOD.cfg'
	var mod_config := ConfigFile.new()
	var mod_config_err:Error = mod_config.load(mod_config_path)
	if mod_config_err != OK:
		TesseractErrorServer.error.emit(2, [path])
		if not allow_mods_without_details: return
	# Check ID is valid.
	var id = mod_config.get_value('TesseractMod', 'id', '')
	if id is not String or id.is_empty() or id in mod_instances:
		TesseractErrorServer.error.emit(3, [path])
		return
	# Check mod dependencies are loaded.
	var mod_dependencies = mod_config.get_value('TesseractMod', 'mod_dependencies', [])
	if mod_dependencies is Array && not mod_dependencies.is_empty():
		for dependency in mod_dependencies:
			if dependency is not String: continue
			if dependency not in mod_instances:
				TesseractErrorServer.error.emit(4, [id,dependency])
				return

	# Get game configuration for mods of this type.
	var mod_type:String = mod_config.get_value('TesseractMod', 'type', '')
	var mod_type_section:String = 'MOD TYPE: %s' % mod_type

	var cfg_game_api_version = config.get_value(mod_type_section, 'api_version', game_api_version)
	var cfg_load_into_path:String = config.get_value(mod_type_section, 'load_mods_into_path', load_mods_into_path)
	var cfg_allow_mod_scripts:bool = config.get_value(mod_type_section, 'allow_mod_scripts', allow_mod_scripts)
	var cfg_blocked_script_keywords:Array = config.get_value(mod_type_section, 'blocked_script_keywords', blocked_script_keywords)
	# Check version compatibility.
	var for_game_versions:Array[Variant] = mod_config.get_value('TesseractMod', 'for_game_versions', [cfg_game_api_version])
	var for_tesseract_versions:Array[Variant] = mod_config.get_value('TesseractMod', 'for_tesseract_versions', [api_version])
	if cfg_game_api_version not in for_game_versions:
		TesseractErrorServer.error.emit(5, [id])
		return
	if api_version not in for_tesseract_versions :
		TesseractErrorServer.error.emit(6, [id])
		return

	# Get mod script.
	var mod_script_path:String = path+'/INIT.gd'
	var mod_script
	if cfg_allow_mod_scripts && FileAccess.file_exists(mod_script_path):
		mod_script = load(mod_script_path) as GDScript
		if not _is_script_compliant(id, mod_script, cfg_blocked_script_keywords): mod_script = null
	# If none found or is invalid, use backup script.
	if mod_script is not GDScript or mod_script.get_base_script() != TesseractMod:
		mod_script = load('res://addons/Tesseract/ModScript.gd')
	var mod_instance = mod_script.new() as TesseractMod

	# Set config values to the mod instance.
	mod_instance.mod_dependencies = mod_dependencies
	mod_instance.config = mod_config
	for key:String in mod_config.get_section_keys('TesseractMod'):
		mod_instance.set(key, mod_config.get_value('TesseractMod', key))

	# Walk through all resources in the mod & load them.
	var resources:Array[Resource] = []
	TesseractUtils.walk_dir(path, _load_into_mod.bind(path, mod_instance, {
		'load_into_path': cfg_load_into_path,
		'allow_mod_scripts': cfg_allow_mod_scripts,
		'blocked_script_keywords': cfg_blocked_script_keywords,
	},''))
	# Initialize mod.
	mod_instance.init()
	mod_instances.set(mod_instance.id, mod_instance)


func _is_script_compliant(mod_id:String, script:Script, blocked_keywords:Array, emit_error:bool=false, file_path:String='') -> bool:
	var source_code = script.source_code
	if not blocked_keywords.is_empty():
		for keyword in blocked_keywords:
			if keyword is not String: continue
			if keyword in source_code:
				if emit_error && not file_path.is_empty(): TesseractErrorServer.error.emit(8, [mod_id,file_path])
				return false
	return true


func _load_into_mod(file_path:String, mod_path:String, mod_instance:TesseractMod, cfg:Dictionary, requested_by:String='') -> void:
	var relative_path:String = file_path.trim_prefix(mod_path+'/')
	if relative_path in ['INIT.gd','MOD.cfg']: return
	if relative_path in mod_instance.resources.keys(): return
	var res_path:String = 'res://'+cfg.load_into_path+('' if cfg.load_into_path.ends_with('/') or cfg.load_into_path.is_empty() else '/')+'%s' % relative_path
	var ext:String = file_path.split('.')[-1]
	# Load resource.
	if ext in resource_extensions:
		var res = load(file_path)
		if res is Script:
			_load_mod_script(mod_instance, relative_path, res, res_path, file_path, cfg)
		elif res is PackedScene:
			_load_mod_scene(mod_instance, relative_path, res, res_path, file_path, cfg)
		elif res:
			_load_mod_resource(mod_instance, relative_path, res, res_path)
	# Load audio.
	elif ext in audio_extensions:
		_load_mod_audio(mod_instance, relative_path, res_path, file_path, ext)
	# Load image.
	elif ext in image_extensions:
		var res = Image.load_from_file(file_path)
		if res:
			mod_instance.add_resource(relative_path, res_path, res)
	# Load config.
	elif ext in ['cfg']:
		var res = ConfigFile.new()
		_load_mod_cfg(mod_instance, relative_path, res, res_path, file_path)


func _load_mod_resource(mod_instance:TesseractMod, relative_path:String, res:Resource, res_path:String) -> void:
	mod_instance.add_resource(relative_path, res_path, res)


func _load_mod_audio(mod_instance:TesseractMod, relative_path:String, res_path:String, file_path:String, ext:String) -> void:
	var res
	match ext:
		'wav':
			res = AudioStreamWAV.load_from_file(file_path)
		'mp3':
			res = AudioStreamMP3.load_from_file(file_path)
		'ogg':
			res = AudioStreamOggVorbis.load_from_file(file_path)
		# For use with AudioStreamFLAC module.
		'flac':
			var class_exists = ClassDB.class_exists('AudioStreamFLAC')
			if class_exists:
				res = ClassDB.class_call_static('AudioStreamFLAC', 'new')
				res.data = FileAccess.get_file_as_bytes(file_path)
	if not res: return
	mod_instance.add_resource(relative_path, res_path, res)


func _load_mod_script(mod_instance:TesseractMod, relative_path:String, res:Script, res_path:String, file_path:String, cfg:Dictionary) -> void:
	if not cfg.allow_mod_scripts: return
	if not _is_script_compliant(mod_instance.id, res, cfg.blocked_script_keywords, true, file_path): return
	mod_instance.add_resource(relative_path, res_path, res)


func _load_mod_scene(mod_instance:TesseractMod, relative_path:String, res:PackedScene, res_path:String, file_path:String, cfg:Dictionary) -> void:
	var scene_string:String = var_to_str(res)
	if not cfg.allow_mod_scripts && scene_string.contains('Object(GDScript'):
		TesseractErrorServer.error.emit(7, [mod_instance.id,file_path])
		return
	if scene_string.contains('func _init'):
		TesseractErrorServer.error.emit(9, [mod_instance.id,file_path])
		return

	var scene_instance:Node = res.instantiate()

	# Apply mod id to asset linker nodes.
	for node in scene_instance.find_children('*'):
		var script = node.get_script()
		if script is Script && script.resource_path.contains('::'):
			var end = '::'+script.resource_path.split('::')[1]
			if not _is_script_compliant(mod_instance.id, script, cfg.blocked_script_keywords, true, file_path): return
		if node is not AssetLinker: continue
		node = node as AssetLinker
		node.mod_id = mod_instance.id

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

		# Pack the merged scene then delete the instances.
		res.pack(base_scene_instance)
		scene_instance.queue_free()
		base_scene_instance.queue_free()

	mod_instance.add_resource(relative_path, res_path, res)


func _load_mod_cfg(mod_instance:TesseractMod, relative_path:String, res:ConfigFile, res_path:String, file_path:String) -> void:
	var res_err:Error = res.load(file_path)
	if res_err != OK: return
	var parent_path:String = res_path.trim_suffix('.cfg')

	if res.has_section('SceneVariables'):
		mod_instance.scene_variables.set(parent_path, {})
		for key:String in res.get_section_keys('SceneVariables'):
			mod_instance.scene_variables[parent_path].set(key, res.get_value('SceneVariables',key))

		var scene = load(parent_path)
		if scene is PackedScene:
			var variable_setter := SceneVariableSetter.new()
			variable_setter.name = 'SceneVariableSetter'
			variable_setter.mod_id = mod_instance.id
			var scene_instance:Node = scene.instantiate()
			scene_instance.add_child(variable_setter)
			variable_setter.owner = scene_instance

			# Pack the scene then delete the instance.
			scene.pack(scene_instance)
			scene_instance.queue_free()

			mod_instance.add_resource(relative_path, parent_path, scene)
