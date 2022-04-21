PLoop(function()

    namespace "SpaUI.Layout.ViewGroup"
    import "SpaUI.Layout"

    class "ViewGroup"(function()
        inherit "View"
        
        -- Call this function to layout child. This function will automatically calculate the positions corresponding to different layoutdirections
        __Final__()
        __Arguments__{ IView, Number, Number }
        function LayoutChild(self, child, xOffset, yOffset)
            local direction = self.direction
            local point
            if Enum.ValidateFlags(LayoutDirection.TOP_TO_BOTTOM, direction) then
                point = "TOP"
                yOffset = -yOffset
            else
                point = "BOTTOM"
            end
            if Enum.ValidateFlags(LayoutDirection.LEFT_TO_RIGHT, direction) then
                point = point .. "LEFT"
            else
                point = point .. "RIGHT"
                xOffset = -xOffset
            end
            child:ClearAllPoints()
            child:SetPoint(point, xOffset, yOffset)

            child:Layout()
        end

        __Arguments__{ IView, NonNegativeNumber/0 }
        function AddView(self, view, index)
            if index <= 0 then
                index = self:GetChildViews() + 1
            end
            tinset(self.__ChildViews, view, index)
            self:RequestLayout()
        end

        __Arguments__{ NaturalNumber }
        function GetChildViewAt(self, index)
            return self.__ChildViews[index]
        end

        function GetChildViewCount(self)
            return #self.__ChildViews
        end

        function GetChildViews(self)
            return self.__ChildViews
        end

        -----------------------------------------
        --              Propertys              --
        -----------------------------------------
        
        property "LayoutDirection"  {
            type                    = LayoutDirection,
            default                 = LayoutDirection.LEFT_TO_RIGHT + LayoutDirection.TOP_TO_BOTTOM,
            handler                 = function(self)
                self:Layout()
            end
        }

        function __ctor(self)
            self.__ChildViews = {}
        end

    end)

end)