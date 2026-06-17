@tool
extends ScrollContainer

const config_section_scene := preload('res://addons/Tesseract/Editor/Tesseract Settings/Config Section/config_section.tscn')


func _ready() -> void:
	if is_part_of_edited_scene(): return
	for section:String in TesseractConfigHandler.config_file.get_sections():
		var config_section:Node = config_section_scene.instantiate()
		config_section.section = section
		$VBox.add_child(config_section)
		$VBox.move_child(config_section, 1)
