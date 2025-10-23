extends Node


var current_balance = 0


func _ready() -> void:
	Global.fish_collected.connect(on_fish_collected)
	
func on_fish_collected(fish):
	current_balance+=fish
	print(current_balance)
