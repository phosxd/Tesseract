extends EditorContextMenuPlugin

const create_mod_dialog = preload('res://addons/Tesseract/Editor/Create Mod Dialog/create_mod_dialog.tscn')
var icon: Texture2D


func _init(icon_:Texture2D) -> void:
	icon = icon_


func _popup_menu(paths:PackedStringArray) -> void:
	if paths.size() != 1: return
	var path:String = paths[0]
	# Ignore mod directories.
	if FileAccess.file_exists(path+'/MOD.cfg'): return

	add_context_menu_item('Mod...', create_mod.bind(path), icon)


func create_mod(paths:PackedStringArray, parent_dir:String) -> void:
	var create_mod_dialog_instance:Window = create_mod_dialog.instantiate()
	create_mod_dialog_instance.set('parent_dir', parent_dir)
	EditorInterface.popup_dialog_centered(create_mod_dialog_instance)
