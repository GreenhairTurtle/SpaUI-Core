PLoop(function()

    namespace "SpaUI.Layout"

    -- Provide some features to all blz widgets
    interface "IView"(function()

        function Refresh(self)
            -- @todo
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
            self:Refresh()
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
            self:Refresh()
        end

        -- @Override
        __Final__()
        function SetShown(self, shown)
            if shown then
                self.Visibility = Visibility.VISIBLE
            else
                self.Visibility = Visibility.GONE
            end
        end

        -- @Override
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
            handler                 = function(self, new, old)
                self:OnVisibilityChanged(new, old)
            end
        }

        property "Padding"          {
            type                    = Padding,
            handler                 = function(self, new, old)
                self:OnPaddingChanged(new, old)
            end
        }
    
    end)

    -- Frame, implement IView
    class "View"{ Frame, IView }

end)