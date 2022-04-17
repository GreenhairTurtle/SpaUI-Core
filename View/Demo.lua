Scorpio "SpaUI.View.Demo" ""

import "SpaUI.Layout.Widget.TextView"

-- textView = TextView("TextView", UIParent, "BackdropTemplate")
-- textView:SetBackdrop(BACKDROP_CHARACTER_CREATE_TOOLTIP_32_32)
-- -- textView = FontString("TextView")
-- textView:SetPoint("CENTER")
-- textView:SetSize(64, 68)
-- textView:SetText("测试测试测试测试测试测试测试测试测试测试测试测试测试测试")
-- textView:SetMaxLines(2)
-- print(textView:GetStringWidth())
-- -- 这个函数返回需要的实际的宽度
-- print(textView:GetUnboundedStringWidth())
-- print(textView:GetWrappedWidth())
-- -- 这个函数返回显示的文本的高度
-- print(textView:GetStringHeight())
-- print(textView:GetSize())

textView = TextView("TextView", UIParent, "BackdropTemplate")
textView2 = TextView("TextView2", UIParent, "BackdropTemplate")

Delay(5, function()
    print(textView.Padding)
    print(textView2.Padding)
end)