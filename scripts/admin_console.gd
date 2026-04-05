extends CanvasLayer

func _ready():
	# 1. 游戏启动时，隐藏菜单面板
	$MenuPanel.hide()
	
	# 2. 绑定魔法球的【点击】事件
	$MagicButton.pressed.connect(_on_magic_button_pressed)
	
	# ==========================================
	# 【新增】工业级鼠标悬停透明度渐变效果
	# ==========================================
	# A. 设置初始状态：游戏一开始，魔法球不透明度仅为 30% (Alpha=0.3)
	$MagicButton.modulate.a = 0.3
	
	# B. 绑定鼠标移入/移出信号
	$MagicButton.mouse_entered.connect(_on_magic_mouse_entered)
	$MagicButton.mouse_exited.connect(_on_magic_mouse_exited)

# ------------------------------------------
# 魔法球信号响应函数集合
# ------------------------------------------
# 响应信号：鼠标移入。不透明度变为 100% (A=1.0)
func _on_magic_mouse_entered():
	$MagicButton.modulate.a = 1.0

# 响应信号：鼠标移出。不透明度恢复为 30% (A=0.3)
func _on_magic_mouse_exited():
	$MagicButton.modulate.a = 0.3

# 响应点击：开/关菜单
func _on_magic_button_pressed():
	$MenuPanel.visible = not $MenuPanel.visible
