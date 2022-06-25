PLoop(function()

    namespace "MeowMeow.Layout"

    -- Do not constructor this class, it can only has an instance which is IViewRoot.Default
    class "ViewRoot"(function()
        inherit "FrameLayout"

        function DoLayoutPass(self)
            local rootWidthMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, self:GetWidth())
            local rootHeightMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, self:GetHeight())
            self:Measure(IView.GetChildMeasureSpec(rootWidthMeasureSpec, self.MarginStart + self.MarginEnd, self.Width, self.MaxWidth),
                IView.GetChildMeasureSpec(rootHeightMeasureSpec, self.MarginTop + self.MarginBottom, self.Height, self.MaxHeight), true)
            self:Layout(true)
            self:OnLayoutComplete()
            self:Refresh()
        end

        function LayoutPass(self)
            self.__RequestLayoutFlag = true
        end

        local function OnUpdate(self, elapsed)
            if self.__RequestLayoutFlag then
                self.__RequestLayoutFlag = false
                self:DoLayoutPass()
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