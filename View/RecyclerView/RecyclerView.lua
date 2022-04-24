-----------------------------------------------------------
--         Warcraft version of Android recyclerView      --
-----------------------------------------------------------

PLoop(function(ENV)

    namespace "SpaUI.Widget.Recycler"

    import "Scorpio.UI.Style"

    class "ItemDecoration" {}

    class "ItemView" { Button }
    
    class "RecyclerView" { ScrollFrame }

    -----------------------------------------------------------
    --                     ScrollBar                         --
    -----------------------------------------------------------

    __Sealed__()
    class "ScrollBar"(function()
        inherit "Frame"

        local function ScrollToCursorValue(self)
            local recyclerView = self:GetParent()
            if not recyclerView then return end

            local uiScale, cursorX, cursorY = self:GetEffectiveScale(),  GetCursorPosition()
            local left, top = self:GetLeft(), self:GetTop()
            cursorX, cursorY = cursorX/uiScale, cursorY/uiScale
            
            local offset, length = 0, 0

            if self.Orientation == Orientation.HORIZONTAL then
                offset = cursorX - left
                length = self:GetWidth()
            elseif self.Orientation == Orientation.VERTICAL then
                offset = top - cursorY
                length = self:GetHeight()
            end

            if offset > length then
                offset = length
            elseif offset < 0 then
                offset = 0
            end

            local value = offset / length * self.__Range
            if value < 0 then
                value = 0
            end

            recyclerView:ScrollToLength(value)
        end

        local function Thumb_OnUpdate(self, elapsed)
            self.timeSinceLast = self.timeSinceLast + elapsed
            if self.timeSinceLast >= 0.08 then
                self.timeSinceLast = 0
                ScrollToCursorValue(self:GetParent())
            end
        end

        local function Thumb_OnMouseUp(self, button)
            self.OnUpdate = self.OnUpdate - Thumb_OnUpdate
        end

        local function Thumb_OnMouseDown(self, button)
            if button == "LeftButton" then
                self.timeSinceLast = 0
                self.OnUpdate = self.OnUpdate + Thumb_OnUpdate
            end
        end

        local function OnMouseWheel(self, delta)
            local recyclerView = self:GetParent()
            if recyclerView then
                recyclerView:OnMouseWheel(delta)
            end
        end
        
        local function OnMouseDown(self, button)
            ScrollToCursorValue(self)
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

        local function Show(self)
            self:SetAlpha(1)
            local current = GetTime()
            self.ShowTime = current
            self.FadeoutTarget = current + self.FadeoutDelay + self.FadeoutDuration
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

        local function RefreshThumbAndScrollButton(self, from, to, total)
            -- update thumb
            local thumb = self:GetChild("Thumb")
            local length = self:GetLength()
            local thumbLength = math.abs(to - from) / total * length
            local offset = from / total * length
            local point = "TOPLEFT"
            
            if offset + thumbLength > length then
                offset = 0
                point = "BOTTOMRIGHT"
            end
    
            if thumbLength > length then 
                thumbLength = length
            end

            thumb:ClearAllPoints()
            if self.Orientation == Orientation.HORIZONTAL then
                thumb:SetWidth(thumbLength)
                thumb:SetHeight(self:GetHeight())
                thumb:SetPoint(point, offset, 0)
            elseif self.Orientation == Orientation.VERTICAL then
                thumb:SetHeight(thumbLength)
                thumb:SetWidth(self:GetWidth())
                thumb:SetPoint(point, 0, -offset)
            end

            -- update scroll button
            local scrollUpButton = self:GetChild("ScrollUpButton")
            local scrollDownButton = self:GetChild("ScrollDownButton")
            if from <= 0 then
                scrollUpButton:Disable()
            else
                scrollUpButton:Enable()
            end

            if to >= total then
                scrollDownButton:Disable()
            else
                scrollDownButton:Enable()
            end
        end

        __Final__()
        function GetLength(self)
            if self.Orientation == Orientation.HORIZONTAL then
                return self:GetWidth()
            elseif self.Orientation == Orientation.VERTICAL then
                return self:GetHeight()
            end
        end

        __Final__()
        __Arguments__{ Number, Number, Number }
        function RequestLayoutInternal(self, from, to, total)
            self.__Range = total
            Show(self)
            RefreshThumbAndScrollButton(self, from, to, total)
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
            default                 = 4
        }

        -- 渐隐延迟
        property "FadeoutDelay"     {
            type                    = Number,
            default                 = 2
        }

        -- 方向
        property "Orientation"      {
            type                    = Orientation,
            default                 = Orientation.VERTICAL
        }

        __Template__{
            ScrollUpButton          = Button,
            ScrollDownButton        = Button,
            Thumb                   = Button
        }
        __InstantApplyStyle__()
        function __ctor(self)
            self:SetAlpha(0)

            local scrollUpButton        = self:GetChild("ScrollUpButton")
            local scrollDownButton      = self:GetChild("ScrollDownButton")
            local thumb                 = self:GetChild("Thumb")
            
            scrollUpButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
            scrollUpButton.direction    = 1
            scrollDownButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
            scrollDownButton.direction  = -1

            scrollUpButton.OnClick      = scrollUpButton.OnClick + ScrollButton_OnClick
            scrollUpButton.OnEnter      = scrollUpButton.OnEnter + ScrollButton_OnEnter
            scrollUpButton.OnLeave      = scrollUpButton.OnLeave + ScrollButton_OnLeave

            scrollDownButton.OnClick    = scrollDownButton.OnClick + ScrollButton_OnClick
            scrollDownButton.OnEnter    = scrollDownButton.OnEnter + ScrollButton_OnEnter
            scrollDownButton.OnLeave    = scrollDownButton.OnLeave + ScrollButton_OnLeave

            thumb.OnMouseDown           = thumb.OnMouseDown + Thumb_OnMouseDown
            thumb.OnMouseUp             = thumb.OnMouseUp + Thumb_OnMouseUp

            self.OnMouseWheel           = self.OnMouseWheel + OnMouseWheel
            self.OnEnter                = self.OnEnter + OnEnter
            self.OnLeave                = self.OnLeave + OnLeave
            self.OnMouseDown            = self.OnMouseDown + OnMouseDown
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

        property "DataPosition"         {
            type                        = NaturalNumber
        }

        property "Orientation"          {
            type                        = Orientation
        }

        property "ContentView"          {
            type                        = LayoutFrame
        }

        function Destroy(self)
            self.Orientation = nil
            self.Position = nil
            self.DataPosition = nil

            -- 对于正常的Item，ContentView不可能为nil
            -- 但Header、Footer、Empty所在的ViewHolder则会在回收时将ContentView设置为nil
            if self.ContentView then
                self.ContentView:Hide()
                self.ContentView:ClearAllPoints()
                self.ContentView:SetParent(nil)
            end

            -- 清除子控件事件
            if self.__ChildScripts then
                wipe(self.__ChildScripts)
            end
        end

        function IsHeaderView(self)
            return Adapter.HEADER_VIEW == self.ItemViewType
        end

        function IsFooterView(self)
            return Adapter.FOOTER_VIEW == self.ItemViewType
        end

        function IsEmptyView(self)
            return Adapter.EMPTY_VIEW == self.ItemViewType
        end

        function IsDataView(self)
            return not self:IsHeaderView() and not self:IsFooterView() and not self:IsEmptyView()
        end

        __Arguments__{ NEString }
        function GetChild(self, name)
            return self.ContentView and self.ContentView:GetChild(name)
        end

        __Arguments__{ NEString, -LayoutFrame }
        function GetChild(self, name, class)
            if not self.ContentView then return end

            local view = self.ContentView:GetChild(name)
            if not view then
                view = class(name, self.ContentView)
            end

            return view
        end

        -- 为子控件添加Script处理
        -- 只有添加了Script处理的子组件才会被Adapter的ItemChildListener回调
        -- 只应该在Adapter.OnBindViewHolder函数内使用
        __Arguments__{ UIObject, ScriptsType }
        function AddChildScript(self, child, script)
            if not child:HasScript(script) then return end

            if not self.__ChildScripts then
                self.__ChildScripts = {}
            end

            local scripts = self.__ChildScripts[child]
            if not scripts then
                scripts = {}
                self.__ChildScripts[child] = scripts
            end
            
            if not tContains(scripts, script) then
                tinsert(scripts, script)
            end
        end

        __Arguments__{ NEString, ScriptsType }
        function AddChildScript(self, name, script)
            self:AddChildScript(self:GetChild(name), script)
        end

        function GetChildScripts(self)
            return self.__ChildScripts
        end

        function GetContentLength(self)
            local length = 0
            if self.Orientation == Orientation.VERTICAL then
                length = self.ContentView:GetHeight()
            elseif self.Orientation == Orientation.HORIZONTAL then
                length = self.ContentView:GetWidth()
            end
            return length
        end

        __Arguments__{ Number}
        function SetContentLength(self, length)
            if not self.ContentView then return end
            if length < 0 then length = 0 end

            if self.Orientation == Orientation.VERTICAL then
                self.ContentView:SetHeight(length)
            elseif self.Orientation == Orientation.HORIZONTAL then
                self.ContentView:SetWidth(length)
            end
        end

        __Arguments__{ Integer }
        function __ctor(self, itemViewType)
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

        property "DecorationViews"      {
            type                        = RawTable,
            get                         = function(self)
                self.__DecorationViews = self.__DecorationViews or {}
                return self.__DecorationViews
            end,
            set                         = false
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
            return self.ViewHolder and self.ViewHolder:GetContentLength()
        end

        function GetLength(self)
            if self.Orientation == Orientation.VERTICAL then
                return self:GetHeight()
            elseif self.Orientation == Orientation.HORIZONTAL then
                return self:GetWidth()
            end
        end

        local function UnregisterAllScripts(self)
            for _, event in Enum.GetEnumValues(ScriptsType) do
                if self:HasScript(event) then
                    self[event] = nil
                end
            end
        end

        function Destroy(self)
            self:Hide()
            self:ClearAllPoints()
            self:SetParent(nil)
            self:RegisterForClicks(nil)
            UnregisterAllScripts(self)
        end

    end)

    __Sealed__()
    class "ItemDecoration"(function()

        -- 返回每项item的间距
        -- left, right, top, bottom
        __Abstract__()
        __Arguments__{ RecyclerView, ViewHolder }
        function GetItemMargins(recyclerView, viewHolder)
            return 0, 0, 0, 0
        end

        -- 返回DecorationView
        __Abstract__()
        function OnCreateDecorationView(self)
        end

        -- 返回Overlay View
        function OnCreateOverlayView(self)
        end

        __Arguments__{ RecyclerView, LayoutFrame, ViewHolder }
        __Abstract__()
        function Draw(self, recyclerView, decorationView, viewHolder)
        end

        __Arguments__{ RecyclerView, LayoutFrame }
        __Abstract__()
        function DrawOver(self, recyclerView, overlayView)
        end

        __Arguments__{ ItemView }
        function RecycleDecorationView(self, itemView)
            local decorationView = itemView.DecorationViews[self]
            if not decorationView then return end

            decorationView:Hide()
            decorationView:ClearAllPoints()
            decorationView:SetParent(nil)
            tinsert(self.__DecorationViewCache, decorationView)

            itemView.DecorationViews[self] = nil
        end

        __Arguments__{ RecyclerView, ItemView }
        function AttachItemView(self, recyclerView, itemView)
            local decorationView = itemView.DecorationViews[self]
            
            if not decorationView then
                decorationView = tremove(self.__DecorationViewCache)

                if not decorationView then
                    decorationView = self:OnCreateDecorationView()
                end
            end

            itemView.DecorationViews[self] = decorationView

            if decorationView then
                decorationView:SetParent(itemView)
                decorationView:SetAllPoints(itemView)
                self:Draw(recyclerView, decorationView, itemView.ViewHolder)
                decorationView:Show()
            end
        end

        __Arguments__{ RecyclerView }
        function RecycleOverlayView(self, recyclerView)
            local overlayView = recyclerView.OverlayViews[self]
            if overlayView then
                overlayView:Hide()
                overlayView:ClearAllPoints()
                overlayView:SetParent(nil)
            end
            tinsert(self.__OverlayViewCache, overlayView)

            recyclerView.OverlayViews[self] = nil
        end

        __Arguments__{ RecyclerView }:Throwable()
        function ShowOverlayView(self, recyclerView)
            local overlayView = recyclerView.OverlayViews[self]
            if not overlayView then
                overlayView = tremove(self.__OverlayViewCache)

                if not overlayView then
                    overlayView = self:OnCreateOverlayView()
                    if not overlayView or not Class.ValidateValue(Frame, overlayView, true) then
                        throw("OverlayView必须是Frame或其子类型")
                    end
                end

                recyclerView.OverlayViews[self] = overlayView
            end

            if overlayView then
                overlayView:SetParent(recyclerView)
                overlayView:SetFrameStrata(recyclerView:GetFrameStrata())
                overlayView:SetToplevel(true)
                self:DrawOver(recyclerView, overlayView)
                overlayView:Show()
            end
        end

        function Destroy(self, recyclerView)
            self:RecycleOverlayView(recyclerView)

            for _, itemView in recyclerView:GetItemViews() do
                self:RecycleDecorationView(itemView)
            end
        end

        function __ctor(self)
            self.__DecorationViewCache = {}
            self.__OverlayViewCache = {}
        end

    end)

    -----------------------------------------------------------
    --                      Adapter                          --
    -----------------------------------------------------------

    __Sealed__()
    class "Adapter"(function()

        enum "SelectMode" {
            "NONE",
            "SINGLE",
            "MULTIPLE"
        }

        local HEADER_VIEW = 0x10000111
        local FOOTER_VIEW = 0x10000222
        local EMPTY_VIEW  = 0x10000333

        __Static__()
        property "HEADER_VIEW"          {
            type                        = Integer,
            set                         = false,
            default                     = HEADER_VIEW
        }

        __Static__()
        property "FOOTER_VIEW"          {
            type                        = Integer,
            set                         = false,
            default                     = FOOTER_VIEW
        }

        __Static__()
        property "EMPTY_VIEW"           {
            type                        = Integer,
            set                         = false,
            default                     = EMPTY_VIEW
        }

        property "Data"                 {
            type                        = List,
            handler                     = function(self)
                self:NotifyDataSetChanged(false)
            end
        }

        property "RecyclerView"         {
            type                        = RecyclerView
        }

        -- 空布局
        -- 设置了空布局，则默认数据为0时不显示Header和Footer，除非设置了HeaderWithEmptyEnable及FooterWithEmptyEnable属性
        property "EmptyView"            {
            type                        = LayoutFrame,
            handler                     = function(self)
                self:NotifyDataSetChanged()
            end
        }

        property "HeaderView"           {
            type                        = LayoutFrame,
            handler                     = function(self)
                self:NotifyDataSetChanged()
            end
        }

        property "FooterView"           {
            type                        = LayoutFrame,
            handler                     = function(self)
                self:NotifyDataSetChanged()
            end
        }

        -- 显示Header的时候是否显示空布局
        property "HeaderWithEmptyEnable"{
            type                        = Boolean,
            default                     = false,
            handler                     = function(self)
                self:NotifyDataSetChanged()
            end
        }

        -- 显示Footer的时候是否显示空布局
        property "FooterWithEmptyEnable"{
            type                        = Boolean,
            default                     = false,
            handler                     = function(self)
                self:NotifyDataSetChanged()
            end
        }

        -- Item监听，需要定义同名Script方法
        -- 例如 function listener.OnClick
        -- Script handler返回参数表为(adapter, itemView, ...)
        property "ItemListener"         {
            type                        = RawTable
        }

        -- Item child监听，需要定义同名Script方法
        -- 例如 function ChildListener.OnClick
        -- Script handler返回参数表为(adapter, itemView, childView, ...)
        property "ItemChildListener"    {
            type                        = RawTable
        }

        -- ItemView:RegisterForClicks
        property "RegisterForClicks"    {
            type                        = struct { String },
            default                     = { "LeftButtonUp" }
        }

        -- 单选/多选
        property "SelectMode"           {
            type                        = SelectMode,
            default                     = SelectMode.NONE
        }

        -- 刷新
        __Final__()
        __Arguments__{ Boolean/true }
        function NotifyDataSetChanged(self, keepPosition)
            if self.RecyclerView then
                self.RecyclerView:Refresh(keepPosition)
            end
        end

        -- 数据源为空
        function IsDataEmpty(self)
            return not self.Data or self.Data.Count == 0
        end
        
        local function HasEmptyView(self)
            if not self.EmptyView then
                return false
            end
            return self:IsDataEmpty()
        end

        __Final__()
        __Arguments__{ NaturalNumber }:Throwable()
        function GetItemViewTypeInternal(self, position)
            if HasEmptyView(self) then
                local hasHeader = (self.HeaderWithEmptyEnable and self.HeaderView)
                if position == 1 then
                    return hasHeader and HEADER_VIEW or EMPTY_VIEW
                end
                if position == 2 then
                    return hasHeader and EMPTY_VIEW or FOOTER_VIEW
                end
                if position == 3 then
                    return FOOTER_VIEW
                end
            else
                if self.HeaderView and position == 1 then
                    return HEADER_VIEW
                end
                position = self.HeaderView and (position - 1) or position
                local dataSize = self.Data and self.Data.Count or 0
                if position <= dataSize then
                    -- 子类重写这个方法，返回自己的ViewType
                    local viewType = self:GetItemViewType(position)
                    if IsInternalViewType(viewType) then
                        throw(string.format("GetItemViewType can not return view type which is same as %d, %d and %d", HEADER_VIEW, EMPTY_VIEW, FOOTER_VIEW))
                    end
                    if not Struct.ValidateValue(Integer, viewType, true) then
                        throw("GetItemViewType must return integer value")
                    end
                    return viewType
                else
                    return FOOTER_VIEW
                end
                
            end
            return 0
        end
        
        -- 如果需要实现多布局，重写这个方法，需返回整数
        __Abstract__()
        __Arguments__{ NaturalNumber }
        function GetItemViewType(self, position)
            return 0
        end

        -- 获取item数量，必须是自然数
        -- 设置了空布局，则默认数据为0时不显示Header和Footer，除非设置了HeaderWithEmptyEnable及FooterWithEmptyEnable属性
        __Final__()
        function GetItemCount(self)
            if HasEmptyView(self) then
                local count = 1
                if self.HeaderWithEmptyEnable and self.HeaderView then
                    count = count + 1
                end
                if self.FooterWithEmptyEnable and self.FooterView then
                    count = count + 1
                end
                return count
            else
                local count = self.Data and self.Data.Count or 0
                if self.HeaderView then
                    count = count + 1
                end
                if self.FooterView then
                    count = count + 1
                end
                return count
            end
        end

        -- 是否为内部使用的ViewType，即Header、Footer和Empty
        __Static__()
        function IsInternalViewType(viewType)
            return viewType == HEADER_VIEW or viewType == FOOTER_VIEW or viewType == EMPTY_VIEW
        end

        -- 将Data position转换成Adapter position
        __Arguments__{ NaturalNumber }
        function ConvertDataPositionToAdapterPosition(self, position)
            return position + (self.HeaderView and 1 or 0)
        end

        -- 创建ViewHolder
        __Final__()
        __Arguments__{ Integer }:Throwable()
        function CreateViewHolder(self, viewType)
            -- Header、Footer、Empty不创建ContentView
            if IsInternalViewType(viewType) then
                return ViewHolder(viewType)
            else
                local viewHolder = ViewHolder(viewType)
                local contentView = self:OnCreateContentView(viewType)
                if not contentView or not Class.ValidateValue(LayoutFrame, contentView, true) then
                    throw("ContentView 必须是LayoutFrame或其子类型")
                end
                viewHolder.ContentView = contentView
                return viewHolder
            end
            
        end

        -- 重写该方法返回ContentView
        -- @param viewType: 由GetItemViewType获取
        __Abstract__()
        __Arguments__{ Integer }
        function OnCreateContentView(self, viewType)
        end

        -- 绑定ViewHolder
        -- @param holder: ViewHolder
        -- @param position: 数据源位置
        __Final__()
        __Arguments__{ ViewHolder, NaturalNumber }
        function BindViewHolder(self, holder, position)
            holder.Position = position
            local viewType = holder.ItemViewType
            if IsInternalViewType(viewType) then
                -- 空布局大小要和RecyclerView一样大
                if viewType == EMPTY_VIEW then
                    holder.ContentView:SetSize(self.RecyclerView:GetSize())
                end
            else
                -- 去掉头布局才是真正的Data position
                -- 走到这个分支时，说明Data一定有数据，所以无需判断HeaderWithEmptyEnable
                position = self.HeaderView and (position - 1) or position
                holder.DataPosition = position
                self:OnBindViewHolder(holder, self.Data[position])
            end
        end

        -- 重写该方法实现数据绑定
        __Arguments__{ ViewHolder, Any }
        __Abstract__()
        function OnBindViewHolder(self, holder, data)
        end

        -- 判断是否需要刷新
        -- @param itemView: ItemView
        -- @param position: 数据源位置
        __Arguments__{ ItemView, NaturalNumber }
        function NeedRefresh(self, itemView, position)
            local itemViewType = self:GetItemViewTypeInternal(position)
            return not itemView.ViewHolder or itemView.ViewHolder.Position ~= position
                    or itemView.ViewHolder.ItemViewType ~= itemViewType
        end

        -- 获取回收池内ViewHolder数量
        function GetViewHolderCacheCount(self)
            local count = 0
            for _, cache in pairs(self.__ViewHolderCache) do
                count = count + #cache
            end

            return count
        end

        -- 回收ItemView的ViewHolder
        __Arguments__{ ItemView }
        function RecycleViewHolder(self, itemView)
            local viewHolder = itemView.ViewHolder
            if not viewHolder then return end

            viewHolder:Destroy()
            -- Header、Footer、Empty等在回收时要取消对ContentView的索引
            -- 因为HeaderView、FooterView、EmptyView可能会被更改
            if IsInternalViewType(viewHolder.ItemViewType) then
                viewHolder.ContentView = nil
            end
            
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

        local function GetContentViewByInternalViewType(self, viewType)
            if viewType == HEADER_VIEW then
                return self.HeaderView
            elseif viewType == EMPTY_VIEW then
                return self.EmptyView
            elseif viewType == FOOTER_VIEW then
                return self.FooterView
            end
        end

        local function InstallEvents(self, itemView)
            if IsInternalViewType(itemView.ViewHolder.ItemViewType) then
                return
            end

            if self.ItemListener then
                if self.RegisterForClicks then
                    itemView:RegisterForClicks(unpack(self.RegisterForClicks))
                else
                    itemView:RegisterForClicks(nil)
                end

                for script, handler in pairs(self.ItemListener) do
                    if itemView:HasScript(script) and type(handler) == "function" then
                        itemView[script] = function(...)
                            handler(self, ...)
                        end
                    end
                end
            end

            if self.ItemChildListener then
                local childScripts = itemView.ViewHolder:GetChildScripts()
                if not childScripts then return end

                for child, scripts in pairs(childScripts) do
                    for _, script in ipairs(scripts) do
                        local handler = self.ItemChildListener[script]
                        if handler and type(handler) == "function" then
                            child[script] = function(...)
                                handler(self, itemView, ...)
                            end
                        end
                    end
                end
            end
        end

        -- Adapter附着到ItemView，这个方法实现数据绑定
        -- @param itemView: ItemView
        -- @param position: 数据源位置
        __Arguments__{ ItemView, NaturalNumber }
        function AttachItemView(self, itemView, position)
            local itemViewType = self:GetItemViewTypeInternal(position)

            if itemView.ViewHolder and itemView.ViewHolder.ItemViewType ~= itemViewType then
                self:RecycleViewHolder(itemView)
            end

            local viewHolder = itemView.ViewHolder

            if not viewHolder then
                viewHolder = GetViewHolderFromCache(self, itemViewType)
                if not viewHolder then
                    viewHolder = self:CreateViewHolder(itemViewType)
                end
                -- Header、Footer、Empty等在取出时要重新变更ContentView
                -- 因为HeaderView、FooterView、EmptyView可能会被更改
                if IsInternalViewType(itemViewType) then
                    viewHolder.ContentView = GetContentViewByInternalViewType(self, itemViewType)
                end
                itemView.ViewHolder = viewHolder
            end

            viewHolder.ContentView:SetParent(itemView)
            self:BindViewHolder(viewHolder, position)
            InstallEvents(self, itemView)
            viewHolder.ContentView:Show()
        end

        function __ctor(self)
            self.__ViewHolderCache = {}
        end
        
    end)

    -----------------------------------------------------------
    --                  LayoutManager                        --
    -----------------------------------------------------------

    -- LayoutManager是RecyclerView运作的核心实现类
    -- 它没有那么抽象，可供实现的方法也不多。
    -- 一般来说，使用RecyclerView不推荐自定义LayoutManager

    -- 自定义LayoutManager需要主要需要实现OnLayout方法，在该方法内进行
    -- ItemView的绘制、计算大小、绘制ItemDecoration及布局操作
    -- 值得注意的是，构造方法中初始化生成的__RowCount,__MinRowLength,__RowLength
    -- 这三个变量决定了列表中显示的行数、每行对应长度及行最小长度，
    -- 子类应当使用这三个变量来实现逻辑

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
            type                        = NaturalNumber,
            default                     = 1
        }

        property "LayoutOffset"         {
            type                        = Number,
            default                     = 0
        }

        -- 从指定位置和偏移量开始布局，是布局的入口
        -- @param: position: item位置,第一个完整显示在RecyclerView可视范围内的item位置
        -- @param: offset: 该position对应的itemView距离RecycleView顶部的距离，负数说明该ItemView的顶部在recyclerView内，正数说明该ItemView的顶部在recyclerView外部
        __Final__()
        __Arguments__{ NaturalNumber, Number}
        function Layout(self, position, offset)
            if self.RecyclerView then
                local contentLength = 0

                if self.RecyclerView.Adapter then
                    local itemCount = self.RecyclerView.Adapter:GetItemCount()
                    position = math.min(position, itemCount)

                    if position <= 0 then return end
                    
                    self.LayoutPosition = position
                    -- position大于item数量，则跳转到最后一项，offset设为0
                    self.LayoutOffset = position > itemCount and 0 or offset
                    contentLength = self:OnLayout(position, self.LayoutOffset)
                end

                self.RecyclerView:OnLayoutChanged(contentLength)
            end
        end

        -- @see Layout
        -- LayoutManager的子类应当重写这个方法来实现自己的布局
        -- 需要返回布局完成后所在方向的长度
        __Abstract__()
        __Arguments__{ NaturalNumber, Number }
        function OnLayout(self, position, offset)
        end

        -- 获取可见的ItemView数量
        __Abstract__()
        function GetVisibleItemViewCount(self)
        end

        -- 获取第一个完整可见的item
        -- @return
        -- @param itemView 返回第一个完整可见的item
        -- @param index itemView index
        -- @param offset 该item位置
        __Abstract__()
        function GetFirstCompletelyVisibleItemView(self)
        end

        -- 获取第一个可见的item
        -- @return
        -- @param itemView 返回第一个可见的item
        -- @param index itemView index
        -- @param offset 该item在屏幕外的长度
        __Abstract__()
        function GetFirstVisibleItemView(self)
        end

        -- 请求重新布局
        -- @param keepPosition: 保留当前位置，即刷新后仍停留在当前item
        __Final__()
        __Arguments__{ Boolean/false }
        function RequestLayoutInternal(self, keepPosition)
            wipe(self.__RowLength)
            self.__RowCount = 0
            self.__MinRowLength = 2147483648

            local position = 1
            if keepPosition then
                local itemView = self:GetFirstVisibleItemView()
                if itemView then 
                    position = itemView.ViewHolder.Position
                end
            end
            self:Layout(position, 0)
        end

        -- 滚动到指定位置
        -- @param position:数据源位置
        __Abstract__()
        function ScrollToPosition(self, position)
        end

        -- 滚动到指定位置
        -- @param length:长度
        __Abstract__()
        function ScrollToLength(self, length)
        end

        -- 获取总长度
        -- 没有加载的项，可以使用最小值预估
        -- @return
        -- @param totalLength: 总长度
        -- @param beforeDisplayLength:展示的内容区域之前的长度
        -- @param afterDisplayLength: 展示的内容区域之后的长度
        __Abstract__()
        function GetTotalLength(self)
        end

        -- __RowLength:每行对应长度
        -- __MinRowLength:行最小长度
        -- __RowCount:行数量
        function __ctor(self)
            self.__RowLength = {}
            self.__MinRowLength = 2147483648
            self.__RowCount = 0
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
        --                      Pool                         --
        -------------------------------------------------------

        local itemViewPool              = Recycle(ItemView, "RecyclerView.ItemView%d")

        function itemViewPool:OnPush(itemView)
            itemView:Destroy()
        end

        local function AcquireItemView(self)
            local itemView = itemViewPool()
            local scrollChild = self:GetChild("ScrollChild")
            itemView:SetParent(scrollChild)
            itemView:SetFrameStrata(scrollChild:GetFrameStrata())
            itemView:SetFrameLevel(scrollChild:GetFrameLevel())
            itemView.Orientation = self.Orientation
            return itemView
        end

        local function ReleaseItemView(self, itemView)
            itemViewPool(itemView)
        end

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

        __Indexer__(Any)
        property "OverlayViews"         {
            type                        = LayoutFrame,
            set                         = function(self, key, value)
                self.__OverlayViews = self.__OverlayViews or {}
                self.__OverlayViews[key] = value
            end,
            get                         = function(self, key)
                return self.__OverlayViews and self.__OverlayViews[key]
            end
        }

        -------------------------------------------------------
        --                    Functions                      --
        -------------------------------------------------------

        -- 绘制ItemDecorations
        __Arguments__{ ItemView }
        function DrawItemDecorations(self, itemView)
            for _, itemDecoration in ipairs(self.__ItemDecorations) do
                itemDecoration:AttachItemView(self, itemView)
            end
        end

        -- 绘制ItemDecorations的Overlay
        function DrawItemDecorationsOverlay(self)
            for _, itemDecoration in ipairs(self.__ItemDecorations) do
                itemDecoration:ShowOverlayView(self)
            end
        end

        -- 返回ItemDecorations的迭代器
        function GetItemDecorations(self)
            return ipairs(self.__ItemDecorations)
        end

        -- 添加ItemDecoration
        __Arguments__{ ItemDecoration }
        function AddItemDecoration(self, itemDecoration)
            if not tContains(self.__ItemDecorations, itemDecoration) then
                tinsert(self.__ItemDecorations, itemDecoration)
            end
        end

        -- 删除ItemDecoration
        __Arguments__{ ItemDecoration }
        function RemoveItemDecoration(self, itemDecoration)
            itemDecoration:Destroy(self)
            tDeleteItem(self.__ItemDecorations, itemDecoration)
            self:Refresh(true)
        end

        -- LayoutManager变更
        function OnLayoutManagerChanged(self, layoutManager, oldLayoutManager)
            if oldLayoutManager then
                oldLayoutManager.RecyclerView = nil
            end

            if layoutManager then
                layoutManager.RecyclerView = self
            end

            self:Refresh()
        end

        -- 方向变更
        function OnOrientationChanged(self)
            for _, itemView in ipairs(self.__ItemViews) do
                itemView.Orientation = self.Orientation
            end
            self:ResetScroll()
            self:Refresh(true)
        end

        -- 适配器变更
        function OnAdapterChanged(self, newAdapter, oldAdapter)
            if oldAdapter then
                oldAdapter.RecyclerView = nil
            end

            if newAdapter then
                newAdapter.RecyclerView = self
            end

            self:Refresh(oldAdapter)
        end

        -- 刷新
        __Arguments__{ Adapter/nil }
        function RequestLayoutInternal(self, adapter)
            self:Refresh(false, adapter)
        end


        -- 刷新
        -- @param keepPosition: 保留当前位置，即刷新后仍停留在当前item
        -- @param adapter 指定ViewHolder回收到哪个adapter，默认为nil，即当前adapter
        __Arguments__{ Boolean/false, Adapter/nil }
        function RequestLayoutInternal(self, keepPosition, adapter)
            self:Reset(adapter)
            if self.LayoutManager then
                self.LayoutManager:RequestLayoutInternal(keepPosition)
            else
                self:OnLayoutChanged()
            end
        end

        -- 跳转到指定item
        -- @param position: item位置
        __Arguments__{ NaturalNumber }
        function ScrollToPosition(self, position)
            if self.LayoutManager then
                self.LayoutManager:ScrollToPosition(position)
            end
        end

        -- 跳转到指定位置
        -- @param length: 长度
        __Arguments__{Number }
        function ScrollToLength(self, length)
            if self.LayoutManager then
                self.LayoutManager:ScrollToLength(length)
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

        -- 隐藏所有ScrollBar
        function HideScrollBars(self)
            self:GetChild("VerticalScrollBar"):Hide()
            self:GetChild("HorizontalScrollBar"):Hide()
        end

        -- 重置
        __Arguments__{ Adapter/nil }
        function Reset(self, adapter)
            self:HideScrollBars()
            self:RecycleItemViews(adapter)
            for _, itemDecoration in ipairs(self.__ItemDecorations) do
                itemDecoration:RecycleOverlayView(self)
            end
        end

        -- 获取RecyclerView长度，根据其方向会返回长度或宽度
        function GetLength(self)
            if self.Orientation == Orientation.HORIZONTAL then
                return self:GetWidth()
            elseif self.Orientation == Orientation.VERTICAL then
                return self:GetHeight()
            end
        end

        -- 从指定index开始回收ItemViews
        -- @param index: 从指定位置的ItemView往后开始回收
        -- @param adapter: 指定ViewHolder回收到哪个adapter，默认为nil，即当前adapter
        __Arguments__{ Adapter/nil, NaturalNumber/1 }
        function RecycleItemViews(self, adapter, index)
            for i = #self.__ItemViews, index, -1 do
                self:RecycleItemView(i, adapter)
            end
        end
        
        -- 回收指定位置的ItemView
        -- @param index: 指定位置的ItemView
        -- @param adapter: 指定ViewHolder回收到哪个adapter，默认为nil，即当前adapter
        __Arguments__{ NaturalNumber, Adapter/nil }
        function RecycleItemView(self, index, adapter)
            local itemView = tremove(self.__ItemViews, index)
            self:RecycleItemView(itemView, adapter)
        end

        -- 回收ItemView
        -- @param itemView: 需要被回收的itemView
        __Arguments__{ ItemView, Adapter/nil }
        function RecycleItemView(self, itemView, adapter)
            adapter = adapter or self.Adapter
            if adapter then
                adapter:RecycleViewHolder(itemView)
            end

            -- 回收ItemDecoration
            for _, itemDecoration in ipairs(self.__ItemDecorations) do
                itemDecoration:RecycleDecorationView(itemView)
            end

            ReleaseItemView(self, itemView)
        end

        -- 设置ItemViews，由LayoutManager调用
        __Arguments__{ struct {ItemViewInfos} / nil }
        function SetItemViews(self, itemViewInfos)
            if not itemViewInfos then
                self:RecycleItemViews()
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

        -- 返回ItemViews的迭代器
        function GetItemViews(self)
            return ipairs(self.__ItemViews)
        end

        -- 获取一个新的ItemView，由LayoutManager调用
        -- 由回收池获取或新建返回
        function ObtainItemView(self)
            return AcquireItemView(self)
        end

        -- 获取指定位置的ItemView
        -- @param index:ItemView位置
        __Arguments__{ NaturalNumber }
        function GetItemView(self, index)
            return self.__ItemViews[index]
        end

        -- 获取布局中的ItemView个数
        function GetItemViewCount(self)
            return #self.__ItemViews
        end

        -- 通过adapter position获取ItemView，可能为nil
        -- @param position:数据源内的位置
        function GetItemViewByAdapterPosition(self, position)
            for index, itemView in ipairs(self.__ItemViews) do
                local viewHolder = itemView.ViewHolder
                if viewHolder and viewHolder.Position == position then
                    return itemView, index
                end
            end
        end

        -- 通过DataPosition获取ItemView，可能为nil
        function GetItemViewByDataPosition(self, position)
            if self.Adapter then
                position = self.Adapter:ConvertDataPositionToAdapterPosition(position)
                return self:GetItemViewByAdapterPosition(position)
            end
        end

        -- @itemView 返回第一个完整可见的item
        -- @return
        -- @param itemView: ItemView
        -- @param index:ItemView index
        -- @param offset:ItemView offset
        function GetFirstCompletelyVisibleItemView(self)
            if not self.LayoutManager then return end
        
            return self.LayoutManager:GetFirstCompletelyVisibleItemView()
        end

        -- 获取可见的ItemView数量
        function GetVisibleItemViewCount(self)
            if not self.LayoutManager then
                return 0
            end

            return self.LayoutManager:GetVisibleItemViewCount()
        end

        function GetFirstVisibleItemView(self)
            if not self.LayoutManager then return end

            return self.LayoutManager:GetFirstVisibleItemView()
        end

        -- 是否滚动到底部
        function IsScrollToBottom(self)
            local adapter = self.Adapter
            local layoutManager = self.LayoutManager
            local itemViewCount = #self.__ItemViews
            if not adapter or not layoutManager or itemViewCount < 1 then
                return true
            end

            local scrollOffset = math.floor(self:GetScrollOffset())
            local scrollRange = math.floor(self:GetScrollRange())
            local itemCount = adapter:GetItemCount()

            local itemView = self.__ItemViews[#self.__ItemViews]
            if itemView.ViewHolder.Position == itemCount and math.abs(scrollOffset - scrollRange) < 5 then
                return true
            end

            return false
        end

        -- 是否滚动到顶部
        function IsScrollToTop(self)
            local adapter = self.Adapter
            local layoutManager = self.LayoutManager
            local itemViewCount = #self.__ItemViews
            if not adapter or not layoutManager or itemViewCount < 1 then
                return true
            end

            local scrollOffset = math.floor(self:GetScrollOffset())

            local itemView = self.__ItemViews[1]
            if itemView.ViewHolder.Position == 1 and math.abs(scrollOffset) < 5 then
                return true
            end

            return false
        end

        -- 获取滚动范围，根据不同方向返回不同的滚动范围
        function GetScrollRange(self)
            local orientation = self.Orientation
            if orientation == Orientation.VERTICAL then
                return self:GetVerticalScrollRange()
            elseif orientation == Orientation.HORIZONTAL then
                return self:GetHorizontalScrollRange()
            end
        end

        -- 获取滚动值，根据不同方向返回不同的滚动值
        function GetScrollOffset(self)
            local orientation = self.Orientation
            if orientation == Orientation.VERTICAL then
                return self:GetVerticalScroll()
            elseif orientation == Orientation.HORIZONTAL then
                return self:GetHorizontalScroll()
            end
        end

        -- 在当前方向上滚动
        -- @param offset:滚动值
        function Scroll(self, offset)
            local orientation = self.Orientation
            if orientation == Orientation.VERTICAL then
                self:SetVerticalScroll(offset)
            elseif orientation == Orientation.HORIZONTAL then
                self:SetHorizontalScroll(offset)
            end
            -- 刷新ItemDecoration的OverlayView
            self:DrawItemDecorationsOverlay()
        end

        -- 重置滚动值
        function ResetScroll(self)
            self:SetHorizontalScroll(0)
            self:SetVerticalScroll(0)
        end 

        -- 显示/隐藏ScrollBar
        __Arguments__{ Boolean}
        function SetScrollBarShown(self, shown)
            local scrollBar = self:GetScrollBar()
            scrollBar:SetShown(shown)
            if shown then
                local totalLength, beforeDisplayLength = self.LayoutManager:GetTotalLength()
                scrollBar:Refresh(beforeDisplayLength, beforeDisplayLength + self:GetLength(), totalLength)
            end
        end

        -- 布局完成
        __Arguments__{ Number/0 }
        function OnLayoutChanged(self, contentLength)
            if contentLength > self:GetLength() then
                self:SetScrollBarShown(true)
            else
                self:SetScrollBarShown(false)
            end
        end

        -- 鼠标滚轮事件
        -- 这里是滚动驱动入口
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
            if not itemView then return end

            local position = itemView.ViewHolder.Position
            if offset > scrollRange or offset < 0 then
                offset = -(curOffset - offset)
                
                if position == 1 then
                    offset = 0
                end

                self.LayoutManager:Layout(position, offset)
            end

            -- 改变ScrollBar的值
            self:SetScrollBarShown(true, position)
        end

        -- 大小变化时刷新以触发重绘
        local function OnSizeChanged(self)
            -- 延迟一点时间，以使Scorllbar重新布局，否则Scrollbar.Thumb位置会不正确，因为在重新布局期间调用thumb:SetPoint会使其定位错误
            Delay(0.1, self.Refresh, self, true)
        end

        __Template__{
            VerticalScrollBar           = VerticalScrollBar,
            HorizontalScrollBar         = HorizontalScrollBar,
            ScrollChild                 = Frame
        }
        function __ctor(self)
            self.__ItemViews = {}
            self.__ItemDecorations = {}

            self.OnMouseWheel   = self.OnMouseWheel + OnMouseWheel
            self.OnSizeChanged  = self.OnSizeChanged + OnSizeChanged

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
    
            Thumb                                   = {
                NormalTexture                       = {
                    color                           = ColorType(1, 0, 0)
                }
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
    
            Thumb                                   = {
                NormalTexture                       = {
                    file                            = [[Interface\Buttons\UI-ScrollBar-Knob]],
                    texCoords                       = {
                        ULx                         = 0.8,
                        ULy                         = 0.125,
                        LLx                         = 0.2,
                        LLy                         = 0.125,
                        URx                         = 0.8,
                        URy                         = 0.875,
                        LRx                         = 0.2,
                        LRy                         = 0.875
                    }
                }
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
end)