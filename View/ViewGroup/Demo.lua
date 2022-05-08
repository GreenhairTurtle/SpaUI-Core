Scorpio "KittyBox.Widget.Layout.Demo" ""

import "KittyBox.Layout"
import "KittyBox"

TestLinearLayoutParent = LinearLayout("TestLinearLayoutParent")
TestLinearLayoutParent.Orientation = Orientation.HORIZONTAL
TestLinearLayoutParent:SetPoint("CENTER")

TestLinearLayout = LinearLayout("TestLinearLayout")
TestLinearLayout:SetLayoutParams(LayoutParams(500, 800))
TestLinearLayout.Gravity = Gravity.CENTER_HORIZONTAL + Gravity.CENTER_VERTICAL
TestLinearLayout.Padding = Padding(50, 80, 60, 100)
TestLinearLayout:SetPoint("CENTER")

TestLinearLayoutParent:AddChild(TestLinearLayout)

TestButton = UIPanelButton("TestButton")
TestButton:SetText("测试")
local layoutParams = {
    width = SizeMode.WRAP_CONTENT,
    height = SizeMode.WRAP_CONTENT,
    prefWidth = 100,
    prefHeight = 50,
    weight = 0.5,
    margin = Margin(20, 50)
}
TestLinearLayout:AddChild(TestButton, layoutParams)

TestButton2 = UIPanelButton("TestButton2")
TestButton2:SetText("测试2")
local layoutParams2 = {
    width = SizeMode.WRAP_CONTENT,
    height = SizeMode.WRAP_CONTENT,
    prefWidth = 150,
    prefHeight = 200,
    weight = 1,
    margin = Margin(150, 20)
}
TestLinearLayout:AddChild(TestButton2, layoutParams2)

TestButton3 = UIPanelButton("TestButton3")
TestButton3:SetText("测试3")
local layoutParams3 = {
    width = SizeMode.WRAP_CONTENT,
    height = SizeMode.WRAP_CONTENT,
    prefWidth = 150,
    prefHeight = 200,
    weight = 1,
    margin = Margin(150, 20)
}
TestLinearLayoutParent:AddChild(TestButton3, layoutParams3)

Delay(5, function()
    TestLinearLayout.Orientation = Orientation.HORIZONTAL
end)

Delay(10, function()
    TestLinearLayout.LayoutDirection = LayoutDirection.RIGHT_TO_LEFT
    print(TestLinearLayout:GetEffectiveScale(), TestLinearLayout:GetSize())
end)

Delay(15, function()
    TestLinearLayout:SetScale(1.5)
end)