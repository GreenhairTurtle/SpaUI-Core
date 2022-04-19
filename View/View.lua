PLoop(function()

    namespace "SpaUI.Layout"

    -- Provide some features to all blz widgets
    -- The android style for wow
    interface "IView"(function()
        require "LayoutFrame"

        local function SetWidthInternal(self, width)
            LayoutFrame.SetWidth(self, width)
        end

        local function SetHeightInternal(self, height)
            LayoutFrame.SetHeight(self, height)
        end

        local function SetSizeInternal(self, width, height)
            LayoutFrame.SetSize(self, width, height)
        end

        local function ShowInternal(self)
            LayoutFrame.Show(self)
        end

        local function HideInternal(self)
            LayoutFrame.Hide(self)
        end

        local function SetShownInternal(self, shown)
            LayoutFrame.SetShown(self, shown)
        end
        
        -- PH for future expansion
        __Final__()
        __Arguments__{ MeasureSpec, MeasureSpec }
        function Measure(self, widthMeasureSpec, heightMeasureSpec)
            self:OnMeasure(widthMeasureSpec, heightMeasureSpec)
        end

        -- This function should call SetMeasuredDimension to store measured width and measured height
        __Abstract__()
        __Arguments__{ MeasureSpec, MeasureSpec }
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
        end

        __Abstract__()
        function OnRefresh(self)
        end

        function RequestLayout(self)
            -- @todo
        end

        function Refresh(self)
            self:OnRefresh()
        end

        __Final__()
        __Arguments__{ NonNegativeNumber + SizeMode }
        function SetWidth(self, width)
            local lp = self:GetLayoutParams()
            lp.width = width
            self:OnLayoutParamsChanged()
        end

        __Final__()
        __Arguments__{ NonNegativeNumber + SizeMode }
        function SetHeight(self, height)
            local lp = self:GetLayoutParams()
            lp.height = height
            self:OnLayoutParamsChanged()
        end

        __Final__()
        __Arguments__{ NonNegativeNumber + SizeMode, NonNegativeNumber + SizeMode }
        function SetSize(self, width, height)
            local lp = self:GetLayoutParams()
            lp.width = width
            lp.height = height
            self:OnLayoutParamsChanged()
        end

        __Arguments__{ LayoutParams/nil }:Throwable()
        function SetLayoutParams(self, layoutParams)
            self.__LayoutParams = layoutParams
            self:OnLayoutParamsChanged()
        end

        __Final__()
        function GetLayoutParams(self)
            if not self.__LayoutParams then
                self.__LayoutParams = LayoutParams(SizeMode.WRAP_CONTENT, SizeMode.WRAP_CONTENT)
            end
            return self.__LayoutParams
        end

        function OnLayoutParamsChanged(self)
            self:RequestLayout()
        end

        __Arguments__{ NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0 }
        function SetMargin(self, left, top, right, bottom)
            local lp = self:GetLayoutParams()
            lp.margin = Margin(left, top, right, bottom)
            self:OnMarginChanged(lp.margin)
        end

        __Arguments__{ Margin }
        function SetMargin(self, margin)
            local lp = self:GetLayoutParams()
            lp.margin = margin
            self:OnMarginChanged(margin)
        end

        function GetMargin(self)
            return self:GetLayoutParams().margin
        end

        function OnMarginChanged(self, margin)
            self:RequestLayout()
        end

        __Arguments__{ NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0 }
        function SetPadding(self, left, top, right, bottom)
            self.Padding = Padding(left, top, right, bottom)
        end

        function OnPaddingChanged(self, new, old)
            self:Refresh()
        end

        __Final__()
        function SetShown(self, shown)
            if shown then
                self.Visibility = Visibility.VISIBLE
            else
                self.Visibility = Visibility.GONE
            end
        end

        __Final__()
        function Show(self)
            self.Visibility = Visibility.VISIBLE
        end

        __Final__()
        function Hide(self)
            self.Visibility = Visibility.GONE
        end

        function OnVisibilityChanged(self, visibility, old)
            SetShownInternal(self, visibility == Visibility.VISIBLE)
        end

        property "Visibility"       {
            type                    = Visibility,
            default                 = Visibility.VISIBLE,
            handler                 = OnVisibilityChanged
        }

        property "Padding"          {
            type                    = Padding,
            handler                 = OnPaddingChanged,
            default                 = function(self)
                return Padding(0)
            end
        }
    
    end)

    -- Frame, implement IView
    class "View" { Frame, IView }

end)