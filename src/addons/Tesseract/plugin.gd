@tool
extends EditorPlugin

const icon:Texture2D = preload('res://addons/Tesseract/icon.svg')
const singleton_names:Array[String] = ['TesseractAPI', 'TesseractErrorServer']
const singleton_paths:Array[String] = ['res://addons/Tesseract/API.gd', 'res://addons/Tesseract/ErrorServer.gd']
const filesystem_context_menu:GDScript = preload('res://addons/Tesseract/Editor/FileSystemContextMenu.gd')
const create_context_menu:GDScript = preload('res://addons/Tesseract/Editor/CreateContextMenu.gd')
const tesseract_settings:PackedScene = preload('res://addons/Tesseract/Editor/Tesseract Settings/Tesseract Settings.tscn')
var filesystem_context_menu_instance:EditorContextMenuPlugin = filesystem_context_menu.new(icon)
var create_context_menu_instance:EditorContextMenuPlugin = create_context_menu.new(icon)
var tesseract_settings_instance:Control = tesseract_settings.instantiate()


func _enable_plugin() -> void:
	# Remove all autoloads.
	var autoloads:Dictionary[String,String] = {}
	for property:Dictionary in ProjectSettings.get_property_list():
		if property.name.begins_with('autoload/'):
			var autoload_name:String = property.name.split('/')[-1]
			var autoload_value = ProjectSettings.get_setting('autoload/%s' % autoload_name)
			autoloads.set(autoload_name, load(autoload_value.trim_prefix('*')).resource_path)
			remove_autoload_singleton(autoload_name)

	# Add plugin autoloads.
	for i:int in singleton_names.size():
		add_autoload_singleton(singleton_names[i], singleton_paths[i])

	# Re-add original autoloads after plugin autoloads.
	for key:String in autoloads:
		add_autoload_singleton(key, autoloads[key])


func _disable_plugin() -> void:
	# Remove autoloads.
	for i:int in singleton_names.size():
		remove_autoload_singleton(singleton_names[i])


func _enter_tree() -> void:
	# Add plugins.
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, filesystem_context_menu_instance)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE, create_context_menu_instance)
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, tesseract_settings_instance)


func _exit_tree() -> void:
	# Remove plugins.
	remove_context_menu_plugin(filesystem_context_menu_instance)
	remove_context_menu_plugin(create_context_menu_instance)
	tesseract_settings_instance.queue_free()


func _build() -> bool:
	# Get auto-exports.
	var auto_exports = TesseractConfigHandler.config_file.get_value('plugin', 'auto_exports')
	if auto_exports is not Array:
		printerr('Unexpected type "%s" in field "auto_exports" in Tesseract config.' % typeof(auto_exports))
		return false

	# Export every mod in auto exports.
	for item:Array in auto_exports:
		if item.size() != 3: continue
		var enabled = item[0]
		var output_path = item[1]
		var mod_path = item[2]
		if enabled is not bool or output_path is not String or mod_path is not String: continue
		if not enabled: continue
		print('Exporting mod "%s" to "%s".' % [mod_path,output_path])
		# Export package if output path has valid extension.
		if output_path.to_lower().get_extension() in ['tmod','zip']:
			filesystem_context_menu_instance._save_tmod(true, [output_path], 0, mod_path)
		# Export as folder if output path is not a valid file.
		else:
			output_path += '' if output_path.ends_with('/') else '/'
			mod_path += '' if mod_path.ends_with('/') else '/'
			# Throw error if output path is outside of user data & already exists.
			if (DirAccess.dir_exists_absolute(output_path) && not output_path.begins_with('user://')):
				printerr('Cannot overwrite directories outside of user data for safety reasons. Please delete the directory or choose an output in user data.')
				return false
			# Copy mod into output path.
			else:
				OS.move_to_trash(output_path)
				TesseractUtils.walk_dir(mod_path, func(file_path:String) -> void:
					if file_path.to_lower().get_extension() in ['uid']: return
					var relative_path:String = file_path.trim_prefix(mod_path)
					var destination:String = output_path+relative_path
					DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
					DirAccess.copy_absolute(file_path, destination)
				)

	return true


func _has_main_screen() -> bool:
	return false


func _get_plugin_name():
	return 'Tesseract'


func _get_plugin_icon() -> Texture2D:
	return icon
