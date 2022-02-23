PLoop(function()

    namespace "SpaUI.Widget.Layout"

    -------------------------------
    --          ViewGroup        --
    -------------------------------

    class "ViewGroup"(function()
        extend "ScrollFrame"

        local wrapContentLayoutParams = LayoutParams(LayoutSizeMode.WRAP_CONTENT, LayoutSizeMode.WRAP_CONTENT)

        property "Padding"      {
            type                = Padding,
            require             = true,
            default             = Padding(0)
        }

        property "Margin"       {
            type                = Margin,
            require             = true,
            default             = Margin(0)
        }

        property "Scrollable"   {
            type                = Boolean
        }

        property "LayoutParams" {
            type                = LayoutParams,
            default             = wrapContentLayoutParams
        }

        local function OnChildShow(child)
            child:GetParent():RequestLayout()
        end

        local function OnChildHide(child)
            child:GetParent():RequestLayout()
        end

        local function InstallEventsToChild(self, child)
            child = UI.GetWrapperUI(child)
            child.OnShow = child.OnShow + OnChildShow
            child.OnHide = child.OnHide + OnChildHide
        end

        __Final__()
        __Arguments__{ LayoutFrame, LayoutParams/wrapContentLayoutParams }
        function AddChild(self, child, layoutParams)
            child:ClearAllPoints()
            child:SetParent(self)
            InstallEventsToChild(child)
            self.__LayoutParams[child] = layoutParams
            self:RequestLayout()
        end

        __Final__()
        __Arguments__{ NEString }
        function RemoveChild(self, childName)
            local child = self:GetChild(childName)
            self:RemoveChild(child)
            self:RequestLayout()
        end

        __Final__()
        __Arguments__{ LayoutFrame/nil }
        function RemoveChild(self, child)
            if not child then return end

            self.__LayoutParams[child] = nil
            child:SetParent(nil)
            self:RequestLayout()
        end

        __Abstract__()
        function RequestLayout(self)
        end

        -- internal use
        __Abstract__()
        function SetupScrollChild(self)
        end

        function __ctor(self)
            self.__LayoutParams = {}
            self:SetupScrollChild()
        end

    end)

end)