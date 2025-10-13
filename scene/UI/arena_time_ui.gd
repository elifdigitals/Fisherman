extends CanvasLayer


@onready var label: Label = %Label
@export var arena_time_manager: Node


func _process(delta):
	if arena_time_manager == null:
		return
	
	var time_elapsed = arena_time_manager.get_time_elapsed()
	label.text = format_time(time_elapsed)
	

func format_time (sec:int):
	var minutes = floor(sec/60)
	var remaining_sec = sec - (minutes * 60)
	return "%d:%02d" % [minutes, remaining_sec] 
