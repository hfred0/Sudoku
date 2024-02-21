extends Area2D

var index: int

func setzeText(text:String):
	$Label.text = text

func _on_input_event(_viewport, event, _shape_idx):
	if event:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == 1:
				get_parent().wertAnheben(index)
			elif event.button_index == 2:
				get_parent().wertSenken(index)
		get_parent().selectFeld = index

func get_color() -> Color:
	return $ColorRect.color

func set_color(color):
	$ColorRect.color = color
