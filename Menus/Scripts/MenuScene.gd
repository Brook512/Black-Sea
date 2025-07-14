extends Node2D

var scene_map = {
	"EnterGame": "res://Scenes/StartAnim.tscn",
	"Settings": "res://scenes/SettingScene.tscn"
}

func _on_start_pressed() -> void:
	GlobalSceneManager.change_state(GlobalSceneManager.States.Normal)
	GlobalSceneManager.goto_scene("res://scenes/StartAnim.tscn")

# 私有方法：获取场景路径
func _get_scene_path(key: String) -> String:
	return scene_map.get(key, "")


func _on_settings_pressed() -> void:
	GlobalSceneManager.change_state(GlobalSceneManager.States.Settings)



func _on_quit_pressed() -> void:
	get_tree().quit()
