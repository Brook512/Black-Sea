
---
title: 像素风横板动作游戏 Demo 开发笔记
date: 2025-07-03 15:44:03
tags: [Godot, 横版动作, 开发经验, 像素风, LimboAI]
---

## 一、游戏本质：状态机 + 数据驱动

### 1. 状态机（State Machine）
游戏中的角色、敌人、系统逻辑本质上都是围绕“状态”运行的。例如玩家的移动、攻击、防御等行为就是不同的状态。通过有限状态机（FSM）或行为树（Behavior Tree）实现清晰的状态管理与切换，降低耦合，提高扩展性。

### 2. 数据驱动（Data-Driven）
游戏逻辑应尽可能从“硬编码”过渡到“数据驱动”。通过配置文件（如 JSON、TOML、Resource）来决定角色属性、攻击逻辑、敌人行为，从而提升可维护性和可扩展性。

---

## 二、Godot 引擎核心机制

### 1. 树状节点结构
- 所有节点组成一棵树，SceneTree 为根。
- 子节点继承父节点的变换属性（如位置、旋转）。
- 每帧引擎遍历场景树，按以下顺序调用回调函数：
  ```
  物理处理 → 输入处理 → 逻辑处理 → 渲染处理
  ```

### 2. 节点的基本能力
每个节点拥有：
- 名称、可编辑属性
- 生命周期函数：_ready(), _exit_tree(), _process(), _physics_process()
- 可继承、自定义扩展
- 可以挂载为其他节点的子节点，组成树结构

### 3. 信号系统
信号是一种事件广播机制：
- **信号定义方**：定义 `signal dead` 并使用 `emit_signal("dead")` 触发
- **信号接收方**：使用 `connect("dead", target_node, "_on_dead")` 连接信号回调

---

## 三、游戏设计核心：以时机驱动的战斗体验

- 攻击相撞后可进入“专注时间”，敌人变慢，玩家可打出连续技。
- 架势条系统控制“霸体”与“破防”机制。
- 体力系统控制闪避与攻击节奏。
- 战斗节奏以“读秒、还击、打断”形成动态博弈。
- 音乐节奏设计和攻击节奏强相关。

---

## 四、美术素材来源

推荐素材站点：
- [itch.io](https://itch.io)
- [Kenney.nl](https://kenney.nl)
- [Sketchfab](https://sketchfab.com)
- [Craftpix.net](https://craftpix.net)

---

## 五、输入系统解析（InputEvent）

Godot 的输入事件传播机制如下：

### 1. 基本流程
Viewport 会按照以下顺序处理输入：
1. `_input()`：全局输入，可设置 `set_input_as_handled()` 阻断传播。
2. `_gui_input()`：专用于 GUI 控件的输入逻辑。
3. `_shortcut_input()`：快捷键专用输入。
4. `_unhandled_key_input()`：未被 GUI 接收的按键事件。
5. `_unhandled_input()`：全屏游戏常用的输入函数。

### 2. Control 节点输入
- `_gui_input()` 会处理鼠标、触摸、键盘等 GUI 输入。
- `mouse_filter` 控制是否拦截输入事件。
- `accept_event()` 拦截事件防止继续传播。
- 控件焦点通过 `grab_focus()` 管理，避免事件被多个控件处理。

---

## 六、UI 系统

- UI 事件由视口统一向下传播。
- 使用 `Control._gui_input()` + `accept_event()` 控制输入优先级。
- 鼠标穿透可通过设置 `mouse_filter = MOUSE_FILTER_IGNORE` 实现。
- 背包系统可采用 **跳表（Skip List）** 数据结构，实现 O(logN) 插入与查询。

---

## 七、Shader 系统概览

### 1. 渲染管线核心阶段
- **Vertex Shader**：每个顶点执行一次
- **Fragment Shader**：每个像素执行一次
- **Light Shader**：受光照影响时每像素每光源执行

### 2. 常用内置变量（GLSL）
| 类型 | 变量名 | 描述 |
|------|--------|------|
| 输出 | `COLOR` | 当前像素颜色 |
| 输入 | `UV` | 当前像素的 UV 坐标 |
| Uniform | `TIME` | 全局时间 |
| Uniform | `SCREEN_PIXEL_SIZE` | 屏幕像素尺寸 |

### 3. 自定义变量传递
- `uniform`：用于从 GDScript 传值到 Shader
- `varying`：从 Vertex 向 Fragment 传递数据

---

## 八、角色控制与战斗系统

### 1. Player 控制逻辑
- `_physics_process()` 中处理移动、跳跃、攻击
- 动画通过 `AnimationPlayer` 或 `AnimationTree` 切换
- 攻击逻辑五级解耦：
  ```
  输入层 → 动画层 → 生成层 → 物理层 → 效果层
  ```

### 2. 碰撞层设置建议
| 类型 | Layer | Mask |
|------|-------|------|
| 主角 | 1 | 2,3,4 |
| 敌人 | 4 | 1,5 |
| NPC | 2 | 1 |
| 道具 | 3 | 1 |
| 墙体 | 6 | 1,2,3 |

---

## 九、AI 系统：LimboAI 行为树

### 1. 三大核心节点
- **Selector**：遇到成功就返回成功
- **Sequence**：遇到失败就返回失败
- **Condition**：判断条件节点

### 2. 创建自定义任务
继承 BTAction / BTCondition，实现 `_tick()` 方法。

### 3. 敌人 AI 设计
- 属性：血量、体力、架势、状态（待机/攻击/受击）
- 状态切换：远距 → 追击，近距 → 攻击或重击，受到攻击 → 闪避或硬抗

---

## 十、架势/体力/血量机制

- **血量 HP**：归零则死亡
- **体力 SP**：攻击和闪避消耗，归零则无法行动
- **架势 Posture**：遭受攻击时减少，归零则进入硬直状态

---

## 十一、序列化系统（待补充）

可使用 Godot 的 Resource、JSON、TOML、ConfigFile 进行存档、角色信息、技能参数等数据的持久化。

---

## 十二、网络系统（待补充）

涉及：
- 同步动画状态
- 客户端预测 + 服务器修正
- P2P vs Dedicated Server 架构对比

---

## 总结

这是一个关于使用 Godot 打造像素风横版动作游戏的开发实践总结。通过结合状态机、行为树、Shader 渲染、模块化输入处理、数据驱动和架势条系统，形成一套结构清晰、功能健全的横版战斗框架。未来计划补充存档系统与网络联机模块，欢迎持续关注。

---
