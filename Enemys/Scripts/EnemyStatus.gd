extends Node2D
# 功能: 敌人基础状态数据容器
# 架构: 纯数据组件(无方法)，通过直接访问字段读写状态

# 敌人状态结构体 - 使用字典实现轻量级结构体
# 优点: 1) 内存紧凑 2) 支持编辑器可视化 3) 序列化友好
var Status: Dictionary = {
	# 当前生命值(归零时死亡)
	"health": 100.0,
	
	# 架势条(被破防时触发处决)
	"posture": 0.0,
	
	# 体力值(影响行动能力)
	"stamina": 100.0,
	
	# 状态标志位(用位掩码优化存储)
	# 第0位: 是否存活 | 第1位: 是否破防 | 第2位: 是否疲劳
	"state_flags": 0  
}

# 状态标志常量(位掩码操作)
const ALIVE_FLAG: int = 1 << 0
const BROKEN_POSTURE_FLAG: int = 1 << 1
const EXHAUSTED_FLAG: int = 1 << 2
