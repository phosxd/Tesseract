@tool
extends EditorPlugin

const icon:Texture2D = preload('res://addons/Tesseract/icon.svg')
const singleton_names:Array[String] = ['TesseractAPI', 'TesseractErrorServer']
const singleton_paths:Array[String] = ['res://addons/Tesseract/API.gd', 'res://addons/Tesseract/ErrorServer.gd']
const filesystem_context_menu:GDScript = preload('res://addons/Tesseract/Editor/FileSystemContextMenu.gd')
const create_context_menu:GDScript = preload('res://addons/Tesseract/Editor/CreateContextMenu.gd')
var filesystem_context_menu_instance:EditorContextMenuPlugin = filesystem_context_menu.new(icon)
var create_context_menu_instance:EditorContextMenuPlugin = create_context_menu.new(icon)


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


func _exit_tree() -> void:
	# Remove plugins.
	remove_context_menu_plugin(filesystem_context_menu_instance)
	remove_context_menu_plugin(create_context_menu_instance)


func _has_main_screen() -> bool:
	return false


func _get_plugin_name():
	return 'Tesseract'


func _get_plugin_icon() -> Texture2D:
	return icon
