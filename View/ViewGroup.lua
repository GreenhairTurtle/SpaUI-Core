PLoop(function()

    namespace "SpaUI.Layout"

    class "ViewGroup"(function()
        inherit "View"
        
        -- Call this function to layout child. This function will automatically calculate the positions corresponding to different layoutdirections
        __Final__()
        __Arguments__{ IView, Number, Number }
        function LayoutChild(self, child, xOffset, yOffset)
            local direction = self.LayoutDirection
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
        end

        function OnLayoutComplete(self)
            self.__LayoutRequested = false
            for _, child in pairs(self.__ChildViews) do
                child:OnLayoutComplete()
            end
        end

        -- @Override
        function OnRefresh(self)
            for _, child in self:GetNonGoneChilds() do
                child:Refresh()
            end
        end

        __Arguments__{ IView }
        function RemoveView(self, view)
            if tContains(self.__ChildViews, view) then
                view:SetParent(nil)
                view:ClearAllPoints()
                tDeleteItem(self.__ChildViews, view)
                self:RequestLayout()
            end
        end

        __Arguments__{ IView, NonNegativeNumber/0 }
        function AddView(self, view, index)
            if index <= 0 then
                index = #self.__ChildViews + 1
            end
            view:ClearAllPoints()
            view:SetParent(self)
            tinsert(self.__ChildViews, index, view)
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

        -- Internal use, iterator
        function GetNonGoneChilds(self)
            return function(views, index)
                index = (index or 0) + 1
                for i = index, #views do
                    local view = views[i]
                    if view.Visibility ~= Visibility.GONE then
                        return i, view
                    end
                end
            end, self.__ChildViews, 0
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