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

    class "ViewGroup"(function()
        inherit "ScrollFrame"

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
        __Arguments__{ LayoutFrame, LayoutParams/wrapContentLayoutParams }:Throwable()
        function AddChild(self, child, layoutParams)
            if tContains(self.__Children, child) then
                throw("The child has already been added")
            end

            child:ClearAllPoints()
            child:SetParent(self)
            InstallEventsToChild(child)
            tinsert(self.__Children, child)
            self.__Children[child] = layoutParams
            self:RequestLayout()
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
                tDeleteItem(self.__Children, child)
                self.__Children[child] = nil
                child:SetParent(nil)
                self:RequestLayout()
            end
        end

        __Abstract__()
        function RequestLayout(self)
        end

        -- internal use
        __Abstract__()
        function SetupScrollChild(self)
        end

        function __ctor(self)
            self.__Children = {}
            self:SetupScrollChild()
        end

    end)

end)