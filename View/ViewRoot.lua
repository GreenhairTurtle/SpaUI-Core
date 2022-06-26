PLoop(function()

    namespace "MeowMeow.Layout"

    -- Do not constructor this class, it can only has an instance which is ViewRoot.Default
    class "ViewRoot"(function()
        inherit "FrameLayout"

        function LayoutPass(self)
            self.__RequestLayoutFlag = true
        end

        -- @Override
        function OnChildAdd(self, child)
            child:ClearAllPoints()
            child:SetParent(self)
            child:SetViewFrameStrata(child.FrameStrata)
            child:SetViewFrameLevel(child.FrameLevel)
        end

        -- @Override
        function OnChildAdded(self)
            -- do nothing
        end

        local function DoLayoutPass(self, forceLayout)
            print("DoLayoutPass")
            local rootWidthMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, self:GetWidth())
            local rootHeightMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, self:GetHeight())
            self:Measure(IView.GetChildMeasureSpec(rootWidthMeasureSpec, self.MarginStart + self.MarginEnd, self.Width, self.MaxWidth),
                IView.GetChildMeasureSpec(rootHeightMeasureSpec, self.MarginTop + self.MarginBottom, self.Height, self.MaxHeight), forceLayout)
            self:Layout(forceLayout)
            self:Refresh()
        end

        local function OnUpdate(self, elapsed)
            if self.__RequestLayoutFlag then
                DoLayoutPass(self, true)
                self.__RequestLayoutFlag = false
            end
        end

        -----------------------------------------
        --              Constructor            --
        -----------------------------------------
        function __ctor(self)
            super.__ctor(self)
            self.__RequestLayoutFlag = true
            self.OnUpdate = self.OnUpdate + OnUpdate
        end

        __Static__()
        function IsRootView(view)
            return view == ViewRoot.Default
        end

    end)

    Class "ViewRoot"(function()
                
        DefaultViewRoot = ViewRoot("MeowMeowViewRoot")
        DefaultViewRoot:SetAllPoints(UIParent)
        
        __Static__()
        property "Default" {
            set             = false,
            default         = DefaultViewRoot
        }

    end)

end)