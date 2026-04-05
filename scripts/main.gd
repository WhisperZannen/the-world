extends Node2D

func _ready():
	call_deferred("draw_empire_borders")

func draw_empire_borders():
	var civ_polygons = {}
	
	for child in get_children():
		# 核心修改 1：现在找的是 city_id，不是 town_id
		if "city_id" in child:
			var c_id = child.city_id
			
			# 核心修改 2：查的是 cities 表
			if DataManager.game_data["cities"].has(c_id):
				# 核心修改 3：直接获取控制方文明，省去了省份这一层
				var civ_id = DataManager.game_data["cities"][c_id]["owner_civ"]
				
				var local_poly = child.get_node("CollisionPolygon2D").polygon
				var global_poly = PackedVector2Array()
				
				for pt in local_poly:
					global_poly.append(child.position + pt)
					
				# 安全锁：只有当多边形的顶点数大于等于3（构成一个面）时，才参与国界线合并
				if global_poly.size() >= 3:
					if not civ_polygons.has(civ_id):
						civ_polygons[civ_id] = []
					civ_polygons[civ_id].append(global_poly)
				
	for civ_id in civ_polygons:
		# ==========================================
		# 【架构师补丁：幽灵势力拦截网】
		# 如果查到是无归属阵营(C_000)，直接跳过，绝对不给它画国家粗线！
		# ==========================================
		if civ_id == "C_000":
			continue
		var polys_to_merge = civ_polygons[civ_id]
		var merged_outlines = _merge_all_polygons(polys_to_merge)
		
		var hex_color = DataManager.game_data["civilizations"][civ_id]["color"]
		var border_color = Color(hex_color)
		border_color.a = 1.0 
		
		for outline in merged_outlines:
			var line = Line2D.new()
			line.points = outline
			
			# ==========================================
			# 【修复 1：启用完美闭环】
			# 删掉原来手动 add_point(outline[0]) 的旧代码。
			# 直接让引擎在首尾相接处进行圆滑的物理闭合，消灭断层毛刺。
			# ==========================================
			line.closed = true 
			
			line.width = 12.0 
			line.default_color = border_color
			line.z_index = 10 
			
			line.joint_mode = Line2D.LINE_JOINT_ROUND    
			line.begin_cap_mode = Line2D.LINE_CAP_ROUND  
			line.end_cap_mode = Line2D.LINE_CAP_ROUND    
			line.antialiased = true                      
			
			# ==========================================
			# 【修复 2：加入摄像机变色广播网】
			# 给这些动态生成的线贴上 "empire_borders" 标签
			# ==========================================
			line.add_to_group("empire_borders")
			
			add_child(line)

func _merge_all_polygons(polys: Array) -> Array:
	var result = []
	for p in polys:
		var merged_any = false
		if result.size() > 0:
			for i in range(result.size()):
				var merged = Geometry2D.merge_polygons(result[i], p)
				if merged.size() == 1:
					result[i] = merged[0]
					merged_any = true
					break
		if not merged_any:
			result.append(p)
	return result
