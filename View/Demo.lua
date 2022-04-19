Scorpio "SpaUI.View.Demo" ""

import "SpaUI.Layout"
import "SpaUI.Layout.Widget"

textView = TextView("TextView", UIParent, "BackdropTemplate")
textView:SetPoint("CENTER", -200, 0)
textView:SetText("测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试")
textView.Width = 64
textView.Height = 80


Delay(5, function()
    textView.Width = 200
    textView.Height = SizeMode.WRAP_CONTENT
end)