using Godot;

public partial class DebugZIndex : Sprite2D
{
    // _Process函数在每一帧都会被调用
    public override void _Process(double delta)
    {
        // 我们只需要这一行代码，来实时查看父节点的Y-Sort功能为我们计算出的Z Index
        GD.Print(this.Name + " Z Index: ", this.ZIndex);
    }
}