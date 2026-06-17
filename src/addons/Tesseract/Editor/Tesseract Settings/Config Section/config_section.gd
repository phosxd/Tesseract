@tool
class_name TesseractEditorConfigSection extends FoldableContainer

const field_scene := preload('res://addons/Tesseract/Editor/Tesseract Settings/Config Section/field.tscn')

@export var section:String = 'game':
	set(v):
		section = v
		
		if is_node_ready():
			if %Name.text != section: %Name.text = section
			title = section_prefix+section
		else:
			await ready
			if %Name.text != section: %Name.text = section
			title = section_prefix+section

@export var section_prefix:String = '':
	set(v):
		section_prefix = v
		title = section_prefix+section

@export var auto_populate:bool = true

@export var allow_deleting_section:bool = true:
	set(v):
		allow_deleting_section = v

		if is_node_ready():
			%Delete.disabled = not v
		else:
			await ready
			%Delete.disabled = not v

@export var allow_changing_section_name:bool = true:
	set(v):
		allow_changing_section_name = v

		if is_node_ready():
			%Name.editable = v
		else:
			await ready
			%Name.editable = v

@export var can_disable_fields:bool = true


func save() -> void:
	section = %Name.text
	var real_section:String = section_prefix+section

	for field:Node in $VBox.get_children():
		var enabled = field.get('enabled')
		var key = field.get('setting_key')
		var value = field.get('value')
		var value_type = field.get('value_type')
		if enabled is not bool or key is not String or value is not String or value_type is not Variant.Type: continue

		# Remove value if disabled.
		if not enabled:
			if TesseractConfigHandler.config_file.has_section_key(real_section, key):
				TesseractConfigHandler.config_file.erase_section_key(real_section, key)
			continue

		# Set value in config.
		var real_value = str_to_var(value)
		if typeof(real_value) != value_type: continue
		TesseractConfigHandler.config_file.set_value(real_section, key, real_value)

	TesseractConfigHandler.save()


func add_field(key:String, value:Variant, value_type:Variant.Type) -> void:
	var field:Node = field_scene.instantiate()
	field.title = key
	field.setting_key = key
	field.value_type = value_type
	field.value = var_to_str(value)
	field.enabled = true
	if not can_disable_fields:
		field.get_node('%Toggle').hide()
	$VBox.add_child(field)
	$VBox.move_child(field, 1)


func _ready() -> void:
	if is_part_of_edited_scene(): return
	var delete_icon:Texture2D = self.get_theme_icon('Remove', 'EditorIcons')
	%Delete.icon = delete_icon

	if not auto_populate: return
	var real_section:String = section_prefix+section
	for key:String in TesseractConfigHandler.config_file.get_section_keys(real_section):
		var value = TesseractConfigHandler.config_file.get_value(real_section, key, null)
		if value != null:
			var value_type:Variant.Type = typeof(value)
			add_field(key, value, value_type)


func _on_apply_pressed() -> void:
	save()


func _on_name_text_changed(new_text:String) -> void:
	if not allow_changing_section_name: return
	section = new_text


func _on_delete_pressed() -> void:
	TesseractConfigHandler.config_file.erase_section(section_prefix+section)
	TesseractConfigHandler.save()
	queue_free()
