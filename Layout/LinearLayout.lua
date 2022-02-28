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

        -- @Override
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            local width, height, childWidthMeasureSpec, childHeightMeasureSpec = self:CalcSizeAndChildMeasureSpec(widthMeasureSpec, heightMeasureSpec)
            
            local contentWidth, contentHeight = 0, 0
            for child, layoutParams in self:GetChildLayoutParams() do
                if ViewGroup.IsViewGroup(child) then
                    local childWidth, childHeight = child:Measure(childWidthMeasureSpec, childHeightMeasureSpec)
                    contentWidth = contentWidth + childWidth
                    contentHeight = contentHeight + contentHeight
                end
            end

            return width, height
        end

    end)

end)