Scorpio "SpaUI.Widget.RecyclerView.Demo" ""

-- if not TestRecyclerView then return end

TestRecyclerView = RecyclerView("TestRecylcerView")
TestRecyclerView:SetPoint("CENTER")
TestRecyclerView:SetSize(250, 500)

adapter = Adapter()

function adapter:OnCreateContentView(viewType)
    local frame = Frame("ContentView")
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
        contentView:SetHeight(math.max(data * 5, 50))
    else
        contentView:SetWidth(math.max(data * 2, 50))
    end
end

Divider = ItemDecoration("Divider")
Divider.Height = 10

function Divider:GetItemMargins(recyclerView, holder)
    local paddingBottom = self.Height
    if holder.Position % 2 == 0 then
        paddingBottom = 30
    end
    return 0, 0, 0, paddingBottom
end

function Divider:Draw(recyclerView, itemView)
    local line = self:GetDecorationView(parent, "Line", Texture)
    line = Texture("Line", itemView)
    line:SetPoint("BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT")
    line:SetHeight(self.Height)
    line:SetColorTexture(1, 0, 0)

    local text = itemView:GetDecorationView("Text", FontString)
    text = FontString("Text", itemView)
    text:SetFontObject(GameFontRed)
    text:SetPoint("BOTTOM")

    local holder = itemView.ViewHolder

    if holder.Position % 2 == 0 then
        line:Hide()
        text:Show()
        text:SetText("这是第" .. holder.Position .. "行的页尾")
    else
        line:Show()
        text:Hide()
    end
end

TestRecyclerView.Adapter = adapter
-- TestRecyclerView.Orientation = Orientation.HORIZONTAL
TestRecyclerView.LayoutManager = LinearLayoutManager()
TestRecyclerView:AddItemDecoration(Divider)
adapter.Data = List(50)