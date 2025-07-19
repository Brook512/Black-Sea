extends CanvasLayer
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		self.visible = true
