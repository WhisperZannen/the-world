extends Control

func _ready():
	# 1. 游戏启动时，自动隐藏面板
	hide()
	
	# 2. 绑定关闭按钮的点击事件 (假设你的按钮叫 CloseButton)
	$CloseButton.pressed.connect(_on_close_pressed)
	
	# 3. 【核心机制】将自己加入 "city_info_panel" 广播群组，全图唯一接收器
	add_to_group("city_info_panel")

# ==========================================
# 接收大地图发来的城市 ID，并渲染数据
# ==========================================
func show_city_info(target_city_id: String):
	if not DataManager.game_data["cities"].has(target_city_id):
		return
		
	var city_data = DataManager.game_data["cities"][target_city_id]
	
	# --- 新增：跨表查询文明名称 ---
	var civ_id = city_data["owner_civ"]
	var civ_name = DataManager.game_data["civilizations"][civ_id]["name"]
	
	$VBoxContainer/CityNameLabel.text = "城市： " + city_data["name"]
	# 在 UI 中显示归属信息
	$VBoxContainer/OwnerLabel.text = "归属： " + civ_name 
	
	$VBoxContainer/PopulationLabel.text = "人口： " + str(city_data.get("population", "未知"))
	show()

# ==========================================
# 关闭按钮逻辑
# ==========================================
func _on_close_pressed():
	hide()
