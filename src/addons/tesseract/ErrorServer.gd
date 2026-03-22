## Tesseract error server.
extends Node

const error_strings:Array[String] = [
	'%s',
	'Failed to load game config.',
]

const warning_strings:Array[String] = [
	'%s',
	'Mod at "%s" is missing config file, unable to get details.',
	'Mod at "%s" is not compatible with game\'s API version.',
	'Mod at "%s" is not compatible with the current version of Tesseract.',
]

const info_strings:Array[String] = [
	'%s',
]

signal error(code:int, translations:Array)
signal warning(code:int, translations:Array)
signal info(code:int, translations:Array)
