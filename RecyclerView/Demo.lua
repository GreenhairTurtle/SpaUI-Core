Scorpio "SpaUI.Widget.RecyclerView.Demo" ""

-- if not TestRecyclerView then return end

TestRecyclerView = RecyclerView("TestRecylcerView")
TestRecyclerView:SetPoint("CENTER")
TestRecyclerView:SetSize(500, 800)

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
        contentView:SetHeight(math.max(data * 10, 50))
    else
        contentView:SetWidth(math.max(data * 2, 50))
    end
end

Divider = ItemDecoration("Divider")
Divider.Height = 10

function Divider:OnCreateDecorationView()
    local frame = Frame("DecorationView")
    local line = Texture("Line", frame)
    line:SetPoint("BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT")
    line:SetHeight(self.Height)
    line:SetColorTexture(1, 0, 0)
    
    local text = FontString("Text", frame)
    text:SetFontObject(GameFontRed)
    text:SetPoint("BOTTOM")

    return frame
end

function Divider:GetItemMargins(recyclerView, holder)
    local paddingBottom = self.Height
    if holder.Position % 2 == 0 then
        paddingBottom = 30
    end
    return 0, 0, 0, paddingBottom
end

function Divider:Draw(recyclerView, decorationView, holder)
    local line = decorationView:GetChild("Line")
    local text = decorationView:GetChild("Text")
    if holder.Position % 2 == 0 then
        line:Hide()
        text:Show()
        text:SetText("这是第" .. holder.Position .. "行的页尾")
    else
        line:Show()
        text:Hide()
    end
end

-- function Divider:OnCreateOverlayView()
--     local frame = Frame("OverlayView")
--     local texture = Texture("Overlay", frame)
--     texture:SetColorTexture(0, 1, 0)
--     texture:SetAllPoints()
--     frame:SetWidth(50)
--     return frame
-- end

-- function Divider:DrawOver(recyclerView, overlayView)
--     overlayView:SetPoint("TOPLEFT")
--     overlayView:SetPoint("BOTTOMLEFT")
-- end

RightBG = ItemDecoration("RightBG")

function RightBG:GetItemMargins()
    return 0, 70, 0, 0
end

function RightBG:OnCreateOverlayView()
    local frame = Frame("RightBg")
    local texture = Texture("Overlay", frame)
    texture:SetColorTexture(0, 0, 1)
    texture:SetAllPoints()
    frame:SetWidth(50)
    return frame
end

function RightBG:DrawOver(recyclerView, overlayView)
    overlayView:SetPoint("TOPRIGHT")
    overlayView:SetPoint("BOTTOMRIGHT")
end

layoutManager = GridLayoutManager(10)
function layoutManager:GetSpanSizeLookUp(position)
    local value = position % 6
    if value > 0 and value <= 1 then
        return 8
    elseif value > 1 and value <= 3 then
        return 4
    elseif value > 3 and value <= 5 then
        return 2
    else
        return 4
    end
end

TestRecyclerView.Adapter = adapter
-- TestRecyclerView.Orientation = Orientation.HORIZONTAL
TestRecyclerView.LayoutManager = layoutManager
TestRecyclerView:AddItemDecoration(Divider)
-- TestRecyclerView:AddItemDecoration(RightBG)
adapter.Data = List(50)