# ==========================================
# 这是一个名为 DataManager.gd 的全局自动加载脚本
# 它的唯一作用是：在游戏启动时，把硬盘里的 JSON 文件读到内存里，供全图使用。
# ==========================================
extends Node

# 详细说明：声明一个名为 game_data 的字典变量。
# 这个字典就是整个沙盘的数据大脑，用来存储从 JSON 读出来的所有数据。
var game_data : Dictionary = {}

# 详细说明：写死 JSON 文件的物理路径。
# 根据你的描述，它放在 data 文件夹下。
var data_path : String = "res://data/save_data.json"

# ==========================================
# 引擎初始化函数：游戏一启动就立刻执行
# ==========================================
func _ready():
	load_game_data()

# ==========================================
# 核心读取逻辑：将 JSON 文本转换为 Godot 字典
# ==========================================
func load_game_data():
	# 1. 尝试用“只读模式 (READ)”打开对应路径的文件
	var file = FileAccess.open(data_path, FileAccess.READ)
	
	# 2. 事实核查：检查文件是否存在、是否成功打开
	if file == null:
		print("【致命错误】找不到数据文件，请检查路径：", data_path)
		return # 如果找不到文件，立刻停止执行
	
	# 3. 把文件里的所有内容当作纯文本读取出来
	var json_text = file.get_as_text()
	file.close() # 养成好习惯，读完就关掉文件释放内存
	
	# 4. 调用 Godot 自带的 JSON 解析器，把纯文本转换成代码能看懂的字典 (Dictionary)
	var parsed_data = JSON.parse_string(json_text)
	
	# 5. 二次核查：确认解析出来的数据是不是一个正确的字典格式
	if typeof(parsed_data) == TYPE_DICTIONARY:
		game_data = parsed_data
		print("【系统播报】底层数据装载完毕！包含城镇数量：", game_data["cities"].size())
	else:
		print("【致命错误】JSON 格式有误，解析失败！请检查 save_data.json 里面有没有漏掉逗号或括号。")
