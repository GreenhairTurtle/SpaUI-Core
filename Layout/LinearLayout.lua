PLoop(function()

    namespace "SpaUI.Widget.Layout"
    import "SpaUI.Widget"

    __Sealed__()
    class "LinearLayout"(function()
        inherit "ViewGroup"

        __Sealed__()
        struct "LayoutParams"(function()
        
            __base = LayoutParams

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

        local function getVerticalSize(self)
            for index, child in ipairs(self.__Children) do
                local layoutParams = self.__Children[child]

            end
        end

        local function getHorizontalSize(self)
        end

        -- @Override
        function OnGetViewGroupSize(self)
            local layoutParams = self.LayoutParams
            if layoutParams.width >= 0 and layoutParams.height >= 0 then
                return layoutParams.width, layoutParams.height
            end

            if self.Orientation == Orientation.VERTICAL then
                return getVerticalSize(self)
            else
                return getHorizontalSize(self)
            end
        end

    end)

end)