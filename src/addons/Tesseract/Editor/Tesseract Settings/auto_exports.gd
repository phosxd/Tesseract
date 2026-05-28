@tool
extends FoldableContainer

const item_scene:PackedScene = preload('res://addons/Tesseract/Editor/Tesseract Settings/Auto Export Item.tscn')
var auto_exports:Array[Array] = []


func _ready() -> void:
	var config_auto_exports = TesseractConfigHandler.config_file.get_value('plugin', 'auto_exports', [])
	for item:Array in config_auto_exports:
		if item.size() != 3: continue
		var enabled = item[0]
		var output_path = item[1]
		var mod_path = item[2]
		if enabled is not bool or output_path is not String or mod_path is not String: continue
		add_item(enabled, output_path, mod_path)


func save() -> void:
	TesseractConfigHandler.config_file.set_value('plugin', 'auto_exports', auto_exports)
	TesseractConfigHandler.save()


func add_item(enabled:bool, output_path:String, mod_path:String) -> void:
	var item_data:Array = [enabled, output_path, mod_path]
	auto_exports.append(item_data)

	var item:Control = item_scene.instantiate()
	item.init(output_path, mod_path)
	item.toggled.connect(func(on:bool) -> void:
		item_data[0] = on
		save()
	)
	item.deleted.connect(func() -> void:
		auto_exports.erase(item_data)
		save()
	)
	item.applied.connect(func(applied_output_path:String, applied_mod_path:String) -> void:
		item_data[1] = applied_output_path
		item_data[2] = applied_mod_path
		save()
	)
	item.moved.connect(func(up:bool) -> void:
		var item_index:int = auto_exports.find(item_data)
		if item_index == -1: return
		item_index += -1 if up else 1
		if item_index < 0 or item_index >= auto_exports.size(): return
		auto_exports.erase(item_data)
		auto_exports.insert(item_index, item_data)
		save()
		%'AE List'.move_child(item, item.get_index() + (-1 if up else 1))
	)

	save()
	%'AE List'.add_child(item)


func _on_ae_output_path_text_changed(new_text:String) -> void:
	%'AE Add'.disabled = (new_text.is_empty() or %'AE Mod Path'.text.is_empty())


func _on_ae_mod_path_text_changed(new_text:String) -> void:
	%'AE Add'.disabled = (new_text.is_empty() or %'AE Output Path'.text.is_empty())


func _on_ae_add_pressed() -> void:
	add_item(true, %'AE Output Path'.text, %'AE Mod Path'.text)
	%'AE Add'.disabled = true
	%'AE Output Path'.text = ''
	%'AE Mod Path'.text = ''
