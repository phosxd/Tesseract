## Tesseract error server.
extends Node

const error_strings:Array[String] = [
	'%s',
	'Failed to load game config.',
	'Mod at "%s": Missing config file, unable to get details',
	'Mod at "%s": Invalid or overlapping ID. Make sure the mod\'s ID is not the same as another mod.',
	'Mod "%s": Missing depedency "%s", ensure the dependency is loaded before this mod.',
	'Mod "%s": Not compatible with game\'s API version.',
	'Mod "%s": Not compatible with the current version of Tesseract.',
	'Mod "%s": Failed to load "%s" as scripts have been disabled.',
	'Mod "%s": Script "%s" contains one or more blocked keywords.',
	'Mod "%s": Scene at "%s" contains one or more built-in scripts utilizing "func _init" override. For security reasons, this is not allowed.',
]

const warning_strings:Array[String] = [
	'%s',
]

const info_strings:Array[String] = [
	'%s',
]

signal error(code:int, translations:Array)
signal warning(code:int, translations:Array)
signal info(code:int, translations:Array)
