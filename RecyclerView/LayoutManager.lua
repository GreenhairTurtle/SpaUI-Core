Scorpio "SpaUI.Widget.RecyclerView.LayoutManager" ""

-----------------------------------------------------------
--               LinearLayoutManager                     --
-----------------------------------------------------------

__Sealed__()
class "LinearLayoutManager"(function()
    inherit "LayoutManager"

    function LayoutItemViews(self)
        local recyclerView = self.RecyclerView
        local relativePoint = recyclerView.Orientation == Orientation.VERTICAL and "BOTTOMLEFT" or "TOPRIGHT"

        local lastItemView
        for _, itemView in recyclerView:GetItemViews() do
            itemView:ClearAllPoints()
            itemView:SetPoint("TOPLEFT", lastItemView or itemView:GetParent(), lastItemView and relativePoint or "TOPLEFT", 0, 0)
            lastItemView = itemView
        end
    end

    local function UpdateItemViewSize(self, itemView)
        local recyclerView = self.RecyclerView
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

    local function GetItemViewByPosition(self, position)
        local recyclerView = self.RecyclerView
        local adapter = recyclerView.Adapter
        local itemView = recyclerView:GetItemViewByAdapterPosition(position)

        if not itemView then
            itemView = recyclerView:ObtainItemView()
        end

        if adapter:NeedRefresh(itemView, position) then
            adapter:AttachItemView(itemView, position)
            UpdateItemViewSize(self, itemView)
            recyclerView:DrawItemDecorations(itemView)
        end

        itemView:Show()

        return itemView
    end

    function OnLayout(self, position, offset)
        local recyclerView = self.RecyclerView
        local adapter = recyclerView.Adapter

        local startPosition = math.max(position - 1, 1)
        local itemCount = adapter:GetItemCount()
        
        local contentLength = 0
        local adapterPosition = startPosition
        local itemViewMap = {}

        while contentLength <= recyclerView:GetLength() and adapterPosition <= itemCount do
            local itemView = GetItemViewByPosition(self, adapterPosition)
            tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            adapterPosition = adapterPosition + 1
            contentLength = contentLength + itemView:GetLength()
        end

        -- 额外添加一项
        -- 因为可能startPosition那一项长度直接超过contentLength导致position反而没添加
        if adapterPosition <= itemCount then
            local itemView = GetItemViewByPosition(self, adapterPosition)
            tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            contentLength = contentLength + itemView:GetLength()
        end
        

        adapterPosition = startPosition - 1

        -- 如果顺序长度不够，则逆序添加足够的项使长度足够
        while contentLength <= recyclerView:GetLength() and adapterPosition > 0 do
            local itemView = GetItemViewByPosition(self, adapterPosition)
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

    function GetVisibleItemViewCount(self)
        local recyclerView = self.RecyclerView

        local scrollOffset = recyclerView:GetScrollOffset()
        local offset = 0
        local length = recyclerView:GetLength()
        local itemViewCount = recyclerView:GetItemViewCount()
        local visibleCount = 0
        
        for i = 1, itemViewCount do
            local itemView = recyclerView:GetItemView(i)
            offset = offset + itemView:GetLength()

            if offset > scrollOffset then
                visibleCount = visibleCount + 1
            end

            if offset >= scrollOffset + length then
                break
            end
        end

        return visibleCount
    end

    function GetFirstCompletelyVisibleItemView(self)
        local recyclerView = self.RecyclerView
        
        local itemViewCount = recyclerView:GetItemViewCount()
        if itemViewCount <= 0 then return end

        local scrollOffset = recyclerView:GetScrollOffset()
        local offset = 0

        for index = 1, itemViewCount do
            local itemView = recyclerView:GetItemView(index)

            if offset > scrollOffset then
                return itemView, index, offset
            end
           
            if index ~= itemViewCount then
                offset = offset + itemView:GetLength()
            end
        end
    
        return recyclerView:GetItemView(itemViewCount), itemViewCount, offset
    end

end)

-----------------------------------------------------------
--                 GridLayoutManager                     --
-----------------------------------------------------------

__Sealed__()
class "GridLayoutManager"(function()
    inherit "LayoutManager"

    property "SpanCount"{
        type            = NaturalNumber,
        default         = 1,
        handler         = function(self, spanCount)
            self:RequestLayout(true)
        end
    }

    -- 获取item对应的跨度大小
    __Arguments__{ NaturalNumber }
    function GetSpanSizeLookUp(self, position)
        return 1
    end

    local function GetRowOrColumn(self, position)
        local info = self.__ItemViewInfos[position]
        return info.RowOrColumn, info.RowOrColumnIndex, info.SpanSize
    end

    local function UpdateItemViewSize(self, itemView, position)
        local recyclerView = self.RecyclerView
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

        local _, _, spanSize = GetRowOrColumn(self, position)

        if orientation == Orientation.VERTICAL then
            length = maxTop + maxBottom + contentView:GetHeight()
            local width = recyclerView:GetWidth() / self.SpanCount * spanSize
            contentView:SetWidth(width - maxLeft - maxRight)
            itemView:SetWidth(width)
            itemView:SetHeight(length)
        elseif orientation == Orientation.HORIZONTAL then
            length = maxLeft + maxRight + contentView:GetWidth()
            local height = recyclerView:GetHeight() / self.SpanCount * spanSize
            contentView:SetHeight(height - maxTop - maxBottom)
            itemView:SetHeight(height)
            itemView:SetWidth(length)
        end
    end

    local function GetItemViewByPosition(self, position)
        local recyclerView = self.RecyclerView
        local adapter = recyclerView.Adapter
        local itemView = recyclerView:GetItemViewByAdapterPosition(position)

        if not itemView then
            itemView = recyclerView:ObtainItemView()
        end

        if adapter:NeedRefresh(itemView, position) then
            adapter:AttachItemView(itemView, position)
            UpdateItemViewSize(self, itemView, position)
            recyclerView:DrawItemDecorations(itemView)
        end

        itemView:Show()

        return itemView
    end

    local function UpdateItemViewPositions(self)
        wipe(self.__ItemViewInfos)
        wipe(self.__RowOrColumnInfos)

        local itemCount = self.RecyclerView.Adapter:GetItemCount()

        local rowOrColumn = 1
        local index = 1
        local rowOrColumnTotalSpanSize = 0

        for position = 1, itemCount do
            local itemViewInfo = {}
            local spanSize = self:GetSpanSizeLookUp(position)

            if spanSize > self.SpanCount then
                error("Span size must be lower than span count")
            end

            rowOrColumnTotalSpanSize = rowOrColumnTotalSpanSize + spanSize
            if rowOrColumnTotalSpanSize > self.SpanCount then
                rowOrColumn = rowOrColumn + 1
                rowOrColumnTotalSpanSize = 0
                index = 1
            end

            itemViewInfo.SpanSize = spanSize
            itemViewInfo.RowOrColumn = rowOrColumn
            itemViewInfo.RowOrColumnIndex = index

            self.__ItemViewInfos[position] = itemViewInfo
            self.__RowOrColumnInfos[rowOrColumn] = self.__RowOrColumnInfos[rowOrColumn] or {}
            tinsert(self.__RowOrColumnInfos[rowOrColumn], position)

            index = index + spanSize
        end
    end

    local function GetContentLengthBetweenRowOrColumn(self, from, to)
        local length = 0
        for i = from, to do
            length = length + self.__RowOrColumnInfos[i].Length
        end
        return length
    end

    function OnLayout(self, position, offset)
        local recyclerView = self.RecyclerView
        local adapter = recyclerView.Adapter

        UpdateItemViewPositions(self)

        local startRowOrColumn = math.max(GetRowOrColumn(self, position) - 1, 1)
        local itemCount = adapter:GetItemCount()
        local maxRowOrColumn = GetRowOrColumn(self, itemCount)
        
        local rowOrColumn = startRowOrColumn
        local itemViewMap = {}
        local contentLength = 0

        while contentLength <= recyclerView:GetLength() and rowOrColumn <= maxRowOrColumn do
            local length = 0
            for _, adapterPosition in ipairs(self.__RowOrColumnInfos[rowOrColumn]) do
                local itemView = GetItemViewByPosition(self, adapterPosition)
                length = math.max(itemView:GetLength(), length)
                self.__RowOrColumnInfos[rowOrColumn].Length = length
                tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            end

            contentLength = contentLength + length
            rowOrColumn = rowOrColumn + 1
        end

        -- 额外添加一行/列
        -- 因为可能startRowOrColumn那一行/列长度直接超过contentLength导致需要显示的那一行/列反而不显示
        if rowOrColumn <= maxRowOrColumn then
            local length = 0
            for _, adapterPosition in ipairs(self.__RowOrColumnInfos[rowOrColumn]) do
                local itemView = GetItemViewByPosition(self, adapterPosition)
                length = math.max(itemView:GetLength(), length)
                self.__RowOrColumnInfos[rowOrColumn].Length = length
                tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            end
            contentLength = contentLength + length
        end

        -- 如果顺序长度不够，则逆序添加足够的项使长度足够
        rowOrColumn = startRowOrColumn - 1
        while contentLength <= recyclerView:GetLength() and rowOrColumn > 0 do
            local length = 0
            for _, adapterPosition in ipairs(self.__RowOrColumnInfos[rowOrColumn]) do
                local itemView = GetItemViewByPosition(self, adapterPosition)
                length = math.max(itemView:GetLength(), length)
                self.__RowOrColumnInfos[rowOrColumn].Length = length
                tinsert(itemViewMap, RecyclerView.ItemViewInfo(adapterPosition, itemView))
            end

            contentLength = contentLength + length
            rowOrColumn = rowOrColumn - 1
        end

        -- 设置ItemView布局
        recyclerView:SetItemViews(itemViewMap)
        self:LayoutItemViews()
        
        -- set offset
        local scrollOffset = 0
        if contentLength > recyclerView:GetLength() then
            recyclerView:SetScrollBarVisible(true)
            local itemView, index = recyclerView:GetItemViewByAdapterPosition(position)
            rowOrColumn = GetRowOrColumn(self, itemView.ViewHolder.Position)
            if itemView and rowOrColumn > 1 then
                -- 显示的第一个ItemView对应的行/列
                local firstRowOrColumn = GetRowOrColumn(self, recyclerView:GetItemView(1).ViewHolder.Position)
                scrollOffset = GetContentLengthBetweenRowOrColumn(self, firstRowOrColumn, rowOrColumn - 1) + offset

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

    function LayoutItemViews(self)
        local recyclerView = self.RecyclerView
        local relativePointWrapLine = recyclerView.Orientation == Orientation.VERTICAL and "BOTTOMLEFT" or "TOPRIGHT"
        local relativePointSameLine = recyclerView.Orientation == Orientation.VERTICAL and "TOPRIGHT" or "BOTTOMLEFT"

        local lastItemView, firstItemViewRowOrColumn
        for index, itemView in recyclerView:GetItemViews() do
            itemView:ClearAllPoints()
            local rowOrColumn, rowOrColumnIndex = GetRowOrColumn(self, itemView.ViewHolder.Position)
            if index == 1 then 
                firstItemViewRowOrColumn = rowOrColumn
            end
            
            if rowOrColumnIndex == 1 then
                -- 每行/列第一个
                itemView:SetPoint("TOPLEFT", itemView:GetParent(), index == 1 and "TOPLEFT" or relativePointWrapLine, 0, - GetContentLengthBetweenRowOrColumn(self, firstItemViewRowOrColumn, rowOrColumn - 1))
            else
                itemView:SetPoint("TOPLEFT", lastItemView, relativePointSameLine, 0, 0)
            end

            lastItemView = itemView
        end
    end

    function ScrollToPosition(self, position)
        if GetRowOrColumn(self, position) ~= GetRowOrColumn(self, self.LayoutPosition) or self.LayoutOffset ~= 0 then
            self:Layout(position, 0)
        end
    end

    function GetVisibleItemViewCount(self)
        local recyclerView = self.RecyclerView

        local scrollOffset = recyclerView:GetScrollOffset()
        local length = recyclerView:GetLength()
        local itemViewCount = recyclerView:GetItemViewCount()
        local visibleCount = 0
        local firstItemViewRowOrColumn

        for i = 1, itemViewCount do
            local itemView = recyclerView:GetItemView(i)
            local rowOrColumn = GetRowOrColumn(self, itemView.ViewHolder.Position)
            if i == 1 then 
                firstItemViewRowOrColumn = rowOrColumn
            end

            local offset = GetContentLengthBetweenRowOrColumn(self, firstItemViewRowOrColumn, rowOrColumn - 1)

            if offset > scrollOffset then
                visibleCount = visibleCount + 1
            end

            if offset >= scrollOffset + length then
                break
            end
        end

        return visibleCount
    end

    function GetFirstCompletelyVisibleItemView(self)
        local recyclerView = self.RecyclerView
        
        local itemViewCount = recyclerView:GetItemViewCount()
        if itemViewCount <= 0 then return end

        local scrollOffset = recyclerView:GetScrollOffset()
        local firstItemViewRowOrColumn

        for index = 1, itemViewCount do
            local itemView = recyclerView:GetItemView(index)
            local rowOrColumn = GetRowOrColumn(self, itemView.ViewHolder.Position)
            if index == 1 then 
                firstItemViewRowOrColumn = rowOrColumn
            end

            local offset = GetContentLengthBetweenRowOrColumn(self, firstItemViewRowOrColumn, rowOrColumn - 1)

            if offset > scrollOffset then
                return itemView, index, offset
            end
           
            if index ~= itemViewCount then
                offset = offset + itemView:GetLength()
            end
        end
    
        return recyclerView:GetItemView(itemViewCount), itemViewCount, offset
    end

    __Arguments__{ NaturalNumber/1 }
    function __ctor(self, spanCount)
        self.SpanCount = spanCount
        self.__ItemViewInfos = {}
        self.__RowOrColumnInfos = {}
    end

end)