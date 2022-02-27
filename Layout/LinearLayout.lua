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
        function OnGetViewGroupSize(self, maxWidth, maxHeight)
            local width = self.LayoutParams.width
            local height = self.LayoutParams.height
            
            local wFlag, hFlag = false, false

            if width == SizeMode.MATCH_PARENT then
                width = maxWidth
            elseif width == SizeMode.WRAP_CONTENT then
                wFlag = true
            end

            if height == SizeMode.MATCH_PARENT then
                height = maxHeight
            elseif height == SizeMode.WRAP_CONTENT then
                hFlag = true
            end

            for child, layoutParams in pairs(self:GetChildLayoutParams()) do
                local childWidth, childHeight = 
            end

            -- return width, height
        end

    end)

end)