extends Node

func _init() -> void:
	TesseractAPI.init({
		'patches_path': 'user://PATCHES',
		'mods_path': 'user://MODS', # Load mods from user data.
		'load_mods_into_path': 'res://Example Game', # Load mod files into example game.
		'game_api_version': 1,

		'asset_map': {},
		'signal_map': {},

		'allow_pck_overwriting_files': true,
	})
	TesseractAPI.load_mods()
