@tool
extends ScrollContainer

const config_section_scene := preload('res://addons/Tesseract/Editor/Tesseract Settings/Config Section/config_section.tscn')
const config_section_mod_type_scene := preload('res://addons/Tesseract/Editor/Tesseract Settings/Config Section/config_section_mod_type.tscn')


func _ready() -> void:
	if is_part_of_edited_scene(): return
	for section:String in TesseractConfigHandler.config_file.get_sections():
		if section in ['plugin']: continue
		var config_section: Node
		if section.begins_with('MOD TYPE: '):
			config_section = config_section_mod_type_scene.instantiate()
			config_section.section = section.trim_prefix('MOD TYPE: ')
		else:
			config_section = config_section_scene.instantiate()
			config_section.section = section

		$VBox.add_child(config_section)
		$VBox.move_child(config_section, 1)


func _on_add_mod_type_pressed() -> void:
	var config_section:Node = config_section_mod_type_scene.instantiate()
	config_section.section = 'new_type_%s' % randi_range(10_000,99_999)
	$VBox.add_child(config_section)
	$VBox.move_child(config_section, 1)
