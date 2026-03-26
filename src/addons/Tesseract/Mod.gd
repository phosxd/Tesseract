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

## Display string for the mod version.
var version_string:String = '1.0.0'
## The mod version.
var version_number:int = 1
## The game version(s) this mod was made for.
var for_game_versions:Array[int] = [1]
## The Tesseract version(s) this mod was made for.
var for_tesseract_verions:Array[int] = [1]

## Short description of the mod. Optional.
var description_short: String
## Long description of the mod. Optional.
var description_long: String

## All resources loaded from this mod & their paths relative to the mod's root directory.
var resources:Dictionary[String,Resource] = {}

## Called when the mod is initialized.
@abstract func init() -> void
## Called when the game sends this mod a signal.
## [param signal_name] & [param args] values depend on game documentation.
@abstract func recieve_signal(signal_name:String, ...args) -> void


## Send a signal to the game.
func send_signal(name:String, ...args) -> Error:
	var sig = TesseractAPI.signal_map.get(name)
	if not sig:
		return ERR_DOES_NOT_EXIST
	sig = sig as Signal

	sig.emit.callv(args)

	return OK


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
