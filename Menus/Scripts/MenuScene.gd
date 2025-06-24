extends Node2D

var scene_map = {
	"EnterGame": "res://scenes/world.tscn",
	"Settings": "res://scenes/SettingScene.tscn"
}

func _on_start_pressed() -> void:
	switch_scene("EnterGame")

func switch_scene(scene_key: String) -> void:
	var path = _get_scene_path(scene_key)
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
		print("场景切换至: " + scene_key)
	else:
		push_error("场景路径无效: " + path)

# 私有方法：获取场景路径
func _get_scene_path(key: String) -> String:
	return scene_map.get(key, "")


func _on_settings_pressed() -> void:
	switch_scene("Setiings")



func _on_quit_pressed() -> void:
	get_tree().quit()
