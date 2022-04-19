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
        
        -- Measure size
        __Final__()
        __Arguments__{ MeasureSpec, MeasureSpec }
        function Measure(self, widthMeasureSpec, heightMeasureSpec)
            local specChanged = widthMeasureSpec == self.__OldWidthMeasureSpec or heightMeasureSpec == self.__OldHeightMeasureSpec
            local isSpecExactly = widthMeasureSpec.Mode == MeasureSpecMode.EXACTLY and heightMeasureSpec.Mode == MeasureSpecMode.EXACTLY
            local matchesSpecSize = self:GetMeasuredWidth() == widthMeasureSpec.Size and self:GetMeasuredHeight() == heightMeasureSpec.Size

            if specChanged and (not isSpecExactly or not matchesSpecSize) then
                self:OnMeasure(widthMeasureSpec, heightMeasureSpec)
            end
            
            self.__OldWidthMeasureSpec = widthMeasureSpec
            self.__OldHeightMeasureSpec = heightMeasureSpec
        end

        -- This function should call SetMeasuredSize to store measured width and measured height
        __Abstract__()
        __Arguments__{ MeasureSpec, MeasureSpec }
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            self:SetMeasuredSize(self:GetDefaultMeasureSize(self.MinWidth, widthMeasureSpec),
                self:GetDefaultMeasureSize(self.MinHeight, heightMeasureSpec))
        end

        -- Utility to return a default size. Uses the supplied size if the MeasureSpec imposed no constraints.
        -- Will get larger if allowed by the MeasureSpec.
        __Static__()
        function GetDefaultMeasureSize(size, measureSpec)
            local result = size
            local mode = measureSpec.Mode
            
            if mode == MeasureSpecMode.AT_MOST or mode == MeasureSpecMode.EXACTLY then
                result = measureSpec.Size
            end

            return result
        end

        -- Change size
        __Final__()
        function Layout(self)
            SetSizeInternal(self, self:GetMeasuredWidth(), self:GetMeasuredHeight())
            self:OnLayout()
            self.__LayoutRequested = false
        end

        -- Viewgroup should override this function to call Layout on each of it's children
        __Abstract__()
        function OnLayout(self)
        end

        function Refresh(self)
            self:OnRefresh()
        end
        
        __Abstract__()
        function OnRefresh(self)
        end

        function IsLayoutRequested(self)
            return self.__LayoutRequested
        end

        __Static__()
        function IsView(view)
            return Class.ValidateValue(View, view, true) and true or false
        end

        function IsRootView(self)
            local parent = self:GetParent()
            return not parent or not View.IsView(parent)
        end

        -- Generate measure spec, usaully used by root view
        local function GenerateMeasureSpec(viewSize, prefSize)
            if viewSize == SizeMode.WRAP_CONTENT then
                return MeasureSpec(MeaspecSpecMode.UNSPECIFIED, prefSize)
            elseif viewSize == SizeMode.MATCH_PARENT then
                return MeasureSpec(MeasureSpecMode.AT_MOST, prefSize)
            else
                return MeasureSpec(MeasureSpecMode.AT_MOST, viewSize)
            end
        end

        local function DoLayout(self)
            self:Measure(GenerateMeasureSpec(self.Width, self:GetPrefWidth()), GenerateMeasureSpec(self.Height, self:GetPrefHeight()))
            self:Layout()
            self:Refresh()
        end

        __Async__(true)
        function RequestLayout(self)
            self.__LayoutRequestTime = GetTime()
            if self.__LayoutRequested then
                return
            end

            self.__LayoutRequested = true

            -- Delay some times to reduce layout pass
            while self:IsRootView() and GetTime() - self.__LayoutRequestTime < 0.05 do
                Next()
            end

            if self:IsRootView() then
                DoLayout(self)
            else
                self:GetParent():RequestLayout()
            end
        end

        __Final__()
        function GetMeasuredWidth(self)
            return self.__MeasuredWidth or 0
        end

        __Final__()
        function GetMeasuredHeight(self)
            return self.__MeasuredHeight or 0
        end

        __Final__()
        function GetMeasuredSize(self)
            return self.__MeasuredWidth or 0, self.__MeasuredHeight or 0
        end

        __Final__()
        function SetMeasuredSize(self, width, height)
            self.__MeasuredWidth = width
            self.__MeasuredHeight = height
        end

        function GetPrefWidth(self)
            if self.PrefWidth >= 0 then
                return self.PrefWidth
            else
                error(self:GetName() + "'s PrefWidth is invalid", 2)
            end
        end

        function GetPrefHeight(self)
            if self.PrefHeight >= 0 then
                return self.PrefHeight
            else
                error(self:GetName() + "'s PrefHeight is invalid", 2)
            end
        end

        __Final__()
        __Arguments__{ ViewSize }
        function SetWidth(self, width)
            self.Width = width
        end

        __Final__()
        __Arguments__{ ViewSize }
        function SetHeight(self, height)
            self.Height = height
        end

        __Final__()
        __Arguments__{ ViewSize, ViewSize }
        function SetSize(self, width, height)
            self.Width = width
            self.Height = height
        end

        function OnLayoutParamsChanged(self)
            self:RequestLayout()
        end

        __Arguments__{ NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0 }
        function SetMargin(self, left, top, right, bottom)
            self.Margin = Margin(left, top, right, bottom)
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

        property "LayoutDirection"  {
            type                    = LayoutDirection,
            default                 = LayoutDirection.LEFT_TO_RIGHT + LayoutDirection.TOP_TO_BOTTOM,
            handler                 = function(self)
                self:Layout()
            end
        }

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

        property "Margin"           {
            type                    = Margin,
            handler                 = OnMarginChanged,
            default                 = function(self)
                return Margin(0)
            end
        }

        property "MinHeight"        {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = RequestLayout
        }

        property "MinWidth"         {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = RequestLayout
        }

        property "Width"            {
            type                    = ViewSize,
            default                 = SizeMode.WRAP_CONTENT,
            handler                 = OnLayoutParamsChanged
        }

        property "Height"           {
            type                    = ViewSize,
            default                 = SizeMode.WRAP_CONTENT,
            handler                 = OnLayoutParamsChanged
        }

        property "PrefWidth"        {
            type                    = ViewSize,
            default                 = 0,
            handler                 = OnLayoutParamsChanged
        }

        property "PrefHeight"       {
            type                    = ViewSize,
            default                 = 0,
            handler                 = OnLayoutParamsChanged
        }

    end)

    -- Frame, implement IView
    class "View" { Frame, IView }

end)