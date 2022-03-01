PLoop(function()

    namespace "SpaUI.Widget.Layout"

    __Sealed__()
    class "LinearLayout"(function()
        inherit "ViewGroup"

        __Sealed__()
        struct "LayoutParams"(function()
        
            __base = SpaUI.Widget.LayoutParams

            member "gravity"    { Type = Gravity }
            member "weight"     { Type = NonNegativeNumber }

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

        local function measureVertical(self, widthMeasureSpec, heightMeasureSpec)
            local padding = self.Padding

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
            local contentWidth, contentHeight = 0, 0
            for index, child in ipairs(self.__Children) do
                local childLayoutParams = self.__ChildLayoutParams[child]
                local margin = childLayoutParams.margin

                childHeightAvaliable = childHeightAvaliable and (childHeightAvaliable - margin.top - margin.bottom)

                local childWidth, childHeight = self:MeasureChild(child, MeasureSpec(childWidthMeasureSpecMode, childWidthAvaliable - margin.left - margin.right),
                    MeasureSpec(childHeightMeasureSpecMode, childHeightAvaliable))
                contentWidth = math.max(childWidth + margin.left + margin.right, contentWidth)
                contentHeight = contentHeight + childHeight + margin.top + margin.bottom
            end

            -- if we have not measure size, so content size is that we need
            if not measureWidth then
                measureWidth = math.min(contentWidth, maxWidth)
            end
            if not measureHeight then
                measureHeight = math.min(contentHeight, maxHeight)
            end

            return measureWidth, measureHeight
        end

        -- @Override
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            if self.Orientation == Orientation.VERTICAL then
                return measureVertical(self, widthMeasureSpec, heightMeasureSpec)
            else
                return measureHorizontal(self, widthMeasureSpec, heightMeasureSpec)
            end
        end

    end)

end)