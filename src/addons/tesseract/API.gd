## Bridge between your game & mods.
##
## This is where you can set options for your game to determine how mods will interact with it.
##
## Set [param game_api_version] to distinguish between major API versions (E.g. if you changed signal map, asset map or your project file structure).
## Set [param asset_map] to provide assets that mods can use.
## Set [param signal_map] to provide signals that mods can call.
extends Node

## Whether or not PCKs are allowed to overwrite resources.
var allow_pck_overwriting_files:bool = true
## Assets available to mods.
var asset_map:Dictionary[String,Variant] = {}
## Signals available to mods.
var signal_map:Dictionary[String,Signal] = {}

## Path to load PCK mods from.
var patches_path:String = 'user://PATCHES'
## Path to load mods from.
var mods_path:String = 'user://MOD'
## Path in which mod files get loaded into.
var load_mods_into_path:String = 'res://'

## The game's API version. Only increment this when you have made breaking changes in file structure or API.
var game_api_version:int = 1

## Every loaded mod instance.
var mod_instances:Dictionary[String,TesseractMod] = {}


## Set API variables via Dictionary.
func init(options:Dictionary[String,Variant]) -> void:
	for key:String in options:
		set(key, options[key])


func load_mods() -> void:
	# Get PCK patch paths.
	var pck_paths := PackedStringArray()
	TesseractUtils.walk_dir(patches_path, func(file_path:String) -> void:
		pck_paths.append(file_path)
	)
	# Load PCK mods in alphabetical order.
	pck_paths.sort()
	for path:String in pck_paths:
		var succeeded:bool = ProjectSettings.load_resource_pack(path, allow_pck_overwriting_files)
		if not succeeded:
			continue

	# Get mod paths.
	var mod_paths := PackedStringArray()
	for dir_path:String in DirAccess.get_directories_at(mods_path):
		mod_paths.append(mods_path+'/'+dir_path)

	# Load mods in alphabetical order.
	mod_paths.sort()
	for mod_path:String in mod_paths:
		# Get mod script.
		var mod_script_path:String = mod_path+'/'+'MOD.gd'
		var mod_script = load(mod_script_path) as GDScript
		if mod_script is not GDScript: continue
		var mod_is_valid:bool = mod_script.get_base_script() == TesseractMod
		if not mod_is_valid: continue
		# Walk through all resources in the mod & load them.
		var resources:Array[Resource] = []
		TesseractUtils.walk_dir(mod_path, func(file_path:String) -> void:
			var relative_path:String = file_path.trim_prefix(mod_path+'/')
			if relative_path == 'MOD.gd': return
			var ext:String = file_path.split('.')[-1]
			if ext in ['tres','res','tscn','scn','gd','gdshader','theme','material']:
				var res = load(file_path)
				if res:
					res.take_over_path(load_mods_into_path+('' if load_mods_into_path.ends_with('/') else '/')+'%s' % relative_path)
					resources.append(res)
		)
		# Initialize mod.
		var mod_instance = mod_script.new() as TesseractMod
		mod_instance.resources = resources
		mod_instance.init()
		mod_instances.set(mod_instance.name, mod_instance)


func _ready() -> void:
	pass
