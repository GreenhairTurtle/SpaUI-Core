Scorpio "SpaUI.Widget.Layout.Demo" ""

import "SpaUI.Widget.Layout"
import "SpaUI.Widget"

TestLinearLayout = LinearLayout("TestLinearLayout")
TestLinearLayout.LayoutParams = LayoutParams(1920, 1080)
TestLinearLayout:SetPoint("CENTER")

print(TestLinearLayout:GetSize())