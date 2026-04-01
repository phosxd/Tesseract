extends EditorContextMenuPlugin

var icon: Texture2D


func _init(icon_:Texture2D) -> void:
	icon = icon_


func _popup_menu(paths:PackedStringArray) -> void:
	if paths.size() != 1: return
	var path:String = paths[0]
	if not path.ends_with('/'): return

	# If directory is a mod, show mod options.
	if FileAccess.file_exists(path+'MOD.cfg'):
		add_context_menu_item('Export TMOD', export_tmod.bind(path), icon)


func export_tmod(paths:PackedStringArray, mod_dir:String) -> void:
	DisplayServer.file_dialog_show(
		'Export TMOD', # Title
		OS.get_user_data_dir(), # Starting directory
		'%s.tmod' % mod_dir.rstrip('/').get_file(), # Starting file name
		false, # Show hidden items
		DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, # Dialog mode
		['*.tmod','*.zip'], # File filters
		_save_tmod.bind(mod_dir) # Callback
	)


func _save_tmod(_status:bool, selected_paths:PackedStringArray, _selected_filter_index:int, mod_dir:String) -> void:
	if selected_paths.size() != 1:
		printerr('Please select only 1 location to save TMOD file to.')
		return
	var save_path:String = selected_paths[0]

	var writer := ZIPPacker.new()
	# Create ZIP file at selected location.
	writer.open(save_path, ZIPPacker.APPEND_CREATE)
	TesseractUtils.walk_dir(mod_dir, func(path:String) -> void:
		if path.get_extension() == 'uid': return # Exclude UID files.
		# Write file into ZIP.
		var relative_path:String = path.trim_prefix(mod_dir)
		writer.start_file(relative_path)
		writer.write_file(FileAccess.get_file_as_bytes(path))
		writer.close_file()
	)
	writer.close()
