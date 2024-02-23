extends Button

func _on_mouse_exited():
	release_focus()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed:
			release_focus()
