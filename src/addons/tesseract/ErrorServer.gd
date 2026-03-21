## Tesseract error server.
extends Node

const error_strings:Array[String] = [
	'%s',
	'Failed to load game config.',
]

const warning_strings:Array[String] = [
	'%s',
	'Mod at "%s" is missing config file, unable to get details.',
]

const info_strings:Array[String] = [
	'%s',
]

signal error(code:int, args:Array)
signal warning(code:int, args:Array)
signal info(code:int, args:Array)
