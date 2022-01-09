-----------------------------------------------------------
--         Warcraft version of Android recyclerView      --
-----------------------------------------------------------
Scorpio "SpaUI.Widget.RecyclerView" ""

namespace "SpaUI.Widget.Recycler"

class "ItemDecoration" {}

class "ItemView" { Frame }

class "RecyclerView" { ScrollFrame }

-----------------------------------------------------------
--                     ScrollBar                         --
-----------------------------------------------------------

-- 修改自Scorpio.Widget.UIPanelScrollFrame.UIPanelScrollBar
-- 无视ValueSetp的ScrollBar，每次滚动只移动1，对应列表1个item
__Sealed__()
class "ScrollBar"(function()
    inherit "Slider"

    local function RefreshScrollButtonStates(self)
        local value = self:GetValue()
        local min, max = self:GetMinMaxValues()
        local scrollUpButton = self:GetChild("ScrollUpButton")
        local scrollDownButton = self:GetChild("ScrollDownButton")
        if value <= min then
            scrollUpButton:Disable()
        else
            scrollUpButton:Enable()
        end
        if value >= max then
            scrollDownButton:Disable()
        else
            scrollDownButton:Enable()
        end
    end
    
    local function Show(self)
        self:SetAlpha(1)
        local current = GetTime()
        self.ShowTime = current
        self.FadeoutTarget = current + self.FadeoutDelay + self.FadeoutDuration
    end

    local function SyncRecyclerView(self)
        self:GetParent():ScrollToPosition(self:GetValue())
    end

    local function OnValueChanged(self, value, userInput)
        print("OnValueChanged", value, userInput)
        Show(self)
        RefreshScrollButtonStates(self)
        if userInput then
            SyncRecyclerView(self)
        end
    end

    local function OnMouseWheel(self, delta)
        local value = self:GetValue() - delta
        local min, max = self:GetMinMaxValues()
        if value < min then
            value = min
        elseif value > max then
            value = max
        end
        self:SetValue(value)
        SyncRecyclerView(self)
    end

    -- Hold down
    local function ScrollButton_Update(self, elapsed)
        self.timeSinceLast = self.timeSinceLast + elapsed
        if self.timeSinceLast >= 0.08 then
            if not IsMouseButtonDown("LeftButton") then
                self:SetScript("OnUpdate", nil)
            elseif self:IsMouseOver() then
                OnMouseWheel(self:GetParent(), self.direction)
                self.timeSinceLast = 0
            end
        end
    end

    local function ScrollButton_OnClick(self, button, down)
        if down and button == "LeftButton" then
            self.timeSinceLast = -0.2
            self:SetScript("OnUpdate", ScrollButton_Update)
            OnMouseWheel(self:GetParent(), self.direction)
            PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
        else
            self:SetScript("OnUpdate", nil)
        end
    end

    local function OnLeave(self)
        -- do nothing
    end

    local function OnEnter(self)
        Show(self)
    end

    local function IsMouseOver(self)
        if self:IsMouseOver() then return true end

        for _, child in self:GetChilds() do
            if child:IsMouseOver() then return true end
        end
    end

    local function OnUpdate(self, elapsed)
        if IsMouseOver(self) then
            Show(self)
        else
            local current = GetTime()
            if self.FadeoutTarget and current <= self.FadeoutTarget and current - (self.ShowTime or 0) > self.FadeoutDelay then
                local alpha = (self.FadeoutTarget - current)/self.FadeoutDuration
                self:SetAlpha(alpha)
            end
        end
    end

    local function ScrollButton_OnEnter(self)
        OnEnter(self:GetParent())
    end

    local function ScrollButton_OnLeave(self)
        OnLeave(self:GetParent())
    end

    -- @Override
    __Final__()
    function SetValueStep(self, step)
        Slider.SetValueStep(self, 1)
    end

    -- @Override
    __Final__()
    function SetMinMaxValues(self, min, max)
        -- do nothing
    end

    -- @Override
    function SetObeyStepOnDrag(self, obeyStepOnDrag)
        Slider.SetObeyStepOnDrag(self, true)
    end

    function SetRange(self, range)
        Slider.SetMinMaxValues(self, 1, range)
    end

    -- @Override
    __Final__()
    function SetValue(self, value)
        local min, max = self:GetMinMaxValues()
        local oldValue = self:GetValue()
        value = math.floor(value + 0.5)
        if value < min then
            value = min
        elseif value > max then
            value = max
        end

        if value ~= oldValue then
            Slider.SetValue(self, value)
        end
    end

    -- @Override
    __Final__()
    function GetValue(self)
        local value = math.modf(Slider.GetValue(self))
        return value or 1
    end

    -- 渐隐
    property "Fadeout"          {
        type                    = Boolean,
        handler                 = function(self, fadeout)
            if fadeout then
                self.OnUpdate = self.OnUpdate + OnUpdate
            else
                self.OnUpdate = self.OnUpdate - OnUpdate
            end
        end
    }

    -- 渐隐时间
    property "FadeoutDuration"  {
        type                    = Number,
        default                 = 2.5
    }

    -- 渐隐延迟
    property "FadeoutDelay"     {
        type                    = Number,
        default                 = 2
    }

    __Template__{
        ScrollUpButton          = Button,
        ScrollDownButton        = Button,
    }
    function __ctor(self)
        self:SetObeyStepOnDrag(true)
        self:SetValueStep(1)
        self:SetAlpha(0)

        local scrollUpButton    = self:GetChild("ScrollUpButton")
        local scrollDownButton  = self:GetChild("ScrollDownButton")
        
        scrollUpButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
        scrollUpButton.direction = 1
        scrollDownButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
        scrollDownButton.direction = -1
        scrollUpButton.OnClick  = scrollUpButton.OnClick + ScrollButton_OnClick
        scrollUpButton.OnEnter = scrollUpButton.OnEnter + ScrollButton_OnEnter
        scrollUpButton.OnLeave = scrollUpButton.OnLeave + ScrollButton_OnLeave
        scrollDownButton.OnClick= scrollDownButton.OnClick + ScrollButton_OnClick
        scrollDownButton.OnEnter = scrollDownButton.OnEnter + ScrollButton_OnEnter
        scrollDownButton.OnLeave = scrollDownButton.OnLeave + ScrollButton_OnLeave

        self.OnValueChanged     = self.OnValueChanged + OnValueChanged
        self.OnMouseWheel       = self.OnMouseWheel + OnMouseWheel
        self.OnEnter            = self.OnEnter + OnEnter
        self.OnLeave            = self.OnLeave + OnLeave
    end

end)

__Sealed__()
class "HorizontalScrollBar" { ScrollBar }

__Sealed__()
class "VerticalScrollBar"   { ScrollBar }

-----------------------------------------------------------
--                  ViewHolder                           --
-----------------------------------------------------------

__Sealed__()
class "ViewHolder"(function()

    property "Position"             {
        type                        = NaturalNumber
    }

    property "Orientation"          {
        type                        = Orientation
    }

    function Destroy(self)
        self.Orientation = nil
        self.ContentView:Hide()
        self.ContentView:ClearAllPoints()
        self.ContentView:SetParent(nil)
    end

    __Arguments__{ LayoutFrame, Integer }
    function __ctor(self, contentView, itemViewType)
        self.ContentView = contentView
        self.ItemViewType = itemViewType
    end

end)

-----------------------------------------------------------
--          Decoration and item view                     --
--Each recyclerView can contain multiple item decoration --
-----------------------------------------------------------

__Sealed__()
class "ItemView"(function()

    property "ViewHolder"           {
        type                        = ViewHolder,
        handler                     = function(self, viewHolder)
            if viewHolder then
                viewHolder.Orientation = self.Orientation
            end
        end
    }

    property "Orientation"          {
        type                        = Orientation,
        handler                     = function(self, orientation)
            if self.ViewHolder then
                self.ViewHolder.Orientation = orientation
            end
        end
    }

    function GetContentLength(self)
        local length = 0
        if self.ViewHolder then
            if self.Orientation == Orientation.VERTICAL then
                length = self.ViewHolder.ContentView:GetHeight()
            elseif self.Orientation == Orientation.HORIZONTAL then
                length = self.ViewHolder.ContentView:GetWidth()
            end
        end
        return length
    end

    function GetLength(self)
        if self.Orientation == Orientation.VERTICAL then
            return self:GetHeight()
        elseif self.Orientation == Orientation.HORIZONTAL then
            return self:GetWidth()
        end
    end

    __Arguments__{ NEString }
    function GetItemDecorationView(self, name)
        local view = self.__ItemDecorations[name]
        if not view then
            view = Frame("ItemDecoration_" .. name, self)
            view:SetFrameStrata(self:GetFrameStrata())
            view:SetFrameLevel(self:GetFrameLevel())
            view:SetAllPoints(self)
            self.__ItemDecorations[name] = view
        end
        
        return view
    end

    function __ctor(self)
        self.__ItemDecorations = {}
    end

end)

__Sealed__()
class "ItemDecoration"(function()

    -- 返回每项item的间距
    -- left, right, top, bottom
    __Abstract__()
    function GetItemMargins(RecyclerView, ViewHolder)
        return 0, 0, 0, 0
    end

    __Arguments__{ RecyclerView, LayoutFrame, ViewHolder }
    __Abstract__()
    function Draw(self, recyclerView, parent, viewHolder)
    end

    __Arguments__{ RecyclerView }
    __Abstract__()
    function DrawOver(self, recyclerView)
    end

    __Arguments__{ NEString }
    function __ctor(self, name)
        self.Name = name
    end

end)

-----------------------------------------------------------
--                      Adapter                          --
-----------------------------------------------------------

__Sealed__()
class "Adapter"(function()

    property "Data"                 {
        type                        = List,
        handler                     = function(self, data)
            if self.RecyclerView then
                self.RecyclerView:Refresh()
            end
        end
    }

    property "RecyclerView"         {
        type                        = RecyclerView
    }
    
    __Arguments__{ NaturalNumber }
    function GetItemViewType(self, position)
        return 0
    end

    -- 获取item数量，必须是自然数
    __Abstract__()
    function GetItemCount(self)
        return self.Data and self.Data.Count or 0
    end

    __Arguments__{ Number }
    __Final__()
    function CreateViewHolder(self, viewType)
        return ViewHolder(self:OnCreateContentView(viewType, "ContentView"), viewType)
    end

    __Arguments__{ Number, NEString }
    __Abstract__()
    function OnCreateContentView(self, viewType, contentViewName)
    end

    __Arguments__{ ViewHolder, NaturalNumber }
    __Final__()
    function BindViewHolder(self, holder, position)
        if holder.Position ~= position then
            self:OnBindViewHolder(holder, position)
        end
        holder.Position = position
    end

    __Arguments__{ ViewHolder, NaturalNumber }
    __Abstract__()
    function OnBindViewHolder(self, holder, position)
    end

    __Arguments__{ ItemView }
    function RecycleViewHolder(self, itemView)
        local viewHolder = itemView.ViewHolder
        if not viewHolder then return end

        viewHolder:Destroy()
        
        local viewHolderCache = self.__ViewHolderCache[viewHolder.ItemViewType]
        if not viewHolderCache then
            viewHolderCache = {}
            self.__ViewHolderCache[viewHolder.ItemViewType] = viewHolderCache
        end

        tinsert(viewHolderCache, viewHolder)

        itemView.ViewHolder = nil
    end

    __Arguments__{ ItemView, NaturalNumber }
    function NeedRefresh(self, itemView, position)
        local itemViewType = self:GetItemViewType(position)
        return not itemView.ViewHolder or itemView.ViewHolder.Position ~= position or itemView.ViewHolder.ItemViewType ~= itemViewType
    end

    function GetViewHolderCount(self)
        local count = 0
        for _, cache in pairs(self.__ViewHolderCache) do
            count = count + #cache
        end

        return count
    end

    local function GetViewHolderFromCache(self, itemViewType)
        if self.__ViewHolderCache[itemViewType] then
            return tremove(self.__ViewHolderCache[itemViewType])
        end
    end

    __Arguments__{ ItemView, NaturalNumber }
    function AttachItemView(self, itemView, position)
        local itemViewType = self:GetItemViewType(position)

        if itemView.ViewHolder and itemView.ViewHolder.ItemViewType ~= itemViewType then
            self:RecycleViewHolder(itemView)
        end

        local viewHolder = itemView.ViewHolder

        if not viewHolder then
            viewHolder = GetViewHolderFromCache(self, itemViewType)
            if not viewHolder then
                viewHolder = self:CreateViewHolder(itemViewType)
            end
            viewHolder.ContentView:SetParent(itemView)
            viewHolder.ContentView:Show()
            itemView.ViewHolder = viewHolder
        end

        self:BindViewHolder(viewHolder, position)
    end

    function __ctor(self)
        self.__ViewHolderCache = {}
    end
    
end)

-----------------------------------------------------------
--                  LayoutManager                        --
-----------------------------------------------------------

__Sealed__()
class "LayoutManager"(function()

    property "RecylerView"          {
        type                        = RecyclerView,
        handler                     = function(self)
            self.LayoutPosition = nil
            self.LayoutOffset = nil
        end
    }

    property "LayoutPosition"       {
        type                        = NaturalNumber
    }

    property "LayoutOffset"         {
        type                        = Number
    }

    -- @param: position: item位置,第一个完整显示在RecyclerView可视范围内的item位置
    -- @param: offset: 该position对应的itemView当前滚动位置
    __Final__()
    __Arguments__{ NaturalNumber, Number }
    function Layout(self, position, offset)
        self.LayoutPosition = position
        self.LayoutOffset = offset
        self:OnLayout(position, offset)
    end

    __Abstract__()
    function OnLayout(self, position, offset)
    end

    __Abstract__()
    function UpdateItemViewSize(self, itemView)
    end

    __Abstract__()
    function LayoutItemView(self)
    end

    function RequestLayout(self)
        self:Layout(1, 0)
    end

    function ScrollToPosition(self, position)
        if position ~= self.LayoutPosition or self.LayoutOffset ~= 0 then
            self:Layout(position, 0)
        end
    end

end)

__Sealed__()
class "LinearLayoutManager"(function()
    inherit "LayoutManager"

    function LayoutItemViews(self)
        local recyclerView = self.RecyclerView
        if not recyclerView then return end
        
        local relativePoint = recyclerView.Orientation == Orientation.VERTICAL and "BOTTOMLEFT" or "TOPRIGHT"

        local lastItemView
        for _, itemView in recyclerView:GetItemViews() do
            itemView:ClearAllPoints()
            itemView:SetPoint("TOPLEFT", lastItemView or itemView:GetParent(), lastItemView and relativePoint or "TOPLEFT", 0, 0)
            lastItemView = itemView
        end
    end

    function UpdateItemViewSize(self, itemView)
        local recyclerView = self.RecyclerView
        if not recyclerView then return end

        local length = itemView:GetContentLength()
        local maxLeft, maxRight, maxTop, maxBottom = 0, 0, 0, 0

        for _, itemDecoration in recyclerView:GetItemDecorations() do
            local left, right, top, bottom = itemDecoration:GetItemMargins(recyclerView, itemView.ViewHolder)
            maxLeft = max(left, maxLeft)
            maxRight = max(right, maxRight)
            maxTop = max(top, maxTop)
            maxBottom = max(bottom, maxBottom)
        end

        local orientation = itemView.Orientation
        local contentView = itemView.ViewHolder.ContentView
        contentView:SetPoint("TOPLEFT", maxLeft, -maxTop)

        if orientation == Orientation.VERTICAL then
            length = maxTop + maxBottom + contentView:GetHeight()
            local width = recyclerView:GetWidth()
            contentView:SetWidth(width - maxLeft - maxRight)
            itemView:SetWidth(width)
            itemView:SetHeight(length)
        elseif orientation == Orientation.HORIZONTAL then
            length = maxLeft + maxRight + contentView:GetWidth()
            local height = recyclerView:GetHeight()
            contentView:SetHeight(height - maxTop - maxBottom)
            itemView:SetHeight(height)
            itemView:SetWidth(length)
        end
    end

    function GetItemViewByPosition(self, position)
        local recyclerView = self.RecyclerView
        local adapter = recyclerView.Adapter
        local itemView = recyclerView:GetItemViewByAdapterPosition(position)

        if not itemView then
            itemView = recyclerView:GetItemViewFromCache()
        end

        if adapter:NeedRefresh(itemView, position) then
            adapter:AttachItemView(itemView, position)
            self:UpdateItemViewSize(itemView)
            recyclerView:DrawItemDecorations(itemView)
        end

        itemView:Show()

        return itemView
    end

    function OnLayout(self, position, offset)
        print("OnLayout", position, offset)
        local recyclerView = self.RecyclerView
        if not recyclerView then return end

        local adapter = recyclerView.Adapter
        if not adapter then return end

        local startPosition = math.max(position - 1, 1)
        local itemCount = adapter:GetItemCount()
        if startPosition > itemCount then return end
        
        local contentLength = 0
        local adapterPosition = startPosition
        local itemViewMap = {}

        while contentLength <= recyclerView:GetLength() and adapterPosition <= itemCount do
            local itemView = self:GetItemViewByPosition(adapterPosition)
            tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            adapterPosition = adapterPosition + 1
            contentLength = contentLength + itemView:GetLength()
        end

        -- 额外添加一项
        -- 因为可能startPosition那一项长度直接超过contentLength导致position反而没添加
        if adapterPosition <= itemCount then
            local itemView = self:GetItemViewByPosition(adapterPosition)
            tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            contentLength = contentLength + itemView:GetLength()
        end
        

        adapterPosition = startPosition - 1

        while contentLength <= recyclerView:GetLength() and adapterPosition > 0 do
            local itemView = self:GetItemViewByPosition(adapterPosition)
            tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            adapterPosition = adapterPosition - 1
            contentLength = contentLength + itemView:GetLength()
        end

        -- 设置ItemView布局
        recyclerView:SetItemViews(itemViewMap)
        self:LayoutItemViews()
        
        -- set offset
        local scrollOffset = 0
        if contentLength > recyclerView:GetLength() then
            recyclerView:SetScrollBarVisible(true)
            local itemView, index = recyclerView:GetItemViewByAdapterPosition(position)
            if itemView and index > 1 then
                for i = 1, index - 1 do
                    scrollOffset = scrollOffset + recyclerView:GetItemView(i):GetLength()
                end
                scrollOffset = scrollOffset + offset

                -- 触底
                if contentLength - scrollOffset < recyclerView:GetLength() then
                    scrollOffset = contentLength - recyclerView:GetLength()
                end
            end
        else
            recyclerView:SetScrollBarVisible(false)
        end
        
        recyclerView:Scroll(scrollOffset)
    end

end)

-----------------------------------------------------------
--                    RecyclerView                       --
-----------------------------------------------------------

__Sealed__()
class "RecyclerView"(function()

    struct "ItemViewInfo"   {
        { name = "Position", type = NaturalNumber,  require = true },
        { name = "ItemView", type = ItemView,       require = true }
    }
    -------------------------------------------------------
    --                    Property                       --
    -------------------------------------------------------

    property "Orientation"          {
        type                        = Orientation,
        default                     = Orientation.VERTICAL,
        handler                     = "OnOrientationChanged"
    }

    property "LayoutManager"        {
        type                        = LayoutManager,
        handler                     = "OnLayoutManagerChanged"
    }

    property "Adapter"              {
        type                        = Adapter,
        handler                     = "OnAdapterChanged"
    }

    -------------------------------------------------------
    --                    Functions                      --
    -------------------------------------------------------

    __Arguments__{ ItemView }
    function DrawItemDecorations(self, itemView)
        for _, itemDecoration in pairs(self.__ItemDecorations) do
            itemDecoration:Draw(self, itemView:GetItemDecorationView(itemDecoration.Name), itemView.ViewHolder)
        end
    end

    -- 返回ItemDecorations的迭代器
    function GetItemDecorations(self)
        return pairs(self.__ItemDecorations)
    end

    __Arguments__{ NEString }
    function GetItemDecoration(self, name)
        return self.__ItemDecorations[name]
    end

    __Arguments__{ ItemDecoration }
    function AddItemDecoration(self, itemDecoration)
        self.__ItemDecorations[itemDecoration.Name] = itemDecoration
    end

    __Arguments__{ ItemDecoration }
    function RemoveItemDecoration(self, itemDecoration)
        self.__ItemDecorations[itemDecoration.Name] = nil
    end

    function OnLayoutManagerChanged(self, layoutManager, oldLayoutManager)
        self:RecycleItemViews(self.Adapter)

        if oldLayoutManager then
            oldLayoutManager.RecyclerView = nil
        end

        if layoutManager then
            layoutManager.RecyclerView = self
        end

        self:Refresh()
    end

    function OnOrientationChanged(self)
        for _, itemView in ipairs(self.__ItemViews) do
            itemView.Orientation = self.Orientation
        end

        self:Refresh()
    end

    function OnAdapterChanged(self, newAdapter, oldAdapter)
        self:RecycleItemViews(oldAdapter)

        if oldAdapter then
            oldAdapter.RecyclerView = nil
        end

        if newAdapter then
            newAdapter.RecyclerView = self
        end

        self:Refresh()
    end

    function Refresh(self)
        self:RefreshScrollBar()
        if self.LayoutManager then
            self.LayoutManager:RequestLayout()
        end
    end

    function RefreshScrollBar(self)
        local scrollBar = self:GetScrollBar()

        local adapter = self.Adapter
        if adapter then
            local count = adapter:GetItemCount()
            if count > 0 then
                scrollBar:SetRange(count)
            end
        end
    end

    -- 跳转到指定item
    __Arguments__{ NaturalNumber }
    function ScrollToPosition(self, position)
        if self.LayoutManager then
            self.LayoutManager:ScrollToPosition(position)
        end
    end

    -- 获取Scrollbar
    function GetScrollBar(self)
        if self.Orientation == Orientation.HORIZONTAL then
            return self:GetChild("HorizontalScrollBar")
        elseif self.Orientation == Orientation.VERTICAL then
            return self:GetChild("VerticalScrollBar")
        end
    end

    __Arguments__{ Boolean/false }
    function SetScrollBarVisible(self, show)
        self:GetScrollBar():SetShown(show)
    end

    function HideScrollBars(self)
        self:GetChild("VerticalScrollBar"):Hide()
        self:GetChild("HorizontalScrollBar"):Hide()
    end

    function GetLength(self)
        if self.Orientation == Orientation.HORIZONTAL then
            return self:GetWidth()
        elseif self.Orientation == Orientation.VERTICAL then
            return self:GetHeight()
        end
    end

    -- 从指定index开始回收ItemViews
    __Arguments__{ Adapter/nil, NaturalNumber/1 }
    function RecycleItemViews(self, adapter, index)
        for i = #self.__ItemViews, index, -1 do
            self:RecycleItemView(i, adapter)
        end
    end
    
    __Arguments__{ NaturalNumber, Adapter/nil }
    function RecycleItemView(self, index, adapter)
        local itemView = tremove(self.__ItemViews, index)
        self:RecycleItemView(itemView, adapter)
    end

    __Arguments__{ ItemView, Adapter/nil }
    function RecycleItemView(self, itemView, adapter)
        if adapter then
            adapter:RecycleViewHolder(itemView)
        end
        itemView:Hide()
        itemView:ClearAllPoints()
        tinsert(self.__ItemViewCache, itemView)
    end

    __Arguments__{ struct {ItemViewInfos} / nil }
    function SetItemViews(self, itemViewInfos)
        if not itemViewInfos then
            self:RecycleItemViews(self.Adapter)
            return
        end

        sort(itemViewInfos, function(a, b)
            return a.Position < b.Position
        end)

        local items = {}

        for _, itemViewInfo in ipairs(itemViewInfos) do
            -- 有相同的itemView，说明被复用了，将其移除
            -- 未被移除的会被回收
            for k, v in pairs(self.__ItemViews) do
                if v == itemViewInfo.ItemView then
                    self.__ItemViews[k] = nil
                    break
                end
            end
            tinsert(items, itemViewInfo.ItemView)
        end

        -- 回收没用的ItemView
        for _, itemView in pairs(self.__ItemViews) do
            self:RecycleItemView(itemView, self.Adapter)
        end

        self.__ItemViews = items
    end

    function GetItemViews(self)
        return ipairs(self.__ItemViews)
    end

    local function CreateItemView(self)
        self.__ItemViewCount = self.__ItemViewCount + 1
        local itemView = ItemView("ItemView" .. self.__ItemViewCount, self:GetChild("ScrollChild"))
        return itemView
    end

    function GetItemViewFromCache(self)
        local itemView = tremove(self.__ItemViewCache)
        if not itemView then
            itemView = CreateItemView(self)
            itemView.Orientation = self.Orientation
        end

        return itemView
    end

    -- 获取ItemView
    __Arguments__{ NaturalNumber }
    function GetItemView(self, index)
        return self.__ItemViews[index]
    end

    function GetItemViewCount(self)
        return #self.__ItemViews, #self.__ItemViewCache
    end

    -- 通过adapter position获取ItemView
    -- 可能为nil
    function GetItemViewByAdapterPosition(self, position)
        for index, itemView in ipairs(self.__ItemViews) do
            local viewHolder = itemView.ViewHolder
            if viewHolder and viewHolder.Position == position then
                return itemView, index
            end
        end
    end

    -- @itemView 返回第一个完整可见的item
    -- @index itemView index
    -- @offset 该item位置
    function GetFirstCompletelyVisibleItemView(self)
        local itemViewCount = #self.__ItemViews
        if itemViewCount <= 0 then return end

        local scrollOffset = self:GetScrollOffset()
        local offset = 0
        local itemViewCount = #self.__ItemViews

        for index = 1, itemViewCount do
            local itemView = self.__ItemViews[index]

            if offset > scrollOffset then
                return itemView, index, offset
            end
           
            if index ~= itemViewCount then
                offset = offset + itemView:GetLength()
            end
        end
    
        return self.__ItemViews[itemViewCount], itemViewCount, offset
    end

    function GetScrollRange(self)
        local orientation = self.Orientation
        if orientation == Orientation.VERTICAL then
            return self:GetVerticalScrollRange()
        elseif orientation == Orientation.HORIZONTAL then
            return self:GetHorizontalScrollRange()
        end
    end

    function GetScrollOffset(self)
        local orientation = self.Orientation
        if orientation == Orientation.VERTICAL then
            return self:GetVerticalScroll()
        elseif orientation == Orientation.HORIZONTAL then
            return self:GetHorizontalScroll()
        end
    end

    function Scroll(self, offset)
        local orientation = self.Orientation
        if orientation == Orientation.VERTICAL then
            self:SetVerticalScroll(offset)
        elseif orientation == Orientation.HORIZONTAL then
            self:SetHorizontalScroll(offset)
        end
    end

    local function OnMouseWheel(self, delta)
        if not self.LayoutManager or not self.Adapter then return end
        
        local scrollRange = self:GetScrollRange()
        if scrollRange <= 0 then return end

        local length = self:GetLength() / 20
        local offset = self:GetScrollOffset() - length * delta

        -- 直接滚动
        self:Scroll(offset)

        -- 判断是否滚动出范围
        -- 滚动出范围，重新刷新
        local itemView, index, curOffset = self:GetFirstCompletelyVisibleItemView()
        local position = itemView.ViewHolder.Position
        if offset > scrollRange or offset < 0 then
            offset = -(curOffset - offset)
            
            if position == 1 then
                offset = 0
            end

            if itemView then
                self.LayoutManager:Layout(itemView.ViewHolder.Position, offset)
            end
        end

        -- 改变ScrollBar的值
        self:GetScrollBar():SetValue(position)
    end

    __Template__{
        VerticalScrollBar           = VerticalScrollBar,
        HorizontalScrollBar         = HorizontalScrollBar,
        ScrollChild                 = Frame
    }
    function __ctor(self)
        self.__ItemViewCount = 0
        self.__ItemViews = {}
        self.__ItemViewCache = {}
        self.__ItemDecorations = {}

        self.OnMouseWheel = self.OnMouseWheel + OnMouseWheel

        -- set scroll child
        local scrollChild = self:GetChild("ScrollChild")
        self:SetScrollChild(scrollChild)
        scrollChild:SetPoint("TOPLEFT")
        scrollChild:SetSize(1, 1)
        
        -- set scroll bar
        self:HideScrollBars()
    end

end)


Style.UpdateSkin("Default", {
    [ScrollBar]                                 = {
        fadeout                                 = true
    },

    [VerticalScrollBar]                         = {
        width                                   = 16,
        thumbTexture                            = {
            file                                = [[Interface\Buttons\UI-ScrollBar-Knob]],
            texCoords                           = RectType(0.20, 0.80, 0.125, 0.875),
            size                                = Size(18, 24),
        },

        ScrollUpButton                          = {
            location                            = { Anchor("BOTTOM", 0, 0, nil, "TOP") },
            size                                = Size(18, 16),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Up]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Down]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Disabled]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Highlight]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
                alphaMode                       = "ADD",
            }
        },

        ScrollDownButton                        = {
            location                            = { Anchor("TOP", 0, 0, nil, "BOTTOM") },
            size                                = Size(18, 16),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Up]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Down]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Disabled]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Highlight]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
                alphaMode                       = "ADD",
            }
        }
    },

    [HorizontalScrollBar]                       = {
        height                                  = 16,
        orientation                             = "HORIZONTAL",
        thumbTexture                            = {
            file                                = [[Interface\Buttons\UI-ScrollBar-Knob]],
            texCoords                           = {
                ULx                             = 0.8,
                ULy                             = 0.125,
                LLx                             = 0.2,
                LLy                             = 0.125,
                URx                             = 0.8,
                URy                             = 0.875,
                LRx                             = 0.2,
                LRy                             = 0.875
            },
            size                                = Size(24, 18),
        },

        ScrollUpButton                          = {
            location                            = { Anchor("RIGHT", 0, 0, nil, "LEFT") },
            size                                = Size(16, 18),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Up]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Down]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Disabled]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Highlight]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
                alphaMode                       = "ADD",
            }
        },

        ScrollDownButton                        = {
            location                            = { Anchor("LEFT", 0, 0, nil, "RIGHT") },
            size                                = Size(16, 18),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Up]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Down]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Disabled]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Highlight]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
                alphaMode                       = "ADD",
            }
        }
    },

    [RecyclerView]                              = {
        VerticalScrollBar                       = {
            location                            = {
                Anchor("TOPLEFT", 2, -16, nil, "TOPRIGHT"),
                Anchor("BOTTOMLEFT", 2, 16, nil, "BOTTOMRIGHT")
            }
        },

        HorizontalScrollBar                     = {
            location                            = {
                Anchor("TOPLEFT", 16, -2, nil, "BOTTOMLEFT"),
                Anchor("TOPRIGHT", -16, 2, nil, "BOTTOMRIGHT")
            }
        }
    }
})
