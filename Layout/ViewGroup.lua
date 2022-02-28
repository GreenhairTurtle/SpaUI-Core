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
        -- This function will not change the original size mode of layout params
        __Final__()
        __Arguments__{ NonNegativeNumber, NonNegativeNumber }
        function SetSizeInternal(self, width, height)
            if width > 0 and self.LayoutParams.width > 0 then
                self.LayoutParams.width = width
            end

            if height > 0 and self.LayoutParams.height > 0 then
                self.LayoutParams.height = height
            end

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
            child.OnShow = child.OnShow + OnChildShow
            child.OnHide = child.OnHide + OnChildHide
            if not ViewGroup.IsViewGroup(child) then
                child.OnSizeChanged = child.OnSizeChanged + OnChildSizeChanged
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

        __Arguments__{ LayoutFrame, NaturalNumber/nil, LayoutParams/wrapContentLayoutParams }:Throwable()
        __Final__()
        function AddChild(self, child, index, layoutParams)
            if tContains(self.__Children, child) then
                throw("The child has already been added")
            end

            if not index then
                index = #self.__Children + 1
            end

            child:ClearAllPoints()
            child:SetParent(self)
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

        __Final__()
        function Refresh()
            -- reduce multi call when layout
            if self.__LayoutRequested then
                return
            end
            self.__LayoutRequested = true

            local layoutParams = self.LayoutParams
            local parent = self:GetParent()
            local inViewGroup = parent and ViewGroup.IsViewGroup(parent)
            -- if ViewGroup's size mode is wrap content, so call parent's refresh function and stop further processing
            if inViewGroup and (layoutParams.width == SizeMode.WRAP_CONTENT or layoutParams.height == SizeMode.WRAP_CONTENT) then
                parent:Refresh()
                return
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
            self:LayoutChildren()

            self.__LayoutRequested = false
        end

        __Final__()
        function LayoutChildren(self)
            for _, child in ipairs(self.__Children) do
                if (ViewGroup.IsViewGroup(child)) then
                    child:LayoutChildren()
                end
            end
            self:OnLayout()
        end

        -- Implement this function to layout child position
        -- You must set each child size except viewgroup self by call ViewGroup.SetChildSize
        -- The size of the viewgroup is determined when this function is called
        __Abstract__()
        function OnLayout(self)
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

        -- Implement this function return view group width and height
        -- Note: If child is viewgroup, please call child:Measure function to get correct size!
        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        __Abstract__()
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
        end

        -- Call this function to get size and child measure spec
        -- Note: size will be nil, you need to call child:Measure function get correct size in subclass
        -- More detail can see LinearLayout
        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        __Arguments__{ MeasureSpec, MeasureSpec }
        function CalcSizeAndChildMeasureSpec(self, widthMeasureSpec, heightMeasureSpec)
            local layoutParams = self.LayoutParams
            local padding = self.Padding
            local width, height, maxWidth, maxHeight

            local childWidthMeasureSpec, childHeightMeasureSpec
            -- calc width
            if widthMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                -- have a specific width
                if layoutParams.width >= 0 then
                    width = layoutParams.width
                    local childWidth = math.max(0, width - padding.left - padding.right)
                    childWidthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childWidth)
                else
                    childWidthMeasureSpec = MeasureSpec(MeasureSpecMode.UNSPECIFIED)
                end
            elseif widthMeasureSpec.mode == MeasureSpecMode.AT_MOST then
                if layoutParams.width >= 0 then
                    width = math.min(widthMeasureSpec.size, layoutParams.width)
                    local childWidth = math.max(0, width - padding.left - padding.right)
                    childWidthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childWidth)
                elseif layoutParams.width == SizeMode.MATCH_PARENT then
                    width = widthMeasureSpec.size
                    local childWidth = math.max(0, width - padding.left - padding.right)
                    childWidthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childWidth)
                else
                    maxWidth = widthMeasureSpec.size
                    local childWidth = math.max(0, widthMeasureSpec.size - padding.left, padding.right)
                    childWidthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childWidth)
                end
            else
                -- width mode = MeasureSpecMode.EXACTLY
                width = widthMeasureSpec.size
                local childWidth = math.max(0, width - padding.left - padding.right)
                childWidthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childWidth)
            end

            -- calc height
            if heightMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                -- have a specific height
                if layoutParams.height >= 0 then
                    height = layoutParams.height
                    local childHeight = math.max(0, height - padding.top - padding.bottom)
                    childHeightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childHeight)
                else
                    childHeightMeasureSpec = MeasureSpec(MeasureSpecMode.UNSPECIFIED)
                end
            elseif heightMeasureSpec.mode == MeasureSpecMode.AT_MOST then
                if layoutParams.height >= 0 then
                    height = math.min(widthMeasureSpec.size, layoutParams.height)
                    local childHeight = math.max(0, height - padding.top - padding.bottom)
                    childHeightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childHeight)
                elseif layoutParams.width == SizeMode.MATCH_PARENT then
                    height = widthMeasureSpec.size
                    local childHeight = math.max(0, height - padding.top - padding.bottom)
                    childHeightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childHeight)
                else
                    local childHeight = math.max(0, heightMeasureSpec.size - padding.top, padding.bottom)
                    childHeightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childHeight)
                end
            else
                -- height mode = MeasureSpecMode.EXACTLY
                height = heightMeasureSpec.size
                local childHeight = math.max(0, height - padding.top - padding.bottom)
                childHeightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, childHeight)
            end

            return width, height, childWidthMeasureSpec, childHeightMeasureSpec
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

        property "Direction"    {
            type                = LayoutDirection,
            default             = LayoutDirection.LEFT_TO_RIGHT + LayoutDirection.TOP_TO_BOTTOM
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