extends Node

func _init() -> void:
	TesseractErrorServer.info.connect(_on_tes_info)
	TesseractErrorServer.warning.connect(_on_tes_warning)
	TesseractErrorServer.error.connect(_on_tes_error)

	TesseractAPI.load_mods()
	for mod:TesseractMod in TesseractAPI.mod_instances.values():
		print('Mod successfuly added: '+mod.name)


func _on_tes_info(code:int, translations:Array) -> void:
	print(TesseractErrorServer.info_strings[code] % translations)


func _on_tes_warning(code:int, translations:Array) -> void:
	print(TesseractErrorServer.warning_strings[code] % translations)


func _on_tes_error(code:int, translations:Array) -> void:
	print(TesseractErrorServer.error_strings[code] % translations)
