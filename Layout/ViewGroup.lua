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

        local wrapContentLayoutParams = LayoutParams(LayoutSizeMode.WRAP_CONTENT, LayoutSizeMode.WRAP_CONTENT)

        -- @Override
        __Final__()
        function SetWidth(self, width)
            error("You can not call SetWidth directly in ViewGroup. Change LayoutParams property instead")
        end

        -- @Override
        __Final__()
        function SetHeight(self, height)
            error("You can not call SetHeight directly in ViewGroup. Change LayoutParams property instead")
        end

        -- @Override
        __Final__()
        function SetSize(self, width, height)
            error("You can not call SetSize directly in ViewGroup. Change LayoutParams property instead")
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

        local function InstallEventsToChild(self, child)
            child = UI.GetWrapperUI(child)
            child.OnShow = child.OnShow + OnChildShow
            child.OnHide = child.OnHide + OnChildHidev
            child.OnSizeChanged = child.OnSizeChanged + OnChildSizeChanged
        end

        local function UninstallEventsFromChild(self, child)
            child = UI.GetWrapperUI(child)
            child.OnShow = child.OnShow - OnChildShow
            child.OnHide = child.OnHide - OnChildHide
            child.OnSizeChanged = child.OnSizeChanged - OnChildSizeChanged
        end

        __Final__()
        __Arguments__{ LayoutFrame, NaturalNumber/nil, -LayoutParams/wrapContentLayoutParams }:Throwable()
        function AddChild(self, child, index, layoutParams)
            if tContains(self.__Children, child) then
                throw("The child has already been added")
            end

            if not index then
                index = #self.__Children + 1
            end

            child:ClearAllPoints()
            child:SetParent(self)
            InstallEventsToChild(child)
            tinsert(self.__Children, index, child)
            self.__Children[child] = layoutParams
            self:Refresh()
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
                self.__Children[child] = nil
                tDeleteItem(self.__Children, child)
                UninstallEventsFromChild(self, child)
                child:SetParent(nil)
                self:Refresh()
            end
        end

        __Final__()
        function Refresh()
            self.__LayoutRequested = true

            local width, height = self:GetSize()
            local newWidth, newHeight = self:GetViewGroupSize()

            if newWidth ~= width or newHeight ~= height then
                super.SetSize(newWidth, newHeight)
                
                -- Will trigger OnSizeChanged in parent view group
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

        -- Return width and height
        __Final__()
        function GetViewGroupSize(self)
            if self.__LayoutRequested or not self.__Width or not self.__Height then
                local width, height = self:OnGetViewGroupSize()
                if type(width) ~= "number" or type(height) ~= "number" then
                    error("ViewGroup's size must be number", 2)
                end
                
                self.__Width = width
                self.__Height = height
                self.__LayoutRequested = false
            end
            return self.__Width, self.__Height
        end

        -- Implement this function return view group width and height
        -- You must call GetChildSize function to get child size instead of child:GetSize()
        __Abstract__()
        function OnGetViewGroupSize(self)
        end

        -- Get child size
        __Final__()
        function GetChildSize(self, child)
            if ViewGroup.IsViewGroup(child) then
                return child:GetViewGroupSize()
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
            type                = -LayoutParams,
            require             = true,
            default             = wrapContentLayoutParams,
            handler             = "Refresh"
        }

    end)

end)