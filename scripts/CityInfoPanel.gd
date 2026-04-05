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
	# 1. 防呆拦截：确保数据存在
	if not DataManager.game_data["cities"].has(target_city_id):
		return
		
	var city_data = DataManager.game_data["cities"][target_city_id]
	
	# 2. 注入数据到文字节点
	# 注意：如果你之前在 JSON 里没写 population(人口) 这些字段，
	# 用 .get("字段名", "默认值") 可以防止游戏崩溃，极其安全！
	$VBoxContainer/CityNameLabel.text = "城市： " + city_data["name"]
	$VBoxContainer/PopulationLabel.text = "人口： " + str(city_data.get("population", "未知"))
	$VBoxContainer/GarrisonLabel.text = "驻军： " + str(city_data.get("garrison", "无驻军"))
	
	# 3. 呼出面板
	show()

# ==========================================
# 关闭按钮逻辑
# ==========================================
func _on_close_pressed():
	hide()
