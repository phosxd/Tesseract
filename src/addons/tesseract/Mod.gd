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

## All resources loaded from this mod.
var resources:Array[Resource] = []

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
