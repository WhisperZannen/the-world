extends Area2D

@export var city_id : String = "CITY_000" 

const ICON_CITY = preload("res://assets/icons/City.png")
const ICON_TOWN = preload("res://assets/icons/Town.png")

# 【新增】记录该阵营在 JSON 里的初始标准颜色
var base_color : Color

func _ready():
	# ==========================================
	# 【删除】删掉了原本 self.input_event 的连接
	# 因为我们不再把整个领土多边形作为城市的点击触发器了
	# ==========================================
	
	# ==========================================
	# 【新增】精准实体点击：只监听城堡图标上的 IconArea
	# ==========================================
	$BuildingIconsGroup/MainCityIcon/IconArea.input_event.connect(_on_icon_clicked)
	
	# ... 下方保留你原有的多边形画线、阵营染色、小镇生成的代码不变 ...
	var my_polygon = $CollisionPolygon2D.polygon
	$Line2D.points = my_polygon
	if my_polygon.size() > 0:
		$Line2D.add_point(my_polygon[0])
		
	if not DataManager.game_data["cities"].has(city_id):
		return
		
	var my_city_data = DataManager.game_data["cities"][city_id]
	$BuildingIconsGroup/NameLabel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	var target_pos = $BuildingIconsGroup/MainCityIcon.position
	$BuildingIconsGroup/NameLabel.position = target_pos + Vector2(-40, 70)
	$BuildingIconsGroup/NameLabel.text = my_city_data["name"]
	$BuildingIconsGroup/MainCityIcon.texture = ICON_CITY
	
	var my_civ_id = my_city_data["owner_civ"]
	var hex_color = DataManager.game_data["civilizations"][my_civ_id]["color"]
	base_color = Color(hex_color) 
	$Polygon2D.color = base_color
	$Polygon2D.polygon = my_polygon
	$Polygon2D.show()
	
	add_to_group("civ_territories")
	
	$BuildingIconsGroup/OptionalTowns.hide()
	var requested_towns = 0
	if my_city_data.has("town_count"):
		requested_towns = int(my_city_data["town_count"])
		
	var final_towns_to_load = clamp(requested_towns, 0, 3)
	
	if final_towns_to_load > 0:
		$BuildingIconsGroup/OptionalTowns.show()
		for i in range($BuildingIconsGroup/OptionalTowns.get_child_count()):
			var town_sprite = $BuildingIconsGroup/OptionalTowns.get_child(i)
			if i < final_towns_to_load:
				town_sprite.show()
				town_sprite.texture = ICON_TOWN
			else:
				town_sprite.hide()

# ==========================================
# 【新增】接收摄像机指令，动态改变透明度的函数
# ==========================================
func update_lod(alpha_multiplier: float):
	var new_color = base_color
	# 将原始透明度乘以系数。例如原透明度是 0.5，系数是 0.2，最终就是 0.1
	new_color.a = base_color.a * alpha_multiplier
	$Polygon2D.color = new_color

# ==========================================
# 【重构】专属的图标点击响应函数
# ==========================================
func _on_icon_clicked(_viewport, event, _shape_idx):
	# 只有当鼠标左键【按下】的那一瞬间，才触发
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("【精确命中实体】点击了城市: ", city_id)
		# ==========================================
		# 【新增】呼叫 UI 弹窗
		# 通过群组广播，把自己的 city_id 扔给 UI 面板
		# ==========================================
		get_tree().call_group("city_info_panel", "show_city_info", city_id)
		
# ==========================================
# 【修正】动态战火渲染逻辑
# 精准识别主城及当前处于激活状态的小镇，并分别点燃
# ==========================================
func set_war_status(is_burning: bool):
	# 1. 独立处理主城着火
	if $BuildingIconsGroup/MainCityIcon.has_node("FireEffect"):
		_toggle_fire($BuildingIconsGroup/MainCityIcon.get_node("FireEffect"), is_burning)
		
	# 2. 遍历处理村庄着火
	for i in range($BuildingIconsGroup/OptionalTowns.get_child_count()):
		var town_sprite = $BuildingIconsGroup/OptionalTowns.get_child(i)
		# 核心防呆：只有当该村庄本身是显示的（意味着 JSON 里有这个村庄），才允许着火！
		if town_sprite.visible and town_sprite.has_node("FireEffect"):
			_toggle_fire(town_sprite.get_node("FireEffect"), is_burning)

# 内部提取的火焰开关工具函数
func _toggle_fire(fire_node: AnimatedSprite2D, is_burning: bool):
	if is_burning:
		fire_node.show()
		fire_node.play("default")
	else:
		fire_node.stop()
		fire_node.hide()
