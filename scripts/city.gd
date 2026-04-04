extends Area2D

@export var city_id : String = "CITY_000" 

const ICON_CITY = preload("res://assets/icons/City.png")
const ICON_TOWN = preload("res://assets/icons/Town.png")

func _ready():
	self.input_event.connect(_on_town_clicked)
	
	var my_polygon = $CollisionPolygon2D.polygon
	$Line2D.points = my_polygon
	if my_polygon.size() > 0:
		$Line2D.add_point(my_polygon[0])
		
	if not DataManager.game_data["cities"].has(city_id):
		return
		
	var my_city_data = DataManager.game_data["cities"][city_id]
	$BuildingIconsGroup/NameLabel.text = my_city_data["name"]
	$BuildingIconsGroup/MainCityIcon.texture = ICON_CITY
	
	var my_civ_id = my_city_data["owner_civ"]
	var hex_color = DataManager.game_data["civilizations"][my_civ_id]["color"]
	$Polygon2D.color = Color(hex_color)
	$Polygon2D.polygon = my_polygon
	$Polygon2D.show()
	
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

func _on_town_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("点击了城市: ", city_id)
