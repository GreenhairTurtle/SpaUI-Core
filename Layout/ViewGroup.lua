PLoop(function()

    namespace "SpaUI.Widget.Layout"
    import "SpaUI.Widget"

    export {
        tinsert         = table.insert,
        tremove         = table.remove,
        tDeleteItem     = tDeleteItem,
        tContains       = tContains,
        math            = math
    }

    -------------------------------
    --          ViewGroup        --
    -------------------------------

    -- Subclass need to implement the following functions:
    -- 1. OnMeasure
    -- 2. OnLayout

    -- For more details, see method comment
    class "ViewGroup"(function()
        inherit "Frame"

        local wrapContentLayoutParams = LayoutParams(SizeMode.WRAP_CONTENT, SizeMode.WRAP_CONTENT)

        -- @Override
        __Final__()
        function SetWidth(self, width)
            error("You can not call SetWidth directly in ViewGroup. Change LayoutParams property instead", 2)
        end

        -- @Override
        __Final__()
        function SetHeight(self, height)
            error("You can not call SetHeight directly in ViewGroup. Change LayoutParams property instead", 2)
        end

        -- @Override
        __Final__()
        function SetSize(self, width, height)
            error("You can not call SetSize directly in ViewGroup. Change LayoutParams property instead", 2)
        end

        -- Call this function instead SetSize, only internal use
        __Final__()
        __Arguments__{ NonNegativeNumber, NonNegativeNumber }
        function SetSizeInternal(self, width, height)
            super.SetSize(self, width, height)
        end

        local function OnChildShow(child)
            child:GetParent():Refresh()
        end

        local function OnChildHide(child)
            child:GetParent():Refresh()
        end

        local function OnChildSizeChanged(child)
            child:GetParent():Refresh()
        end

        local function OnChildAdded(self, child)
            child = UI.GetWrapperUI(child)
            child:ClearAllPoints()
            child:SetParent(self)

            if Class.ValidateValue(Frame, child, true) then
                child:SetFrameStrata(self:GetFrameStrata())
                child:SetFrameLevel(self:GetFrameLevel() + 1)
                child.OnShow = child.OnShow + OnChildShow
                child.OnHide = child.OnHide + OnChildHide
                if not ViewGroup.IsViewGroup(child) then
                    child.OnSizeChanged = child.OnSizeChanged + OnChildSizeChanged
                end
            end
        end

        local function OnChildRemoved(self, child)
            child = UI.GetWrapperUI(child)
            child.OnShow = child.OnShow - OnChildShow
            child.OnHide = child.OnHide - OnChildHide
            child.OnSizeChanged = child.OnSizeChanged - OnChildSizeChanged
        end

        __Arguments__{ LayoutFrame, NaturalNumber/nil }:Throwable()
        __Final__()
        function AddChild(self, child, index)
            self:AddChild(child, index, wrapContentLayoutParams)
        end

        __Final__()
        __Arguments__{ LayoutFrame, NaturalNumber/nil, LayoutParams/wrapContentLayoutParams }:Throwable()
        function AddChild(self, child, index, layoutParams)
            if tContains(self.__Children, child) then
                throw("The child has already been added")
            end

            if not index then
                index = #self.__Children + 1
            end

            -- @todo FontString和Texture特殊处理
            OnChildAdded(child)
            tinsert(self.__Children, index, child)
            self.__ChildLayoutParams[child] = layoutParams

            if ViewGroup.IsViewGroup(child) then
                -- set layout params will trigger refresh
                child.LayoutParams = layoutParams
            else
                self:Refresh()
            end
        end

        __Final__()
        __Arguments__{ NEString }
        function RemoveChild(self, childName)
            local child = self:GetChild(childName)
            if not child then return end

            self:RemoveChild(child)
        end

        __Final__()
        __Arguments__{ LayoutFrame }
        function RemoveChild(self, child)
            if child:GetParent() == self then
                self.__ChildLayoutParams[child] = nil
                tDeleteItem(self.__Children, child)
                OnChildRemoved(self, child)
                child:SetParent(nil)
                self:Refresh()
            end
        end

        -- check is refreshing now
        __Final__()
        function IsRefreshing()
            local parent = self:GetParent()
            if parent and ViewGroup.IsViewGroup(parent) then
                return parent:IsRefreshing()
            end

            return self.__Refresh
        end

        __Final__()
        __Arguments__{ Boolean }
        function SetRefreshStatus(isRefresh)
            self.__Refresh = isRefresh
        end

        __Final__()
        function Refresh(self)
            -- reduce multi call when layout
            -- because child OnSizeChanged maybe call multi times in OnMeasure
            if self:IsRefreshing() then
                return
            end
            self:SetRefreshStatus(true)

            local layoutParams = self.LayoutParams
            local parent = self:GetParent()
            local inViewGroup = parent and ViewGroup.IsViewGroup(parent)
            -- if ViewGroup's size mode is wrap content, so call parent's refresh function and stop further processing
            if inViewGroup and (layoutParams.width == SizeMode.WRAP_CONTENT or layoutParams.height == SizeMode.WRAP_CONTENT) then
                return parent:Refresh()
            end

            -- must be the topest viewgroup whose size needs to be changed now.

            -- generate measure spec

            local widthMeasureSpec, heightMeasureSpec
            -- calc width
            if layoutParams.width == SizeMode.WRAP_CONTENT then
                -- width wrap content means no view group parent
                widthMeasureSpec = MeasureSpec(MeasureSpecMode.UNSPECIFIED)
            elseif layoutParams.width == SizeMode.MATCH_PARENT then
                if inViewGroup then
                    widthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, parent:GetWidth())
                else
                    widthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, self:GetWidth())
                end
            else
                widthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, layoutParams.width)
            end

            -- calc height
            if layoutParams.width == SizeMode.WRAP_CONTENT then
                -- height wrap content means not view group parent
                heightMeasureSpec = MeasureSpec(MeasureSpecMode.UNSPECIFIED)
            elseif layoutParams.height == SizeMode.MATCH_PARENT then
                if inViewGroup then
                    heightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, parent:GetHeight())
                else
                    heightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, self:GetHeight())
                end
            else
                heightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, layoutParams.height)
            end

            local newWidth, newHeight = self:Measure(widthMeasureSpec, heightMeasureSpec)
            self:SetSizeInternal(newWidth, newHeight)
            self:Layout()
        end

        __Final__()
        function Layout(self)
            for _, child in ipairs(self.__Children) do
                if (ViewGroup.IsViewGroup(child)) then
                    child:Layout()
                end
            end
            self:OnLayout()
            -- clear refresh status
            self:SetRefreshStatus(false)
        end

        -- Implement this function to layout child position
        -- The size of the viewgroup is determined when this function is called
        -- You can call LayoutChild function to layout child
        __Abstract__()
        function OnLayout(self)
        end

        -- Call this function to layout child. This function will automatically calculate the positions corresponding to different layoutdirections
        __Arguments__{ LayoutFrame, NonNegativeNumber, NonNegativeNumber }
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

        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        -- Return width and height
        __Final__()
        __Arguments__{ MeasureSpec, MeasureSpec }:Throwable()
        function Measure(self, widthMeasureSpec, heightMeasureSpec)
            local width, height = 0, 0
            if self:IsShown() then
                width, height = self:OnMeasure(widthMeasureSpec, heightMeasureSpec)
                if type(width) ~= "number" or type(height) ~= "number" then
                    throw("ViewGroup's size must be number")
                end
            end
            return width, height
        end

        -- Implement this function to measure viewgroup and child size, return view group size
        -- Note: Please call MeasureChild function to get child correct size!
        -- Note: You must call SetChildSize function to set child size!
        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        __Abstract__()
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
        end

        -- Measure child size
        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        -- @return child measure width and height
        __Final__()
        __Arguments__{ LayoutFrame, MeasureSpec, MeasureSpec }
        function MeasureChild(self, child, widthMeasureSpec, heightMeasureSpec)
            if ViewGroup.IsViewGroup(child) then
                return child:Measure(widthMeasureSpec, heightMeasureSpec)
            else
                local childLayoutParams = self.__ChildLayoutParams[child]
                if not LayoutParams.IsValid(child, childLayoutParams) then
                    throw("The layoutparams must set prefWidth or prefHeight if with/height unspecified")
                end

                local width, height
                -- calc width
                if childLayoutParams.width >= 0 then
                    width = childLayoutParams.width
                elseif childLayoutParams.width == SizeMode.MATCH_PARENT then
                    if widthMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        width = childLayoutParams.prefWidth
                    else
                        width = widthMeasureSpec.size
                    end
                else
                    -- wrap content
                    if widthMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        width = childLayoutParams.prefWidth
                    else
                        width = math.min(childLayoutParams.prefWidth, widthMeasureSpec.size)
                    end
                end

                -- calc height
                if childLayoutParams.height >= 0 then
                    height = childLayoutParams.height
                elseif childLayoutParams.height == SizeMode.MATCH_PARENT then
                    if heightMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        height = childLayoutParams.prefHeight
                    else
                        height = widthMeasureSpec.size
                    end
                else
                    -- wrap content
                    if heightMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        height = childLayoutParams.prefHeight
                    else
                        height = math.min(childLayoutParams.prefWidth, heightMeasureSpec.size)
                    end
                end

                return width, height
            end
        end

        -- Get measure size, max size, child measurespec mode
        -- measure size, max size will be nil.
        -- if measure size has value, means parent's size is not determined by childs.
        -- if max size has value, means child is wrap_content but has max size limit
        -- @param measureSpec: measuresepc
        -- @param orientation: horizontal or vertical, correspond layoutParams width or height
        __Arguments__{ MeasureSpec, Orientation }
        function GetMeasureSizeAndChildMeasureSpec(self, measureSpec, orientation)
            local size, mode, measureSize, maxSize
            if orientation == Orientation.VERTICAL then
                size = self.LayoutParams.height
            else
                size = self.LayoutParams.width
            end
            
            -- we respect view group declared size
            if size > 0 then
                measureSize = size
                mode = MeasureSpecMode.AT_MOST
            elseif size == SizeMode.MATCH_PARENT then
                if measureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                    mode = MeasureSpecMode.UNSPECIFIED
                else
                    -- if measurespec mode is EXACTLY, we also set child measurespec mode AT_MOST,
                    -- you can override this function to implement yourself
                    measureSize = measureSpec.size
                    mode = MeasureSpecMode.AT_MOST
                end
            else
                -- wrap content
                if measureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                    mode = MeasureSpecMode.UNSPECIFIED
                elseif measureSpec.mode == MeasureSpecMode.AT_MOST then
                    maxSize = measureSpec.size
                    mode = MeasureSpecMode.AT_MOST
                else
                    -- if measurespec mode is EXACTLY, we also set child measurespec mode AT_MOST,
                    -- you can override this function to implement yourself
                    measureSize = measureSpec.size
                    mode = MeasureSpecMode.AT_MOST
                end
            end

            if not maxSize and measureSize then
                maxSize = measureSize
            end

            return measureSize, maxSize, mode
        end

        -- Check object is view group
        __Static__()
        function IsViewGroup(viewGroup)
            return Class.ValidateValue(ViewGroup, viewGroup, true) and true or false
        end

        __Static__()
        __Arguments__{ LayoutFrame }
        function SetChildSize(child, width, height)
            if ViewGroup.IsViewGroup(child) then
                child:SetSizeInternal(width, height)
            else
                child:SetSize(width, height)
            end
        end

        function __ctor(self)
            self.__Children = {}
            self.__ChildLayoutParams = {}
        end

        property "Padding"      {
            type                = Padding,
            require             = true,
            default             = Padding(0)
        }

        property "LayoutDirection"{
            type                = LayoutDirection,
            default             = LayoutDirection.LEFT_TO_RIGHT + LayoutDirection.TOP_TO_BOTTOM,
            handler             = function(self)
                self:Layout()
            end
        }

        property "LayoutParams" {
            type                = LayoutParams,
            require             = true,
            default             = wrapContentLayoutParams,
            handler             = function(self, layoutParams)
                local parent = self:GetParent()
                if ViewGroup.IsViewGroup(parent) then
                    parent.__ChildLayoutParams[self] = layoutParams
                end

                self:Refresh()
            end
        }

    end)

end)