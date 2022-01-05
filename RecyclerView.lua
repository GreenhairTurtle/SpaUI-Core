---@diagnostic disable: undefined-global
-----------------------------------------------------------
--         Warcraft version of Android recyclerView      --
-----------------------------------------------------------
Scorpio "SpaUI.Widget.RecyclerView" ""

namespace "SpaUI.Widget.RecyclerView"

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

    local function OnValueChanged(self, value)
        Show(self)
        RefreshScrollButtonStates(self)

        local orientation = self:GetOrientation()
        if orientation == Orientation.HORIZONTAL then
            self:GetParent():SetHorizontalScroll(value)
        elseif orientation == Orientation.VERTICAL then
            self:GetParent():SetVerticalScroll(value)
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
        -- do nothing
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
        self.Position = nil
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
    inherit "Frame"

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

end)

__Sealed__()
class "ItemDecoration"(function()

    -- 返回每项item的间距
    -- left, right, top, bottom
    __Abstract__()
    function GetItemMargins()
        return 0, 0, 0, 0
    end

    __Arguments__{ RecyclerView, ItemView, NaturalNumber }
    __Abstract__()
    function Draw(self, recyclerView, itemView)
    end

    __Arguments__{ RecyclerView }
    __Abstract__()
    function DrawOver(self, recyclerView)
    end

end)

-----------------------------------------------------------
--                      Adapter                          --
-----------------------------------------------------------

__Sealed__()
class "Adapter"(function()

    property "Data"                 {
        type                        = List
    }
    
    __Arguments__{ NaturalNumber }
    function GetItemViewType(self, position)
        return 0
    end

    -- 获取item数量，必须是自然数
    __Abstract__()
    function GetItemCount(self)
        return 0
    end

    __Arguments__{ LayoutFrame, Number }
    __Final__()
    function CreateViewHolder(self, parent, viewType)
        return ViewHolder(self:OnCreateView(parent, viewType), viewType)
    end

    -- 返回列表view
    __Arguments__{ LayoutFrame, Number }
    __Abstract__()
    function OnCreateView(self, parent, viewType)
    end

    __Arguments__{ ViewHolder, NaturalNumber }
    __Final__()
    function BindViewHolder(self, holder, position)
        if holder.Position ~= position then
            OnBindViewHolder(self, holder, position)
        end
        holder.Position = position
    end

    __Arguments__{ ViewHolder, NaturalNumber }
    __Abstract__()
    function OnBindViewHolder(self, holder, position)
    end

    __Arguments__{ ItemView }
    function RecycleViewHoder(self, itemView)
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

    local function GetViewHolderFromCache(self, itemViewType)
        if self.__ViewHolderCache[itemViewType] then
            return tremove(self.__ViewHolderCache[itemViewType])
        end
    end

    __Arguments__{ ItemView, NaturalNumber }
    function AttachItemView(self, itemView, position)
        local itemViewType = self:GetItemViewType(position)

        if itemView.ViewHolder.ItemViewType ~= itemViewType then
            self:RecycleViewHoder(itemView)
        end

        local viewHolder = itemView.ViewHolder

        if not viewHolder then
            viewHolder = GetViewHolderFromCache(self, itemViewType)
            if viewHolder then
                viewHolder.ContentView:SetParent(itemView)
                viewHolder.ContentView:Show()
            else
                viewHolder = self:CreateViewHolder(itemView, itemViewType)
            end
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
        type                        = RecyclerView
    }

    -- @param: position: item位置,第一个完整显示在RecyclerView可视范围内的item位置
    -- @param: offset: 该position对应的itemView当前滚动位置
    __Abstract__()
    function Layout(self, position, offset)
    end

    __Abstract__()
    function UpdateItemViewSize(self, itemView)
    end

    __Abstract__()
    function OnOrientationChanged(self, orientation)
    end

    __Abstract__()
    function LayoutItemView(self)
    end

    function RequestLayout(self)
        self:Layout(0, 0)
    end

    function ScrollToPosition(self, position)
        self:Layout(position, 0)
    end

end)

__Sealed__()
class "LinearLayoutManager"(function()
    inherit "LayoutManager"

    function OnOrientationChanged(self, orientation)
        local recyclerView = self.RecyclerView
        if not recyclerView then return end

        local itemView, index = recyclerView:GetFirstCompletelyVisibleItemView()
        if itemView and itemView.ViewHolder and itemView.ViewHolder.Position then
            self:Layout(itemView.ViewHolder.Position, 0)
        end
    end

    function LayoutItemViews(self)
        local recyclerView = self.RecyclerView
        if not recyclerView then return end
        
        local relativePoint = recyclerView.Orientation == Orientation.VERTICAL and "BOTTOMLEFT" or "TOPRIGHT"

        local lastItemView
        for index, itemView in recyclerView:GetItemViews() do
            itemView:ClearAllPoints()
            itemView:SetPoint("TOPLEFT", lastItemView or itemView:GetParent(), relativePoint)
            lastItemView = index > 1 and itemView
        end
    end

    function UpdateItemViewSize(self, itemView)
        local length = itemView:GetContentLength()
        local maxLeft, maxRight, maxTop, maxBottom = 0, 0, 0, 0

        for _, itemDecoration in recyclerView:GetItemDecorations() do
            local left, right, top, bottom = itemDecoration:GetItemMargins()
            maxLeft = max(left, maxLeft)
            maxRight = max(right, maxRight)
            maxTop = max(top, maxTop)
            maxBottom = max(bottom, maxBottom)
        end

        local orientation = itemView.Orientation
        if orientation == Orientation.VERTICAL then
            length = length + maxTop + maxBottom
            itemView:SetHeight(length)
            itemView:SetWidth(recyclerView:GetWidth())
        elseif orientation == Orientation.HORIZONTAL then
            length = length + maxLeft + maxBottom
            itemView:SetWidth(length)
            itemView:SetHeight(recyclerView:GetHeight())
        end

        return length
    end

    function Layout(self, position, offset)
        local recyclerView = self.RecyclerView
        if not recyclerView then return end

        local adapter = recyclerView.Adapter
        if not adapter then return end

        local startPosition = math.max(position - 1, 1)
        local itemCount = adapter:GetItemCount()
        if startPosition > itemCount then return end
        
        local itemViewIndex, contentLength = 1, 0
        local adapterPosition = startPosition
        local itemViewMap = {}
        -- 用于排序
        local itemViewPositions = {}

        while contentLength <= recyclerView:GetLength() and adapterPosition <= itemCount do
            local itemView = recyclerView:GetItemView(itemViewIndex)

            adapter:AttachItemView(itemView, adapterPosition)
            local itemLength = self:UpdateItemViewSize(itemView)
            recyclerView:DrawItemDecorations(itemView)
            itemView:Show()

            itemViewMap[adapterPosition] = itemView
            tinsert(itemViewPositions, adapterPosition)

            adapterPosition = adapterPosition + 1
            contentLength = contentLength + itemLength
            itemViewIndex = itemViewIndex + 1
        end

        adapterPosition = startPosition - 1

        while contentLength <= recyclerView:GetLength() and adapterPosition > 0 do
            local itemView = recyclerView:GetItemView(itemViewIndex)

            adapter:AttachItemView(itemView, adapterPosition)
            local itemLength = self:UpdateItemViewSize(itemView)
            recyclerView:DrawItemDecorations(itemView)
            itemView:Show()

            itemViewMap[adapterPosition] = itemView
            tinsert(itemViewPositions, adapterPosition)

            adapterPosition = adapterPosition + 1
            contentLength = contentLength + itemLength
            itemViewIndex = itemViewIndex + 1
        end

        -- 设置ItemView布局
        sort(itemViewPositions)
        for index, itemViewPosition in ipairs(itemViewPositions) do
            local itemView = itemViewMap[itemViewPosition]
            recyclerView:SetItemView(index, itemView)
        end
        recyclerView:RecycleItemViews(adapter, itemViewIndex)
        self:LayoutItemViews()
        
        -- set offset
        local itemView, index = recyclerView:GetItemViewByAdapterPosition(position)
        if itemView then
            local length = 0
            for i = 1, index - 1 do
                length = length + recyclerView:GetItemView(i):GetLength()
            end
            length = length + offset
            recyclerView:Scroll(length)
        end
    end

end)

-----------------------------------------------------------
--                    RecyclerView                       --
-----------------------------------------------------------

__Sealed__()
class "RecyclerView"(function()

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
        for _, itemDecoration in ipairs(self.__ItemDecorations) do
            itemDecoration:Draw(self, itemView)
        end
    end

    -- 返回ItemDecorations的迭代器
    function GetItemDecorations(self)
        return ipairs(self.__ItemDecorations)
    end

    __Arguments__{ NaturalNumber }
    function GetItemDecoration(self, index)
        return self.__ItemDecorations[index]
    end

    __Arguments__{ ItemDecoration }
    function AddItemDecoration(self, itemDecoration)
        return tinsert(self.__ItemDecorations, itemDecoration)
    end

    __Arguments__{ ItemDecoration }
    function RemoveItemDecoration(self, itemDecoration)
        return tDeleteItem(self.__ItemDecorations, itemDecoration)
    end

    function OnLayoutManagerChanged(self, layoutManager)
        self:RecyclerItemViews(self.Adapter)
        if layoutManager then
            layoutManager:RequestLayout()
        end
    end

    function OnOrientationChanged(self)
        local verticalScrollBar = self:GetChild("VerticalScrollBar")
        local horizontalScrollBar = self:GetChild("HorizontalScrollBar")

        if self.Adapter then
            if self.Orientation == Orientation.VERTICAL then
                verticalScrollBar:Show()
                horizontalScrollBar:Hide()
            elseif self.Orientation == Orientation.HORIZONTAL then
                verticalScrollBar:Hide()
                horizontalScrollBar:Show()
            end
        else
            verticalScrollBar:Hide()
            horizontalScrollBar:Hide()
        end

        for _, itemView in ipairs(self.__ItemViews) do
            itemView.Orientation = self.Orientation
        end
        
        if self.LayoutManager then
            self.LayoutManager:OnOrientationChanged(self.Orientation)
        end
    end

    function OnAdapterChanged(self, newAdapter, oldAdapter)
        local scrollBar = self:GetScrollBar()

        self:RecyclerItemViews(oldAdapter)

        if newAdapter then
            scrollBar:SetMinMaxValues(0, newAdapter:GetItemCount())
            scrollBar:SetValue(0)
            scrollBar:Show()
        else
            scrollBar:Hide()
        end

        if self.LayoutManager then
            self.LayoutManager:RequestLayout()
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

    function GetLength(self)
        if self.Orientation == Orientation.HORIZONTAL then
            return self:GetWidth()
        elseif self.Orientation == Orientation.VERTICAL then
            return self:GetHeight()
        end
    end

    -- 从指定index开始回收ItemViews
    __Arguments__{ Adapter, NaturalNumber/1 }
    function RecycleItemViews(self, adapter, index)
        for i = index, #self.__ItemViews do
            self:RecycleItemView(adapter, i)
        end
    end
    
    __Arguments__{ Adapter, NaturalNumber }
    function RecycleItemView(self, adapter, index)
        local itemView = tremove(self.__ItemView, index)
        if itemView then
            if adapter then
                adapter:RecycleViewHoder(itemView)
            end
            itemView:Hide()
            itemView:ClearAllPoints()
            tinsert(self.__ItemViewCache, itemView)
        end
    end

    __Arguments__{ NaturalNumber, ItemView }
    function SetItemView(self, index, itemView)
        self.__ItemViews[index] = itemView
    end

    function GetItemViews(self)
        return ipairs(self.__ItemViews)
    end

    local function CreateItemView(self)
        self.__ItemViewCount = self.__ItemViewCount + 1
        local itemView = ItemView("ItemView" .. self.__ItemViewCount, self:GetChild("ScrollChild"))
        return itemView
    end

    -- 获取指定index的ItemView
    __Arguments__{ NaturalNumber }
    function GetItemView(self, index)
        if index <= 0 then
            throw("GetItemView index 必须大于 0")
        end
        if index > #self.__ItemViews + 1 then
            throw("GetItemView index 最多只能比现有的ItemViews数量 +1 ")
        end

        local itemView = self.__ItemViews[index]
        if not itemView then
            itemView = tremove(self.__ItemViewCache)
            if not itemView then
                itemView = CreateItemView(self)
            end
            itemView.Orientation = self.Orientation
            self.__ItemViews[index] = itemView
        end

        return itemView
    end

    function GetItemViewCount(self)
        return #self.__ItemViews
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

    function GetFirstCompletelyVisibleItemView(self)
        local itemViewCount = #self.__ItemViews
        if itemViewCount <= 0 then return end

        local scrollOffset = self:GetScrollOffset()
        local offset = 0

        for index, itemView in ipairs(self.__ItemViews) do
            if scrollOffset <= offset then
                return itemView, index
            end
        end
    
        return self.__ItemViews[itemViewCount], itemViewCount
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


    local function OnVerticalScroll(self, offset)
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

        local scrollChild = self:GetChild("ScrollChild")
        self:SetScrollChild(scrollChild)
        scrollChild:SetPoint("TOPLEFT")
        scrollChild:SetSize(1, 1)
        
        self:OnOrientationChanged()

        self.OnVerticalScroll = self.OnVerticalScroll + OnVerticalScroll
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
                Anchor("TOPLEFT", 2, -18, nil, "TOPRIGHT"),
                Anchor("BOTTOMLEFT", 2, 18, nil, "BOTTOMRIGHT")
            }
        },

        HorizontalScrollBar                     = {
            location                            = {
                Anchor("TOPLEFT", 18, -2, nil, "BOTTOMLEFT"),
                Anchor("TOPRIGHT", 18, 2, nil, "BOTTOMRIGHT")
            }
        }
    }
})
