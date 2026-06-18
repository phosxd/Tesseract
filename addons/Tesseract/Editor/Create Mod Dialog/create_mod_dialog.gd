@tool
extends Window

var parent_dir: String
var mod_config := ConfigFile.new()


func _on_submit_pressed() -> void:
	mod_config.load('res://addons/Tesseract/Templates/ModConfig.cfg')

	var mod_id:String = %ID.text
	var mod_name:String = %Name.text.replace('/','')
	var mod_author:String = %Author.text
	var include_init:bool = %'Include Init'.button_pressed
	var mod_dir:String = parent_dir+'/'+mod_id+'/'

	if DirAccess.dir_exists_absolute(mod_dir):
		printerr('Cannot create mod at "%s", directory already exists.' % mod_dir)
		return
	DirAccess.make_dir_absolute(mod_dir)

	# Set config fields.
	mod_config.set_value('TesseractMod', 'id', mod_id)
	mod_config.set_value('TesseractMod', 'name', mod_name)
	mod_config.set_value('TesseractMod', 'author', mod_author)
	mod_config.set_value('TesseractMod', 'real_path', mod_dir)
	mod_config.save(mod_dir+'/MOD.cfg')

	if include_init:
		var init_file := FileAccess.open(mod_dir+'INIT.gd', FileAccess.WRITE)
		init_file.store_string(FileAccess.get_file_as_string('res://addons/Tesseract/Templates/ModInit.gd'))
		init_file.close()

	queue_free()


func _on_cancel_pressed() -> void:
	queue_free()


func _on_close_requested() -> void:
	queue_free()
