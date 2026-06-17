@tool
extends FoldableContainer

const field_scene := preload('res://addons/Tesseract/Editor/Tesseract Settings/Config Section/field.tscn')

@export var section:String = 'game':
	set(v):
		section = v
		
		if is_node_ready():
			%Name.text = section
			title = section
		else:
			await ready
			%Name.text = section
			title = section


func save() -> void:
	section = %Name.text

	for field:Node in $VBox:
		var enabled = field.get('enabled')
		var key = field.get('setting_key')
		var value = field.get('value')
		var value_type = field.get('value_type')
		if enabled is not bool or key is not String or value is not String or value_type is not Variant.Type: continue

		# Delete value if disabled.
		if not enabled:
			TesseractConfigHandler.config_file.set_value(section, key, null)
			continue

		# Get variant from string value & check it's type.
		var real_value = str_to_var(value)
		if typeof(real_value) != value_type: continue
		# Set value in config.
		TesseractConfigHandler.config_file.set_value(section, key, real_value)

	TesseractConfigHandler.save()


func add_field(key:String, value:Variant, value_type:Variant.Type) -> void:
	var field:Node = field_scene.instantiate()
	field.title = key
	field.setting_key = key
	field.value_type = value_type
	field.value = var_to_str(value)
	field.enabled = true
	$VBox.add_child(field)
	$VBox.move_child(field, 1)


func _ready() -> void:
	if is_part_of_edited_scene(): return
	for key:String in TesseractConfigHandler.config_file.get_section_keys(section):
		var value = TesseractConfigHandler.config_file.get_value(section, key)
		var value_type:Variant.Type = typeof(value)
		add_field(key, value, value_type)


func _on_apply_pressed() -> void:
	save()


func _on_name_text_changed(new_text:String) -> void:
	section = new_text
