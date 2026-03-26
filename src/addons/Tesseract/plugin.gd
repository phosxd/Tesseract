@tool
extends EditorPlugin

const singleton_names:Array[String] = ['TesseractAPI', 'TesseractErrorServer']
const singleton_paths:Array[String] = ['res://addons/Tesseract/API.gd', 'res://addons/Tesseract/ErrorServer.gd']
#var tab_instance: Control


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
	for i:int in singleton_names.size():
		remove_autoload_singleton(singleton_names[i])


func _enter_tree() -> void:
	pass
	#tab_instance = preload('res://addons/tesseract/Editor/main.tscn').instantiate()
	#tab_instance.hide()
	#EditorInterface.get_editor_main_screen().add_child(tab_instance)


func _exit_tree() -> void:
	pass
	#if tab_instance:
		#tab_instance.queue_free()


func _make_visible(visible:bool) -> void:
	pass
	#if tab_instance:
		#tab_instance.visible = visible


func _has_main_screen() -> bool:
	return false


func _get_plugin_name():
	return 'Tesseract'


func _get_plugin_icon() -> Texture2D:
	return preload('res://addons/Tesseract/icon.svg')
