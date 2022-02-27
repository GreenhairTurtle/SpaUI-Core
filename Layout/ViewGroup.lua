PLoop(function()

    namespace "SpaUI.Widget.Layout"
    import "SpaUI.Widget"

    export {
        tinsert         = table.insert,
        tremove         = table.remove,
        tDeleteItem     = tDeleteItem,
        tContains       = tContains
    }

    -------------------------------
    --          ViewGroup        --
    -------------------------------

    -- Subclass need to implement the following functions:
    -- 1. OnGetViewGroupSize
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
            child.OnHide = child.OnHide + OnChildHidev
            child.OnSizeChanged = child.OnSizeChanged + OnChildSizeChanged
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

        -- return iterator for child layout params
        __Final__()
        function GetChildLayoutParams(self)
            return pairs(self.__ChildLayoutParams)
        end

        __Final__()
        function Refresh()
            self.__LayoutRequested = true

            local width, height = self:GetSize()
            -- todo
            local newWidth, newHeight = self:SetViewGroupSize(width, height)

            if newWidth ~= width or newHeight ~= height then
                -- Will trigger OnSizeChanged in parent view group because function:OnChildAdded
                -- So there is no need to continue
                local parent = self:GetParent()
                if parent and ViewGroup.IsViewGroup(parent) then
                    return
                end
            end

            self:LayoutChildren()
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
        -- The size of the viewgroup is determined when this function is called
        __Abstract__()
        function OnLayout(self)
        end

        -- @param maxWidth: the max width this viewgroup can be set, useful when SizeMode is MACTH_PARENT
        -- @param maxHeight: the max height this viewgroup can be set, useful when SizeMode is MATCH_PARENT
        -- Return width and height
        __Final__()
        __Arguments__{ Number, Number }:Throwable()
        function SetViewGroupSize(self, maxWidth, maxHeight)
            if not self:IsShown() then
                self.__Width = 0
                self.__Height = 0
            elseif self.__LayoutRequested or not self.__Width or not self.__Height 
                or not self.__MaxWidth or self.__MaxWidth ~= maxWidth
                or not self.__MaxHeight or self.__MaxHeight ~= maxHeight then
                local width, height = self:OnGetViewGroupSize(maxWidth, maxHeight)
                if type(width) ~= "number" or type(height) ~= "number" then
                    throw("ViewGroup's size must be number")
                end
                
                self.__Width = width
                self.__Height = height
                self.__MaxWidth = maxWidth
                self.__MaxHeight = maxHeight
                self.__LayoutRequested = false
            end
            return self.__Width, self.__Height
        end

        -- Implement this function return view group width and height
        -- You must call GetChildSize function to get child size instead of child:GetSize()
        -- @param maxWidth: the max width this viewgroup can be set, useful when SizeMode is MACTH_PARENT
        -- @param maxHeight: the max height this viewgroup can be set, useful when SizeMode is MATCH_PARENT
        __Abstract__()
        function OnGetViewGroupSize(self, maxWidth, maxHeight)
        end

        -- Get child size
        -- @param maxWidth: the max width this viewgroup can be set, useful when SizeMode is MACTH_PARENT
        -- @param maxHeight: the max height this viewgroup can be set, useful when SizeMode is MATCH_PARENT
        __Final__()
        __Arguments__{ Number, Number }
        function GetChildSize(self, child, maxWidth, maxHeight)
            if ViewGroup.IsViewGroup(child) then
                return child:SetViewGroupSize(maxWidth, maxHeight)
            else
                return child:GetSize()
            end
        end

        -- Check object is view group
        __Static__()
        function IsViewGroup(viewGroup)
            return Class.ValidateValue(ViewGroup, viewGroup, true) and true or false
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
            default             = LayoutDirection.LEFT_TO_RIGHT
        }

        property "LayoutParams" {
            type                = LayoutParams,
            require             = true,
            default             = wrapContentLayoutParams,
            handler             = "Refresh"
        }

    end)

end)