重剑和刺剑

#一、引擎的核心

1. 特性
树状数据结构​​：所有节点以树状结构组织，根节点通常是 MainLoop 或 SceneTree，每个节点及其子节点形成一个分支。（子节点继承父节点的变换（位置、旋转等））
​​逐帧遍历​​：引擎每帧遍历场景树，按固定顺序（物理→输入→逻辑→渲染）触发节点的 _process()、_physics_process() 等方法。
​​节点生命周期管理​​：引擎自动处理节点的创建、销毁、挂载（_ready()）和卸载（_exit_tree()）。

2. 节点的基础功能（打下基础）
所有节点都具备以下特性：
名称。
可编辑的属性。
每帧都可以接收回调以进行更新。
你可以使用新的属性和函数来进行扩展。
你可以将它们添加为其他节点的子节点。
最后一个特征很重要。节点会组成一棵树

3. 信号
信号的使用分为两块
信号创建方，负责定义信号 signal dead，以及广播信号 dead.emit
信号接收方，负责连接创建方的信号 dead.connect(func)， 以及创建回调函数

4. 


#二、设计核心
以重击，伤害数值为核心，优化战斗体验的设计
挥砍的速度、范围、伤害
格挡的帧数长短、格挡反击伤害
闪避的帧数长短、闪避伤害

核心机制：衔接（格斗游戏）、在重击之后合适的时机会接超重击，（博弈点在哪？） 蓄势与出刀拆开来
轻剑有出血
剑盾在攻击任何时候都可以举盾，但是没有反击效果

音乐是关键
重剑克剑盾
剑盾克轻剑
轻剑克重剑


# 三、素材来源
itch.io
kenny asset
sketch fab
craftpix

# 四、输入
## 1. inputevent
如果该 Viewport 内嵌了 Window，则该 Viewport 会尝试以窗口管理器的身份解释事件（例如对 Window 进行大小调整和移动）。

接下来，如果存在聚焦的内嵌 Window，则会将事件发送给该 Window，在该窗口的 Viewport 中进行处理，然后将事件标记为已处理。如果不存在聚焦的内嵌 Window，则会将事件发送给当前视口中的节点，顺序如下。

首先会调用标准的 Node._input() 函数，调用只会发生在覆盖了这个函数（并且输入处理没有通过 Node.set_process_input() 禁用）的节点上。如果某个函数消耗了该事件，可以调用 Viewport.set_input_as_handled()，事件就不会再继续传播。这样就确保你可以在 GUI 之前过滤自己感兴趣的事件。对于游戏输入，Node._unhandled_input() 通常更合适，因为这个函数能够让 GUI 拦截事件。

然后，它会尝试将输入提供给 GUI，并查看是否有控件可以接收它。如果有，该 Control 将通过虚函数 Control._gui_input() 被调用并发出“gui_input”信号（此函数可通过继承它的脚本重新实现）。如果该控件想“消耗”该事件，它将调用 Control.accept_event() 阻止事件的传播。请使用 Control.mouse_filter 属性来控制 Control 是否通过 Control._gui_input() 回调接收鼠标事件的通知，以及是否进一步传播这些事件。

如果事件到目前为止还没有被消耗，并且覆盖了 Node._shortcut_input() 函数（并且没有通过 Node.set_process_shortcut_input() 禁用），那么就会调用这个回调。只有 InputEventKey、InputEventShortcut 和 InputEventJoypadButton 才会如此。如果某个函数消耗了该事件，它可以调用 Viewport.set_input_as_handled()，那么事件就不会再继续传播。快捷键输入回调主要用于处理快捷键相关的事件。

如果事件到目前为止还没有被消耗，并且 Node._unhandled_key_input() 函数已被覆盖（并且没有通过 Node.set_process_unhandled_key_input() 禁用），那么该回调将被调用。仅当事件是 InputEventKey 时才会如此。如果某个函数消耗了该事件，它可以调用 Viewport.set_input_as_handled()，事件就不会再继续传播。未处理按键输入回调主要用于处理按键相关的事件。

如果事件到目前为止还没有被消耗，并且覆盖了 Node._unhandled_input() 函数（并且没有通过 Node.set_process_unhandled_input() 禁用），那么就会调用这个回调。如果某个函数消耗了该事件，它可以调用 Viewport.set_input_as_handled()，事件就不会再继续传播。未处理输入回调主要用于处理全屏游戏事件，因此 GUI 处于活动状态时不会收到。

如果到目前为止没有节点想要该事件，并且对象拾取已打开，则该事件将用于对象拾取。对于根视口，也可以在项目设置中启用该设置。在 3D 场景的情况下，如果将 Camera3D 分配给该 Viewport，则会向物理世界投射一条射线（以从点击开始的射线方向）。如果该射线击中物体，它将调用相关物理对象中的 CollisionObject3D._input_event() 函数。对于 2D 场景，从概念上讲，CollisionObject2D._input_event() 也会发生同样的情况。
## 2. 


# 五、UI
1. UI信号的传播
Godot 通过视口传播输入事件。每个 Viewport 负责将 InputEvent传播到其子节点。
由于 SceneTree.root 是一个 Window，因此游戏中的所有 UI 元素都已自动执行此作。
通过调用 SceneTree 将输入事件从根节点传播到所有子节点Node._input。特别是对于 UI 元素，覆盖虚拟方法 _gui_input 更有意义，该方法会筛选掉不相关的输入事件，例如通过检查 z 顺序、mouse_filter、焦点或事件是否位于控件的边界框内。

调用 accept_event，以便没有其他节点收到事件。接受输入后，它将被处理，因此Node._unhandled_input不会处理它。

只有一个 Control 节点可以处于焦点状态。只有焦点节点才会接收事件。要获得焦点，请致电 grab_focus。当另一个节点抓住控制节点时，或者如果您隐藏了焦点中的节点，则控制节点会失去焦点。

将 mouse_filter 设置为 MOUSE_FILTER_IGNORE 以指示 Control 节点忽略鼠标或触摸事件。如果您在按钮顶部放置图标，您将需要它。

2. 背包机制 （跳表） 实现快速的插入和查询 （logn）
传统链表的查询速度为（n）

## 1.按钮设定


#六、shader
1.shader的主循环：渲染管线
a. ​​顶点着色器（Vertex Shader）​​
​​作用阶段​​：顶点处理阶段（Vertex Processing）。
​​执行方式​​：
对 ​​每个顶点​​ 执行一次。
Godot 会在渲染模型时，自动遍历所有顶点，并将顶点数据（位置、法线、UV 等）传递给顶点着色器。

b. 片元着色器Fragment Shader
对 ​​每个片元（像素）​​ 执行一次。
在光栅化阶段后，Godot 会为每个覆盖模型表面的像素生成片元，并自动调用片元着色器。
片段函数的标准用途是设置用于计算光照的材质属性。例如，你可以为 ROUGHNESS、RIM、TRNASMISSION 等设置值，
告诉光照函数光照应该如何处理对应的片段。这样就可以控制复杂的着色管线，而不必让用户编写过多的代码。如果你不需要这一内置功能，
那么你可以忽略它，自行编写光照处理函数，Godot 会将其优化掉。
例如，如果你没有向 RIM 写入任何值，那么 Godot 就不会计算边缘光照。
编译时，Godot 会检查是否使用了 RIM；如果没有，那么它就会把对应的代码删除。因此，你就不会在没有使用的效果上浪费算力。

c
光照处理器
light() 处理器也会在每一个像素上运行，并且同时还会在每一个影响该对象的灯光上运行。如果没有灯光影响该对象则不会运行。
它会被用于 fragment() 处理器，一般会在 fragment() 函数中进行材质属性设置时执行。

## 🎨 内置变量
| 变量名            | 类型         | Godot 等价物               | 描述                          |
|--------------------|--------------|---------------------------|-------------------------------|
| `fragColor`        | `out vec4`   | `COLOR`                   | 像素输出颜色 (Fragment Shader) |
| `fragCoord`        | `vec2`       | `FRAGCOORD.xy`            | 全屏四边形的像素坐标           |
| `iResolution`      | `vec3`       | `1.0 / SCREEN_PIXEL_SIZE` | 屏幕分辨率倒数 (可手动传递)    |

## ⏱ 时间相关 Uniform
| 变量名              | 类型         | 描述                          |
|----------------------|--------------|-------------------------------|
| `iTime`             | `float`      | 着色器启动后的累计时间（秒）    |
| `iTimeDelta`        | `float`      | 前一帧的渲染耗时（秒）         |
| `iFrame`            | `float`      | 累计渲染帧数                   |
| `iChannelTime[4]`   | `float`      | 各纹理通道独立计时（秒）        |

## 🖱 输入设备 Uniform
| 变量名              | 类型         | 描述                          |
|----------------------|--------------|-------------------------------|
| `iMouse`            | `vec4`       | 鼠标位置（像素坐标）           |
| `iDate`             | `vec4`       | 当前时间 `(秒, 分, 时, 年)`     |

## 🖼 纹理相关
### 分辨率参数
| 变量名                     | 类型         | Godot 等价物               |
|----------------------------|--------------|---------------------------|
| `iChannelResolution[4]`    | `vec3`       | `1.0 / TEXTURE_PIXEL_SIZE` |

### 采样器
| 变量名          | 类型            | 描述                          |
|------------------|-----------------|-------------------------------|
| `iChanneli`      | `sampler2D`     | 纹理采样器 (Godot 默认提供 1 个) |

---

## 使用说明
1. **坐标系统**  
   `fragCoord` 适用于全屏四边形，小范围四边形建议使用 `UV`

2. **纹理扩展**  
   Godot 默认仅提供 1 个内置纹理 (`TEXTURE`)，可通过自定义 Uniform 添加更多纹理通道

3. **分辨率计算**  
   `iResolution` 等价于屏幕像素尺寸的倒数，可通过 `1.0 / SCREEN_PIXEL_SIZE` 获取
## 变量传递方法

### 1. 插值变量（Varying Variables）
1. **声明插值变量**：在着色器顶部使用 `varying` 声明。
   ```glsl
   varying vec3 custom_data;
	```

# 七、Gameplay

## 1.player移动逻辑（本质上是动画切换+坐标移动）
对应_physics_process 通过Input输入映射获取数值，在character的physical process中实现动画切换

## 2.攻击动画 （输入层 → 动画层 → 生成层 → 物理层 → 效果层 五级解耦）
包含了两个对象 player 和 bullet
如果我要

##3.collision
collision_layer是一个位掩码（bitmask），用于表示这个物体属于哪些碰撞层。
collision_mask是一个位掩码，用于表示这个物体会检测哪些碰撞层上的物体。

设定 collision layer——1：主角，2：NPC，3：Item，4：敌人攻击，5：主角攻击 6.wall 7 对话

主角的mask——234
NPC的mask——15
Item的mask——1

wall 的 mask——123

怪物的血量以架势条为核心

角色有四类碰撞：攻击、受伤、对话、运动

##4.status
以架势条、血量和体力为核心


 
