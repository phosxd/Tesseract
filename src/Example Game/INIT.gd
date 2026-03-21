extends Node

func _init() -> void:
	TesseractAPI.load_mods()
	for mod:TesseractMod in TesseractAPI.mod_instances.values():
		print('Mod successfuly added: '+mod.name)
