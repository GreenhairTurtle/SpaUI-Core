PLoop(function()

    namespace "SpaUI.Layout"

    -- Provide some features to all blz widgets
    interface "IView"(function()

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

        function OnVisibilityChanged(self, new, old)
            -- @todo
        end

        property "Visibility"       {
            type                    = Visibility,
            default                 = Visibility.VISIBLE,
            handler                 = function(self, new, old)
                self:OnVisibilityChanged(new, old)
            end
        }
    
    end)

    -- Frame, implement IView
    class "View"{ Frame, IView }

end)