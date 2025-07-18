extends Node2D
@onready var setting_layer = $SettingLayer
var scene_map = {
	"EnterGame": "res://Scenes/StartAnim.tscn",
	"Settings": "res://scenes/SettingScene.tscn"
}

func _on_start_pressed() -> void:
	GlobalSceneManager.change_state(GlobalSceneManager.States.Begin)
	#GlobalSceneManager.goto_scene("res://scenes/StartAnim.tscn")

# 私有方法：获取场景路径
func _get_scene_path(key: String) -> String:
	return scene_map.get(key, "")


func _on_settings_pressed() -> void:
	setting_layer.visible = true



func _on_quit_pressed() -> void:
	get_tree().quit()



func _on_about_pressed() -> void:
	var blog_url: String = "https://brook512.github.io/DNG.github.io/"  # ← 换成你的博客地址

	var err := OS.shell_open(blog_url)
	if err != OK:
		push_error("无法打开浏览器，请手动访问: " + blog_url)  # 非必需的错误提示
