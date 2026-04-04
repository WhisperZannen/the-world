# ==========================================
# 高级上帝视角脚本（丝滑缩放版）
# 挂载对象：Camera2D
# ==========================================
extends Camera2D

# --- 调整参数区 ---
var zoom_speed : float = 0.05        # 缩放灵敏度（越小越精准）
var zoom_min : float = 0.01          # 最小缩放（看全景，针对2万像素图设定的极限）
var zoom_max : float = 2.0           # 最大缩放（看地标）
var smooth_speed : float = 15.0      # 平滑速度（数值越高，反应越快，建议10-20）

# --- 内部变量（不要手动改） ---
var target_zoom : Vector2 = Vector2(0.1, 0.1) # 我们“想要”达到的缩放值
var is_panning : bool = false                 # 是否正在平移

# ==========================================
# 针对 10112x6736 地图的最优初始化
# ==========================================
func _ready():
	# 【逻辑：优先保证高度能看全】
	# 计算：1080(窗口高) / 6736(地图高) ≈ 0.16
	# 我们设为 0.15，这样上下会留出一点点空隙，看起来不拥挤
	zoom = Vector2(0.25, 0.25)
	target_zoom = zoom
	
	# 【逻辑：精准对准地图中心】
	# 10112 / 2 = 5056
	# 6736 / 2 = 3368
	position = Vector2(5056, 3368)

func _unhandled_input(event: InputEvent) -> void:
	# 【功能：鼠标滚轮平滑缩放】
	if event is InputEventMouseButton:
		if event.is_pressed():
			# 向上滚动：目标放大
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# 采用乘法方案，缩放会越来越细腻
				zoom_at_point(1.1, event.position)
			# 向下滚动：目标缩小
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_at_point(0.9, event.position)

	# 【功能：鼠标中键拖拽】
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		is_panning = event.pressed

	if event is InputEventMouseMotion and is_panning:
		# 实时移动位置
		position -= event.relative / zoom

# 这个函数让摄像机向鼠标位置对齐，防止“缩放迷路”
func zoom_at_point(factor: float, mouse_pos: Vector2):
	var old_zoom = target_zoom
	# 计算新的目标缩放，并限制在安全范围内
	target_zoom = (target_zoom * factor).clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
	
	# 如果缩放真的变了，调整位置让鼠标指向的点保持不动
	var direction = (mouse_pos - get_viewport_rect().size / 2)
	var new_pos = position + direction / old_zoom - direction / target_zoom
	position = new_pos

# 每帧都会执行，用来处理“丝滑感”
func _process(delta: float) -> void:
	# 利用 lerp（线性插值）让当前的 zoom 一点点靠近 target_zoom
	# 这样你滑一下滚轮，画面是“滑”过去的，而不是跳过去的
	zoom = zoom.lerp(target_zoom, smooth_speed * delta)
