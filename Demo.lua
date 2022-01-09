Scorpio "SpaUI.Widget.RecyclerView.Demo" ""

TestRecyclerView = RecyclerView("TestRecylcerView")
TestRecyclerView:SetPoint("CENTER")
TestRecyclerView:SetSize(250, 500)

adapter = Adapter()

function adapter:OnCreateContentView(viewType, contentViewName)
    local frame = Frame(contentViewName)
    local text = FontString("Text", frame)
    text:SetAllPoints(frame)
    local bg = Texture("Bg", frame, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal")
    return frame
end

function adapter:OnBindViewHolder(holder, position)
    local data = self.Data[position]
    local contentView = holder.ContentView
    contentView:GetChild("Text"):SetText("测试" .. data)
    if holder.Orientation == Orientation.VERTICAL then
        contentView:SetHeight(math.max(data * 2, 50))
    else
        contentView:SetWidth(math.max(data * 2, 50))
    end
end

Divider = ItemDecoration("Divider")
Divider.Height = 10

function Divider:GetItemMargins(recyclerView, holder)
    if holder.Orientation == Orientation.VERTICAL then
        local paddingBottom = self.Height
        local adapter = recyclerView.Adapter

        if holder.Position == adapter:GetItemCount() then
            paddingBottom = 30
        end
        return 0, 0, 0, paddingBottom
    else
        local paddingBottom = self.Height
        local adapter = recyclerView.Adapter

        if holder.Position == adapter:GetItemCount() then
            paddingBottom = 30
        end
        return 0, paddingBottom, 0, 0
    end
end

function Divider:Draw(recyclerView, parent, holder)
    local line = parent:GetChild("Line")
    local endText = parent:GetChild("EndText")
    local adapter = recyclerView.Adapter

    if not line then
        line = Texture("Line", parent)
            line:SetPoint("BOTTOMLEFT")
            line:SetPoint("BOTTOMRIGHT")
            line:SetHeight(self.Height)
        line:SetColorTexture(1, 0, 0)
    end

    if not endText then
        endText = FontString("EndText", parent)
        endText:SetFontObject(GameFontRed)
        endText:SetPoint("BOTTOM")
        endText:SetText("我是有底线的！")
    end

    if holder.Position == adapter:GetItemCount() then
        line:Hide()
        endText:Show()
    else
        line:Show()
        endText:Hide()
    end
end

TestRecyclerView.Adapter = adapter
TestRecyclerView.LayoutManager = LinearLayoutManager()
TestRecyclerView:AddItemDecoration(Divider)
adapter.Data = List(50)