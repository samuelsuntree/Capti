using Godot;

public partial class PlayerController : CharacterBody2D
{
    // 使用[Export]可以让这个变量显示在Godot编辑器中，方便随时调整
    [Export]
    public float Speed { get; set; } = 200.0f;

    // 用来存储对动画节点的引用
    private AnimatedSprite2D animatedSprite;

    // _Ready()函数在节点进入场景树时被调用一次，适合做初始化工作
    public override void _Ready()
    {
        // 获取子节点AnimatedSprite2D的引用
        // 注意：这里的"AnimatedSprite2D"必须和您场景树中的节点名称完全一致
        // 在这里加入打印语句
        GD.Print("脚本的_Ready函数被调用了!");

        animatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");

        // 再加入一句，检查是否成功获取到了节点
        GD.Print("获取到的动画节点是: ", animatedSprite);
    }

    // _PhysicsProcess()函数在每个物理帧被调用，所有物理相关的逻辑都应放在这里
    public override void _PhysicsProcess(double delta)
    {
        // 1. 获取输入方向
        // Input.GetVector会根据输入映射返回一个方向向量，例如按下右方向键，它会是(1, 0)
        Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

        // 2. 根据方向和速度设置速度
        Velocity = direction * Speed;


        // 3. 调用内置的移动和碰撞函数
        MoveAndSlide();

        // 4. 更新动画
        UpdateAnimation();

        // 5. 更新精灵图朝向
        UpdateSpriteFlip(direction);
    }

    private void UpdateAnimation()
    {

        // Velocity.Length() > 0 意味着角色正在移动
        if (Velocity.Length() > 0)
        {
            animatedSprite.Play("walk");
        }
        else
        {
            // 速度为0，意味着角色静止
            animatedSprite.Play("idle");
        }

    }

    private void UpdateSpriteFlip(Vector2 direction)
    {
        // 如果有水平方向的移动
        if (direction.X != 0)
        {
            // direction.X < 0 意味着向左移动，此时需要水平翻转精灵图
            animatedSprite.FlipH = direction.X < 0;
        }
    }
    public override void _Process(double delta)
    {
        // 打印玩家的全局Y坐标。这是Y-Sort用来排序的主要依据。
        GD.Print("Player Global Y: ", this.GlobalPosition.Y);

        // 打印玩家最终的渲染层级 (Z Index)。
        // Y-Sort就是通过动态修改这个值来实现排序的。
        // Y坐标越大，这个值也应该越大。
        GD.Print("Player Z Index: ", this.ZIndex);
    }
}