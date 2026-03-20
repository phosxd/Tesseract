@tool
extends EditorPlugin

const singleton_name:String = 'TesseractAPI'
const singleton_path:String = 'res://addons/tesseract/API.gd'
var tab_instance: Control


func _enable_plugin() -> void:
	add_autoload_singleton(singleton_name, singleton_path)


func _disable_plugin() -> void:
	remove_autoload_singleton(singleton_name)


func _enter_tree() -> void:
	tab_instance = preload('res://addons/tesseract/Editor/main.tscn').instantiate()
	tab_instance.hide()
	EditorInterface.get_editor_main_screen().add_child(tab_instance)


func _exit_tree() -> void:
	if tab_instance:
		tab_instance.queue_free()


func _make_visible(visible:bool) -> void:
	if tab_instance:
		tab_instance.visible = visible


func _has_main_screen() -> bool:
	return true


func _get_plugin_name():
	return 'Tesseract'


func _get_plugin_icon() -> Texture2D:
	return preload('res://addons/tesseract/icon.svg')
