#statisch() : changes the label to another one with bigger font size and no updating text
#dynamisch() : changes the label to the original, updating one

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

func zeigMögNum(Num):
	if Num is Array:
		for i in range(Num.size()):
			$Control.get_child(Num[i] - 1).visible = true
	else:
		$Control.get_child(Num - 1).visible = true

func verMögNum():
	for i in range(9):
		$Control.get_child(i).visible = false

#nicht ideal, funktioniert aber immerhin
func statisch():
	$Label.visible = false
	$Label2.visible = true
	$Label2.text = $Label.text

func dynamisch():
	$Label.visible = true
	$Label2.visible = false

func get_color() -> Color:
	return $ColorRect.color

func set_color(color):
	$ColorRect.color = color
