@tool
extends Control

signal deleted
signal applied
signal toggled(on:bool)
signal moved(up:bool)


func _ready() -> void:
	var arrow_icon:Texture2D = self.get_theme_icon('ArrowRight', 'EditorIcons')
	var delete_icon:Texture2D = self.get_theme_icon('Remove', 'EditorIcons')
	var move_up_icon:Texture2D = self.get_theme_icon('MoveUp', 'EditorIcons')
	var move_down_icon:Texture2D = self.get_theme_icon('MoveDown', 'EditorIcons')
	%'Arrow Texture'.texture = arrow_icon
	%Delete.icon = delete_icon
	%'Move Up'.icon = move_up_icon
	%'Move Down'.icon = move_down_icon


func init(output_path:String, mod_path:String) -> void:
	%'Mod Path'.text = mod_path
	%'Output Path'.text = output_path


func _on_delete_pressed() -> void:
	deleted.emit()
	self.queue_free()


func _on_mod_path_text_changed(new_text:String) -> void:
	%Apply.disabled = false


func _on_output_path_text_changed(new_text:String) -> void:
	%Apply.disabled = false


func _on_apply_pressed() -> void:
	%Apply.disabled = true
	applied.emit(%'Output Path'.text, %'Mod Path'.text)


func _on_move_up_pressed() -> void:
	moved.emit(true)


func _on_move_down_pressed() -> void:
	moved.emit(false)


func _on_enabled_toggled(toggled_on:bool) -> void:
	toggled.emit(toggled_on)
