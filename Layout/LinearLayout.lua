PLoop(function()

    namespace "SpaUI.Widget.Layout"

    __Sealed__()
    class "LinearLayout"(function()
        inherit "ViewGroup"

        __Sealed__()
        struct "LayoutParams"(function()
        
            __base = SpaUI.Widget.LayoutParams

            member "gravity"    { Type = Gravity }
            -- This property indicates the weight of the length of the child
            -- in the orientation of the Linearlayout to the remaining allocated space
            member "weight"     { Type = PositiveNumber }

        end)

        property "Orientation"      {
            type                    = Orientation,
            default                 = Orientation.VERTICAL
        }


        local function layoutVertical(self)
            
        end

        local function layoutHorizontal(self)
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
            local layoutParams = self.LayoutParams
            local padding = self.Padding
            local orientation = self.Orientation

            local measureWidth, maxWidth, childWidthMeasureSpecMode = self:GetMeasureSizeAndChildMeasureSpecMode(widthMeasureSpec, Orientation.HORIZONTAL)
            local measureHeight, maxHeight, childHeightMeasureSpecMode = self:GetMeasureSizeAndChildMeasureSpecMode(heightMeasureSpec, Orientation.VERTICAL)
            
            local childWidthAvaliable, childHeightAvaliable
            if measureWidth or maxWidth then
                childWidthAvaliable = (measureWidth or maxWidth) - padding.left - padding.right
            end
            if measureHeight or maxHeight then
                childHeightAvaliable = (measureHeight or maxHeight) - padding.top - padding.bottom
            end

            -- we calculate the content size of viewgroup here, also set child size
            local contentWidth, contentHeight, weightSum = 0, 0, 0
            if orientation == Orientation.VERTICAL then
                for _, child in ipairs(self.__Children) do
                    local childLayoutParams = self.__ChildLayoutParams[child]
                    local margin = childLayoutParams.margin

                    -- weight only worked when size is WRAP_CONTENT, MATCH_PARENT and 0
                    if childLayoutParams.height <= 0 then
                        weightSum = weightSum + (childLayoutParams.weight or 0)
                    end

                    childHeightAvaliable = childHeightAvaliable and (childHeightAvaliable - margin.top - margin.bottom)

                    local childWidth, childHeight = self:MeasureChild(child,
                        MeasureSpec(childWidthMeasureSpecMode, childWidthAvaliable and (childWidthAvaliable - margin.left - margin.right)),
                        MeasureSpec(childHeightMeasureSpecMode, childHeightAvaliable))
                    self:SetChildSize(child, childWidth, childHeight)
                    contentWidth = math.max(childWidth + margin.left + margin.right, contentWidth)
                    contentHeight = contentHeight + childHeight + margin.top + margin.bottom
                end
            else
                for _, child in ipairs(self.__Children) do
                    local childLayoutParams = self.__ChildLayoutParams[child]
                    local margin = childLayoutParams.margin

                    -- weight only worked when size is WRAP_CONTENT, MATCH_PARENT and 0
                    if childLayoutParams.width <= 0 then
                        weightSum = weightSum + (childLayoutParams.weight or 0)
                    end

                    childWidthAvaliable = childWidthAvaliable and (childWidthAvaliable - margin.left - margin.right)

                    local childWidth, childHeight = self:MeasureChild(child,
                        MeasureSpec(childWidthMeasureSpecMode, childWidthAvaliable),
                        MeasureSpec(childHeightMeasureSpecMode, childHeightAvaliable and (childHeightAvaliable - margin.top - margin.bottom)))
                    self:SetChildSize(child, childWidth, childHeight)
                    contentWidth = contentWidth + childWidth + margin.left + margin.right
                    contentHeight = math.max(childHeight + margin.top + margin.bottom, contentHeight)
                end
            end

            -- if measure width or height has value here, means LinearLayout's size is not determined by childs
            local checkWeight = weightSum > 0 and ((orientation == Orientation.VERTICAL and measureHeight) or (orientation == Orientation.HORIZONTAL and measureWidth))

            -- if we have not measure size, so content size is that we need
            if not measureWidth then
                measureWidth = math.min(contentWidth, maxWidth)
            end
            if not measureHeight then
                measureHeight = math.min(contentHeight, maxHeight)
            end

            -- Now that we have determined the LinearLayout size, it's time to recalculate the size of the child.
            -- Because of the weight, some child need to be re-distributed in size
            if checkWeight then
                if orientation == Orientation.VERTICAL then
                    local childHeightRemain = measureHeight - contentHeight
                    if childHeightRemain ~= 0 then
                        for _, child in ipairs(self.__Children) do
                            local childLayoutParams = self.__ChildLayoutParams[child]
                            -- weight only worked when size is WRAP_CONTENT, MATCH_PARENT and 0
                            if childLayoutParams.weight and childLayoutParams.height <= 0 then
                                local newHeight = math.max(0, child:GetHeight() + childHeightRemain * childLayoutParams.weight/weightSum)
                                -- remeasure child to make child's child resize
                                local childWidth, childHeight = self:MeasureChild(child,
                                    MeasureSpec(childWidthMeasureSpecMode, child:GetWidth()),
                                    MeasureSpec(childHeightMeasureSpecMode, newHeight))
                                self:SetChildSize(childWidth, childHeight)
                            end
                        end
                    end
                else
                    local childWidthRemain = measureWidth - contentWidth
                    if childWidthRemain ~= 0 then
                        for _, child in ipairs(self.__Children) do
                            local childLayoutParams = self.__ChildLayoutParams[child]
                            -- weight only worked when size is WRAP_CONTENT, MATCH_PARENT and 0
                            if childLayoutParams.weight and childLayoutParams.width <= 0 then
                                local newWidth = math.max(0, child:GetWidth() + childWidthRemain * childLayoutParams.weight/weightSum)
                                -- remeasure child to make child's child resize
                                local childWidth, childHeight = self:MeasureChild(child,
                                    MeasureSpec(childWidthMeasureSpecMode, newWidth),
                                    MeasureSpec(childHeightMeasureSpecMode, child:GetHeight()))
                                self:SetChildSize(childWidth, childHeight)
                            end
                        end
                    end
                end
            end

            return measureWidth, measureHeight
        end

    end)

end)