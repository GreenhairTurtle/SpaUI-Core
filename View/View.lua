PLoop(function()

    namespace "SpaUI.Layout"

    -- Provide some features to all blz widgets
    interface "IView"(function()
        require "LayoutFrame"

        __Abstract__()
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
        end

        __Abstract__()
        function OnDraw(self)
        end

        function RequestLayout(self)
            -- @todo
        end

        __Final__()
        function SetWidth(self, width)
        end

        __Final__()
        function SetHeight(self, height)
        end

        function SetSize(self, width, height)
            
        end

        __Arguments__{ LayoutParams/nil }:Throwable()
        function SetLayoutParams(self, layoutParams)
            self.__LayoutParams = layoutParams
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

        __Arguments__{ NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0 }
        function SetPadding(self, left, top, right, bottom)
            self.Padding = Padding(left, top, right, bottom)
        end

        function OnVisibilityChanged(self, new, old)
            -- @todo
        end

        function OnPaddingChanged(self, new, old)
            -- @todo
        end

        property "Visibility"       {
            type                    = Visibility,
            default                 = Visibility.VISIBLE,
            handler                 = OnVisibilityChanged
        }

        property "Padding"          {
            type                    = Padding,
            handler                 = OnPaddingChanged
        }
    
    end)

    -- Frame, implement IView
    class "View" { Frame, IView }

end)