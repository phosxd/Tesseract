@tool
extends TesseractEditorConfigSection


func _ready() -> void:
	if is_part_of_edited_scene(): return
	var delete_icon:Texture2D = self.get_theme_icon('Remove', 'EditorIcons')
	%Delete.icon = delete_icon

	for field:Node in $VBox.get_children():
		var setting_key = field.get('setting_key')
		if setting_key is not String: continue
		
		var value = TesseractConfigHandler.config_file.get_value(section_prefix+section, setting_key, '%Nil')
		if value is String && value == '%Nil': value = null
		field.set('enabled', value != null)
		if value != null:
			field.set('value', var_to_str(value))
