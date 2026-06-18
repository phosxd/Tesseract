@tool
extends HBoxContainer

@export var setting_key:String = ''

@export var title:String = '':
	set(value):
		title = value
		%Title.text = title

@export var enabled:bool = false:
	set(v):
		enabled = v
		%Toggle.set_pressed_no_signal(v)

@export var value:String = '':
	set(v):
		value = v

		# Show error if mismatched type.
		if is_node_ready(): check_type()
		else:
			await ready
			check_type()

		if %Value.text != value: %Value.text = value

@export var value_type:Variant.Type:
	set(v):
		value_type = v
		%Title.tooltip_text = 'Expected type: %s' % type_string(value_type)


func _ready() -> void:
	if is_part_of_edited_scene(): return


func _on_value_text_changed(new_text:String) -> void:
	value = new_text


func check_type():
	var real_value = str_to_var(value)
	if typeof(real_value) != value_type:
		%Title.self_modulate = Color.RED
	else:
		%Title.self_modulate = Color.WHITE


func _on_toggle_toggled(toggled_on:bool) -> void:
	enabled = toggled_on
