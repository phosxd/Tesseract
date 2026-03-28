## Tesseract mod instance.
@abstract class_name TesseractMod extends Object

## Full config file for this mod.
var config: ConfigFile
var scene_variables:Dictionary[String,Dictionary] = {}

## Unique mod identifier.
var id: String
## Mod display name.
var name: String
## Mod author. Optional.
var author: String
## Short description of the mod. Optional.
var description_short: String
## Long description of the mod. Optional.
var description_long: String
## Display string for the mod version.
var version_string:String = '1.0.0'

## The mod version.
var version_number:int = 1
## The game version(s) this mod was made for.
var for_game_versions:Array[int] = [1]
## The Tesseract version(s) this mod was made for.
var for_tesseract_verions:Array[int] = [1]
## Mod IDs this mod requires to work.
var mod_dependencies := PackedStringArray()

## All resources loaded from this mod & their paths relative to the mod's root directory.
var resources:Dictionary[String,Resource] = {}

## Called when the mod is initialized.
@abstract func init() -> void
## Called when the game sends this mod a signal.
## [param signal_name] & [param args] values depend on game documentation.
@abstract func recieve_signal(signal_name:String, ...args) -> void


## Releases all resources from the virtual filesystem, replaced by the next mod or the original resource.
## [br]
## [br]There is an issue that causes resources referenced in a scene to not get unloaded, even when the scene is loaded well after the resource has been removed.
## For this to happen 3 conditions must be met:
## [br]- This mod includes a resource that is referened in a scene.
## [br]- Another mod loaded after this mod modifies the scene containing the resource reference.
## [br]- The other mod does not get unloaded.
## [br]Keep this in mind when trying to unload a mod. For unloading to always work flawlessly 100% of the time, ALL mods should be unloaded, then reload the mods you want to keep.
## [br]
## [br]If [param also_free] is true, will delete the mod instance after unloading.
func unload(also_free:bool=false) -> void:
	for trace:Dictionary in TesseractAPI._resource_trace.duplicate():
		if trace.get('id') == id:
			var path = trace.get('path')
			TesseractAPI._resource_trace.erase(trace)
			# Get previous trace.
			var previous_trace_index:int = TesseractAPI._resource_trace.rfind_custom(func(item:Dictionary) -> bool:
				if item.get('path', ' ') == path:
					return item.get('res') is Resource
				return false
			)
			# If previous trace exists, replace with previous trace's resource.
			if previous_trace_index != -1:
				var previous_trace:Dictionary = TesseractAPI._resource_trace[previous_trace_index]
				var res = previous_trace.get('res')
				if res is Resource: res.take_over_path(path)

	if also_free:
		free.call_deferred()


## Adds a resource to the mod & loads it into the virtual file system.
func add_resource(relative_path:String, resource_path:String, resource:Resource) -> void:
	# If original resource not already stored in trace, add it.
	if TesseractAPI._can_trace_resources && ResourceLoader.exists(resource_path):
		var original_resource_trace_index:int = TesseractAPI._resource_trace.find_custom(func(item:Dictionary) -> bool:
			if item.get('id') != '@game': return false
			return item.get('path') == resource_path
		)
		if original_resource_trace_index == -1:
			var original_resource = load(resource_path)
			if original_resource:
				TesseractAPI._resource_trace.insert(0, {
					'id': '@game',
					'path': resource_path,
					'res': original_resource,
				})

	if not resources.values().has(resource):
		# Add to resource map & resource trace.
		resources.set(relative_path, resource)
		if TesseractAPI._can_trace_resources:
			TesseractAPI._resource_trace.append({
				'id': id,
				'path': resource_path,
				'res': resource,
			})
		# Take over path in virtual file system.
		resource.take_over_path(resource_path)


#region file system

## Returns all directories from this mod.
func get_directories() -> PackedStringArray:
	var result := PackedStringArray()
	for path:String in resources:
		var dir:String = path.trim_suffix('/'+path.split('/')[-1])
		if dir not in result: result.append(dir)

	return result


## Returns all directories under [param path] from this mod.
func get_directories_at(path:String) -> PackedStringArray:
	var result := PackedStringArray()
	var all_dirs:PackedStringArray = get_directories()
	for path_:String in all_dirs:
		if path_ == path or not path_.begins_with(path): continue
		var dir:String = path_.trim_prefix(path+'/')
		if not dir.is_empty() && dir not in result: result.append(dir)

	return result


## Returns all file paths under [param path] from this mod.
## To get the resources from these paths, use [param resources].
func get_files_at(path:String) -> PackedStringArray:
	var result := PackedStringArray()
	var all_files:Array[String] = resources.keys()
	for path_:String in all_files:
		if path_ == path or not path_.begins_with(path): continue
		var dir:String = path_.trim_prefix(path+'/')
		if not dir.is_empty() && not dir.contains('/') && dir not in result: result.append(dir)

	return result

#endregion


## Send a signal to the game.
func send_signal(name:String, ...args) -> Error:
	var sig = TesseractAPI.signal_map.get(name)
	if not sig:
		return ERR_DOES_NOT_EXIST
	sig = sig as Signal

	sig.emit.callv(args)

	return OK
