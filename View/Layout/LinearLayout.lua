PLoop(function()

    namespace "SpaUI.Layout"

    __Sealed__()
    class "LinearLayout"(function()
        inherit "ViewGroup"

        __Sealed__()
        struct "LayoutParams"(function()
        
            __base = SpaUI.Widget.Layout.LayoutParams

            member "gravity"    { Type = Gravity }
            -- This property indicates the weight of the length of the child
            -- in the orientation of the Linearlayout to the remaining allocated space
            member "weight"     { Type = PositiveNumber }

        end)

        property "Orientation"      {
            type                    = Orientation,
            default                 = Orientation.VERTICAL,
            handler                 = function(self)
                self:Refresh()
            end
        }

        -- This property determines the layout alignment of childs
        property "Gravity"          {
            type                    = Gravity,
            default                 = Gravity.TOP + Gravity.START,
            handler                 = function(self)
                self:Layout()
            end
        }

        local function layoutVertical(self)
            local function getHorizontalGravity(gravity)
                if Enum.ValidateFlags(Gravity.CENTER_HORIZONTAL, gravity) then
                    return Gravity.CENTER_HORIZONTAL
                elseif Enum.ValidateFlags(Gravity.END, gravity) then
                    return Gravity.END
                else
                    return Gravity.START
                end
            end

            local gravity = self.Gravity
            local padding = self.Padding
            local paddingStart, paddingTop, paddingEnd, paddingBottom = padding.left, padding.top, padding.right, padding.bottom
            local width, height = self:GetSize()

            local heightAvaliable = height - paddingTop - paddingBottom
            local widthAvaliable = width - paddingStart - paddingEnd
            local defaultHGravity = getHorizontalGravity(gravity)

            local yOffset
            if Enum.ValidateFlags(Gravity.CENTER_VERTICAL, gravity) then
                local centerYOffset = paddingTop + heightAvaliable/2
                yOffset = centerYOffset - self.__ContentHeight/2
            elseif Enum.ValidateFlags(Gravity.BOTTOM, gravity) then
                yOffset = paddingTop + (heightAvaliable - self.__ContentHeight)
            else
                yOffset = paddingTop
            end

            for _, child in ipairs(self.__Children) do
                local childLp = child:GetLayoutParams()
                local margin = childLp.margin
                local marginStart, marginTop, marginEnd, marginBottom = margin.left, margin.top, margin.right, margin.bottom
                local childHGravity = childLp.gravity and getHorizontalGravity(childLp.gravity) or defaultHGravity
                local childWidth, childHeight = child:GetSize()
                local xOffset
                if childHGravity == Gravity.CENTER_HORIZONTAL then
                    xOffset = paddingStart + widthAvaliable/2 - (childWidth + marginStart + marginEnd)/2
                elseif childHGravity == Gravity.END then
                    xOffset = width - paddingEnd - marginEnd - childWidth
                else
                    xOffset = paddingStart
                end
                yOffset = yOffset + marginTop
                self:LayoutChild(child, xOffset, yOffset)
                yOffset = yOffset + childHeight + marginBottom
            end
        end

        local function layoutHorizontal(self)
            local function getVerticalGravity(gravity)
                if Enum.ValidateFlags(Gravity.CENTER_VERTICAL, gravity) then
                    return Gravity.CENTER_VERTICAL
                elseif Enum.ValidateFlags(Gravity.BOTTOM, gravity) then
                    return Gravity.BOTTOM
                else
                    return Gravity.TOP
                end
            end

            local gravity = self.Gravity
            local padding = self.Padding
            local paddingStart, paddingTop, paddingEnd, paddingBottom = padding.left, padding.top, padding.right, padding.bottom

            local width, height = self:GetSize()

            local heightAvaliable = height - paddingTop - paddingBottom
            local widthAvaliable = width - paddingStart - paddingEnd
            local defaultVGravity = getVerticalGravity(gravity)

            local xOffset
            if Enum.ValidateFlags(Gravity.CENTER_HORIZONTAL, gravity) then
                local centerXOffset = paddingStart + widthAvaliable/2
                xOffset = centerXOffset - self.__ContentWidth/2
            elseif Enum.ValidateFlags(Gravity.END, gravity) then
                xOffset = paddingStart + (widthAvaliable - self.__ContentWidth)
            else
                xOffset = paddingStart
            end

            for _, child in ipairs(self.__Children) do
                local childLp = child:GetLayoutParams()
                local margin = childLp.margin
                local marginStart, marginTop, marginEnd, marginBottom = margin.left, margin.top, margin.right, margin.bottom
                local childVGravity = childLp.gravity and getVerticalGravity(childLp.gravity) or defaultVGravity
                local childWidth, childHeight = child:GetSize()
                local yOffset
                if childVGravity == Gravity.CENTER_VERTICAL then
                    yOffset = paddingTop + heightAvaliable/2 - (childHeight + marginTop + marginBottom)/2
                elseif childVGravity == Gravity.BOTTOM then
                    yOffset = height - paddingBottom - marginBottom - childHeight
                else
                    yOffset = paddingTop
                end
                xOffset = xOffset + marginStart
                self:LayoutChild(child, xOffset, yOffset)
                xOffset = xOffset + childWidth + marginEnd
            end
        end

        -- Override
        function OnLayout(self)
            if self.Orientation == Orientation.VERTICAL then
                layoutVertical(self)
            else
                layoutHorizontal(self)
            end
        end

        -- @Override
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            local padding = self.Padding
            local orientation = self.Orientation

            local measureWidth, maxWidth, childWidthMeasureSpecMode = self:GetMeasureSizeAndChildMeasureSpec(widthMeasureSpec, Orientation.HORIZONTAL)
            local measureHeight, maxHeight, childHeightMeasureSpecMode = self:GetMeasureSizeAndChildMeasureSpec(heightMeasureSpec, Orientation.VERTICAL)
            
            local widthAvaliable, heightAvaliable
            if measureWidth or maxWidth then
                widthAvaliable = (measureWidth or maxWidth) - padding.left - padding.right
            end
            if measureHeight or maxHeight then
                heightAvaliable = (measureHeight or maxHeight) - padding.top - padding.bottom
            end

            -- we calculate the content size of viewgroup here, also set child size
            local contentWidth, contentHeight, weightSum = 0, 0, 0
            if orientation == Orientation.VERTICAL then
                for _, child in ipairs(self.__Children) do
                    local childLayoutParams = child:GetLayoutParams()
                    local margin = childLayoutParams.margin

                    -- weight only work when size is WRAP_CONTENT, MATCH_PARENT and 0
                    if childLayoutParams.height <= 0 and child:GetVisibility() ~= Visibility.GONE then
                        weightSum = weightSum + (childLayoutParams.weight or 0)
                    end

                    heightAvaliable = heightAvaliable and (heightAvaliable - margin.top - margin.bottom)

                    local childWidth, childHeight = self:MeasureChild(child,
                        MeasureSpec(childWidthMeasureSpecMode, widthAvaliable and (widthAvaliable - margin.left - margin.right)),
                        MeasureSpec(childHeightMeasureSpecMode, heightAvaliable))
                    self:SetChildSize(child, childWidth, childHeight)
                    contentWidth = math.max(childWidth + margin.left + margin.right, contentWidth)
                    contentHeight = contentHeight + childHeight + margin.top + margin.bottom
                    heightAvaliable = heightAvaliable and (heightAvaliable - childHeight)
                end
            else
                for _, child in ipairs(self.__Children) do
                    local childLayoutParams = child:GetLayoutParams()
                    local margin = childLayoutParams.margin

                    -- weight only work when size is WRAP_CONTENT, MATCH_PARENT and 0
                    if childLayoutParams.width <= 0 and child:GetVisibility() ~= Visibility.GONE then
                        weightSum = weightSum + (childLayoutParams.weight or 0)
                    end

                    widthAvaliable = widthAvaliable and (widthAvaliable - margin.left - margin.right)

                    local childWidth, childHeight = self:MeasureChild(child,
                        MeasureSpec(childWidthMeasureSpecMode, widthAvaliable),
                        MeasureSpec(childHeightMeasureSpecMode, heightAvaliable and (heightAvaliable - margin.top - margin.bottom)))
                    self:SetChildSize(child, childWidth, childHeight)
                    contentWidth = contentWidth + childWidth + margin.left + margin.right
                    contentHeight = math.max(childHeight + margin.top + margin.bottom, contentHeight)
                    widthAvaliable = widthAvaliable and (widthAvaliable - childWidth)
                end
            end

            self.__ContentWidth = contentWidth
            self.__ContentHeight = contentHeight

            -- if measure width or height has value here, means LinearLayout's size is not determined by childs
            local checkWeight = weightSum > 0 and ((orientation == Orientation.VERTICAL and measureHeight) or (orientation == Orientation.HORIZONTAL and measureWidth))

            -- if we have not measure size, so content size is that we need
            if not measureWidth then
                local newMeasureWidth = contentWidth + padding.left + padding.right
                measureWidth = maxWidth and math.min(newMeasureWidth, maxWidth) or newMeasureWidth
            end
            if not measureHeight then
                local newMeasureHeight = contentHeight + padding.top + padding.bottom
                measureHeight = maxHeight and math.min(newMeasureHeight, maxHeight) or newMeasureHeight
            end

            -- Now that we have determined the LinearLayout size, it's time to recalculate the size of the child.
            -- Because of the weight, some child need to be re-distributed in size
            if checkWeight then
                if orientation == Orientation.VERTICAL then
                    local childHeightRemain = measureHeight - contentHeight - padding.top - padding.bottom
                    if childHeightRemain ~= 0 then
                        self.__ContentWidth, self.__ContentHeight = 0, 0
                        for _, child in ipairs(self.__Children) do
                            local childLp = child:GetLayoutParams()
                            local margin = childLp.margin
                            -- weight only work when size is WRAP_CONTENT, MATCH_PARENT and 0
                            if childLp.weight and childLp.height <= 0 and child:GetVisibility() ~= Visibility.GONE then
                                local newHeight = math.max(0, child:GetHeight() + childHeightRemain * childLp.weight/weightSum)
                                --if child is viewgroup, remeasure child to make child's children resize
                                if ViewGroup.IsViewGroup(child) then
                                    local childWidth, childHeight = self:MeasureChild(child,
                                        MeasureSpec(MeasureSpecMode.AT_MOST, child:GetWidth()),
                                        MeasureSpec(MeasureSpecMode.AT_MOST, newHeight))
                                    self:SetChildSize(child, childWidth, childHeight)
                                else
                                    child:SetHeight(newHeight)
                                end
                            end
                            self.__ContentWidth = math.max(child:GetWidth() + margin.left + margin.right, self.__ContentWidth)
                            self.__ContentHeight = self.__ContentHeight + child:GetHeight() + margin.top + margin.bottom
                        end
                    end
                else
                    local childWidthRemain = measureWidth - contentWidth - padding.left - padding.right
                    if childWidthRemain ~= 0 then
                        self.__ContentWidth, self.__ContentHeight = 0, 0
                        for _, child in ipairs(self.__Children) do
                            local childLp = child:GetLayoutParams()
                            local margin = childLp.margin
                            -- weight only work when size is WRAP_CONTENT, MATCH_PARENT and 0
                            if childLp.weight and childLp.width <= 0 and child:GetVisibility() ~= Visibility.GONE then
                                local newWidth = math.max(0, child:GetWidth() + childWidthRemain * childLp.weight/weightSum)
                                -- if child is viewgroup, remeasure child to make child's children resize
                                if ViewGroup.IsViewGroup(child) then
                                    local childWidth, childHeight = self:MeasureChild(child,
                                        MeasureSpec(MeasureSpecMode.AT_MOST, newWidth),
                                        MeasureSpec(MeasureSpecMode.AT_MOST, child:GetHeight()))
                                    self:SetChildSize(child, childWidth, childHeight)
                                else
                                    child:SetWidth(newWidth)
                                end
                            end
                            self.__ContentWidth = self.__ContentWidth + child:GetWidth() + margin.left + margin.right
                            self.__ContentHeight = math.max(child:GetHeight() + margin.top + margin.bottom, self.__ContentHeight)
                        end
                    end
                end
            end

            return measureWidth, measureHeight
        end

    end)

end)