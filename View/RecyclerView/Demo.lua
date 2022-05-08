Scorpio "KittyBox.Widget.RecyclerView.Demo" ""

import "KittyBox.Widget.Recycler"

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

    local button = UIPanelButton("Button", frame)
    button:SetPoint("RIGHT")
    button:SetSize(128, 64)
    button:SetText("点我")
    return frame
end

function adapter:OnBindViewHolder(holder, data)
    holder:GetChild("Text"):SetText("测试" .. data)
    holder:AddChildScript("Button", "OnClick")
    holder:AddChildScript("Button", "OnDoubleClick")
    holder:SetContentLength(math.max(data * 10, 50))
end

listener = {}
function listener.OnClick(adapter, itemView, button, down)
    print("OnClick", itemView:GetName(), button, down)
    print(itemView.ViewHolder.Position, itemView.ViewHolder.DataPosition)
end
function listener.OnDoubleClick(adapter, itemView, button, down)
    print("OnDoubeClick", itemView:GetName(), button, down)
    print(itemView.ViewHolder.Position, itemView.ViewHolder.DataPosition)
end
adapter.ItemListener = listener

childListener = {}
function childListener.OnClick(adapter, itemView, child, button, down)
    print("Child OnClick", child:GetName(), button, down)
    print(itemView.ViewHolder.Position, itemView.ViewHolder.DataPosition)
end
function childListener.OnDoubleClick(adapter, itemView, child, button, down)
    print("Child OnDoubeClick", child:GetName(), button, down)
    print(itemView.ViewHolder.Position, itemView.ViewHolder.DataPosition)
end
adapter.ItemChildListener = childListener

EmptyView = FontString("EmptyText")
EmptyView:SetText("没有数据哦~")
EmptyView:SetJustifyH("CENTER")
EmptyView:SetJustifyV("MIDDLE")
adapter.EmptyView = EmptyView

HeaderView = Frame("Header")
local text = FontString("Text", HeaderView)
text:SetPoint("CENTER")
text:SetFontObject(GameFontNormalHuge)
text:SetText("这是头布局")
HeaderView:SetHeight(200)
adapter.HeaderView = HeaderView

FooterView = Frame("Footer")
local text2 = FontString("Text", FooterView)
text2:SetPoint("CENTER")
text2:SetFontObject(GameFontNormalHuge)
text2:SetText("这是脚布局")
FooterView:SetHeight(300)
adapter.FooterView = FooterView
adapter.HeaderWithEmptyEnable = true
adapter.FooterWithEmptyEnable = true

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
    if holder.ItemViewType == Adapter.EMPTY_VIEW then
        paddingBottom = 0
    end
    return 0, 0, 0, paddingBottom
end

function Divider:Draw(recyclerView, decorationView, holder)
    local line = decorationView:GetChild("Line")
    local text = decorationView:GetChild("Text")
    if holder:IsDataView() then
        if holder.Position % 2 == 0 then
            line:Hide()
            text:Show()
            text:SetText("这是第" .. holder.Position .. "行的页尾")
        else
            line:Show()
            text:Hide()
        end
    else
        line:Hide()
        text:Hide()
    end
end

function Divider:OnCreateOverlayView()
    local frame = Frame("OverlayView")
    local texture = Texture("Overlay", frame)
    texture:SetColorTexture(0, 1, 0)
    texture:SetAllPoints()
    frame:SetHeight(50)
    local text = FontString("Text", frame)
    text:SetPoint("CENTER")
    return frame
end

function Divider:DrawOver(recyclerView, overlayView)
    overlayView:SetPoint("TOPLEFT")
    overlayView:SetPoint("TOPRIGHT")
    local itemViewCount = recyclerView:GetItemViewCount()
    local itemView, index, offset = recyclerView:GetFirstVisibleItemView()
    overlayView:GetChild("Text"):SetText(tostring(itemView.ViewHolder.Position))
end

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

-- layoutManager = GridLayoutManager(2)
layoutManager = LinearLayoutManager()

TestRecyclerView.Adapter = adapter
-- TestRecyclerView.Orientation = Orientation.HORIZONTAL
TestRecyclerView.LayoutManager = layoutManager
TestRecyclerView:AddItemDecoration(Divider)
-- TestRecyclerView:AddItemDecoration(RightBG)
adapter.Data = List(50)

Delay(10, function()
    TestRecyclerView:ScrollToPosition(25)
end)