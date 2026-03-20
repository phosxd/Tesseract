## A simple mod that overrides the [code]ball.gd[/code] script to make it rainbow!
extends TesseractMod

func init() -> void:
	name = 'Rainbow Pong'
	author = 'PhosXD'
	version_string = '1.0.0'
	version_number = 1
	game_versions = [1]
	description_short = 'Makes the pong ball pretty :>. Also makes it impossible to win lol.'


func recieve_signal(_signal_name:String, ..._args) -> void:
	pass
