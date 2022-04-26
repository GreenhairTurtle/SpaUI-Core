PLoop(function()

    namespace "SpaUI.Layout"

    class "ViewGroup"(function()
        inherit "View"
        
        -- Call this function to layout child. This function will automatically calculate the positions corresponding to different layoutdirections
        __Final__()
        __Arguments__{ IView, Number, Number }
        function LayoutChild(self, child, xOffset, yOffset)
            local direction = self.LayoutDirection
            local width, height = child:GetSize()
            local point
            if Enum.ValidateFlags(LayoutDirection.TOP_TO_BOTTOM, direction) then
                point = "TOP"
                yOffset = -yOffset - height/2
            else
                point = "BOTTOM"
                yOffset = yOffset + height/2
            end
            if Enum.ValidateFlags(LayoutDirection.LEFT_TO_RIGHT, direction) then
                point = point .. "LEFT"
                xOffset = xOffset + width/2
            else
                point = point .. "RIGHT"
                xOffset = -xOffset - width/2
            end
            child:ClearAllPoints()
            child:SetPointInternal("CENTER", self, point, xOffset, yOffset)
        end

        function OnLayoutComplete(self)
            super.OnLayoutComplete(self)
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

        -- @Override
        function SetFrameStrataInternal(self, frameStrata)
            super.SetFrameStrataInternal(self, frameStrata)
            for _, child in self.__ChildViews do
                child:SetFrameStrataInternal(frameStrata)
            end
        end

        -- @Override
        function SetFrameLevelInternal(self, level)
            super.SetFrameLevelInternal(self, level)
            for _, child in self.__ChildViews do
                child:SetFrameLevelInternal(level)
            end
        end

        __Arguments__{ IView }
        function RemoveView(self, view)
            if tContains(self.__ChildViews, view) then
                self:OnChildRemove(view)
                tDeleteItem(self.__ChildViews, view)
                self:OnChildRemoved()
                self:RequestLayout()
            end
        end

        function OnChildRemoved(self, child)
            child:ClearAllPoints()
            child:SetParent(nil)
        end

        __Abstract__()
        function OnChildRemoved(self)
        end

        __Arguments__{ IView, NonNegativeNumber/0 }
        function AddView(self, view, index)
            if not tContains(self.__ChildViews, view) then
                if index <= 0 then
                    index = #self.__ChildViews + 1
                end
                self:OnChildAdd(view)
                tinsert(self.__ChildViews, index, child)
                self:OnChildAdded()
                self:RequestLayout()
            end
        end

        function OnChildAdd(self, child)
            child:ClearAllPoints()
            child:SetFrameStrataInternal(self:GetFrameStrata())
            child:SetFrameLevelInternal(self:GetFrameLevel())
            child:SetParent(self)
        end

        __Abstract__()
        function OnChildAdded(self)
        end

        __Arguments__{ NaturalNumber }
        function GetChildViewAt(self, index)
            return self.__ChildViews[index]
        end

        function GetChildViewCount(self)
            return #self.__ChildViews
        end

        function GetChildViews(self)
            return ipairs(self.__ChildViews)
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