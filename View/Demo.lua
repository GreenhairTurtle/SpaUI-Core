Scorpio "SpaUI.View.Demo" ""

import "SpaUI.Layout"
import "SpaUI.Layout.Widget"

textView = TextView("TextView")
textView:SetText("测试测试测试测试")
textView.Padding = Padding(20, 0, 0, 0)
textView.Margin = Margin(20, 0, 0, 0)
textView.LayoutParams = { gravity = Gravity.END, weight = 1 }

textView2 = TextView("TextView2")
textView2:SetText("22222222222222222222222222222222222222")
textView2.Padding = Padding(20)
textView2:SetNonSpaceWrap(true)
textView2.Margin = Margin(10, 0, 0, 0)
textView2.Width = 100

textView3 = TextView("TextView3")
textView3:SetText("3333333333333333333333333333333333333")
textView3:SetNonSpaceWrap(true)
textView3.Margin = Margin(10, 0, 0, 0)
textView3.Width = 100

linearLayout = LinearLayout("TextLinearLayout", UIParent, "BackdropTemplate")
linearLayout:SetBackdrop(BACKDROP_CHARACTER_CREATE_TOOLTIP_32_32)
linearLayout:AddView(textView)
linearLayout:AddView(textView2)
linearLayout:AddView(textView3)
linearLayout:SetPoint("CENTER")
linearLayout.Padding = Padding(20)
linearLayout.Width = 800
linearLayout.Height = 800

Delay(10, function ()
    linearLayout.Orientation = Orientation.VERTICAL
end)
