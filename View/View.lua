PLoop(function()

    namespace "SpaUI.Layout"

    -- Provide some features to all blz widgets
    -- The android style for wow
    interface "IView"(function()
        require "Frame"

        local MIN_NUMBER = -2147483648
        local MAX_NUMBER = 2147483647

        local function SetWidthInternal(self, width)
            Frame.SetWidth(self, width)
        end

        local function SetHeightInternal(self, height)
            Frame.SetHeight(self, height)
        end

        local function SetSizeInternal(self, width, height)
            Frame.SetSize(self, width, height)
        end

        local function ShowInternal(self)
            Frame.Show(self)
        end

        local function HideInternal(self)
            Frame.Hide(self)
        end

        local function SetShownInternal(self, shown)
            Frame.SetShown(self, shown)
        end

        -- Get child measure spec, copy from Android-ViewGroup
        -- @param measureSpec: The requirements for parent
        -- @param usedSize:Used size for the current dimension for parent
        -- @param childSize:How big the child wants to be in the current dimension
        -- @param maxSize: The max size for the current dimension for child
        __Static__()
        __Arguments__{ Number, NonNegativeNumber, ViewSize, NonNegativeNumber/nil }
        function GetChildMeasureSpec(measureSpec, usedSize, childSize, maxSize)
            local specMode = MeasureSpec.GetMode(measureSpec)
            local specSize = MeasureSpec.GetSize(measureSpec)
            maxSize = (not maxSize or maxSize == 0) or MAX_NUMBER

            local size = math.max(specSize - usedSize, 0)

            local resultSize = 0
            local resultMode = 0

            if specMode == MeasureSpec.EXACTLY then
                -- Parent has imposed an exact size on us
                if childSize >= 0 then
                    -- Child wants a specific size... so be it
                    resultSize = childSize
                    resultMode = MeasureSpec.EXACTLY
                elseif childSize == MeasureSpec.MATCH_PARENT then
                    -- Child wants to be parent's size. So be it.
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.EXACTLY
                elseif childSize == MeasureSpec.WRAP_CONTENT then
                    -- Child wants to determine its own size
                    -- It can't be bigger than us
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.AT_MOST
                end
            elseif sepcMode == MeasureSpec.AT_MOST then
                -- Parent has imposed a maximum size on us
                if childSize >= 0 then
                    -- Child wants a specific size... so be it
                    resultSize = childSize
                    resultMode = measureSpec.EXACTLY
                elseif childSize == MeasureSpec.MATCH_PARENT then
                    -- Child wants to be parent's size, but parent's size is not fixed.
                    -- Constrain child to not be bigger than parent.
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.AT_MOST
                elseif childSize == MeasureSpec.WRAP_CONTENT then
                    -- Child wants to determine its own size
                    -- It can't be bigger than us
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.AT_MOST
                end
            elseif specMode == MeasureSpec.UNSPECIFIED then
                -- Parent asked to see how big child want to be
                if childSize >= 0 then
                    -- Child wants a specific size... let him have it
                    resultSize = childSize
                    resultMode = measureSpec.EXACTLY
                elseif childSize == MeasureSpec.MATCH_PARENT then
                    -- Child wants to be parent's size... find out how big it should be
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.UNSPECIFIED
                elseif childSize == MeasureSpec.WRAP_CONTENT then
                    -- Child wants to determine its own size.... 
                    -- find out how big it should be
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.UNSPECIFIED
                end
            end

            return MeasureSpec.MakeMeasureSpec(resultSize, resultMode)
        end
        
        -- Measure size
        __Final__()
        function Measure(self, widthMeasureSpec, heightMeasureSpec)
            local specChanged = widthMeasureSpec ~= self.__OldWidthMeasureSpec or heightMeasureSpec ~= self.__OldHeightMeasureSpec
            local isSpecExactly = MeasureSpec.GetMode(widthMeasureSpec) == MeasureSpec.EXACTLY and MeasureSpec.GetMode(widthMeasureSpec) == MeasureSpec.EXACTLY
            local matchesSpecSize = self:GetMeasuredWidth() == MeasureSpec.GetSize(widthMeasureSpec) and self:GetMeasuredHeight() == MeasureSpec.GetSize(heightMeasureSpec)

            if specChanged and (not isSpecExactly or not matchesSpecSize) then
                self:OnMeasure(widthMeasureSpec, heightMeasureSpec)
            end
            
            self.__OldWidthMeasureSpec = widthMeasureSpec
            self.__OldHeightMeasureSpec = heightMeasureSpec
        end

        -- This function should call SetMeasuredSize to store measured width and measured height
        __Abstract__()
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            self:SetMeasuredSize(self:GetDefaultMeasureSize(self.MinWidth, widthMeasureSpec),
                self:GetDefaultMeasureSize(self.MinHeight, heightMeasureSpec))
        end

        -- Utility to return a default size
        function GetDefaultMeasureSize(self, size, measureSpec)
            local result = size
            local mode = MeasureSpec.GetMode(measureSpec)
            
            if mode == MeasureSpec.AT_MOST then
                result = math.max(size, MeasureSpec.GetSize(measureSpec))
            elseif mode == MeasureSpec.EXACTLY then
                result = MeasureSpec.GetSize(measureSpec)
            end

            return result
        end

        -- Change size and goto it's location
        __Final__()
        __Arguments__{ LayoutDirection, Number/0, Number/0 }
        function Layout(self, direction, xOffset, yOffset)
            SetSizeInternal(self, self:GetMeasuredWidth(), self:GetMeasuredHeight())

            local point
            if Enum.ValidateFlags(LayoutDirection.TOP_TO_BOTTOM, direction) then
                point = "TOP"
                yOffset = -yOffset
            else
                point = "BOTTOM"
            end
            if Enum.ValidateFlags(LayoutDirection.LEFT_TO_RIGHT, direction) then
                point = point .. "LEFT"
            else
                point = point .. "RIGHT"
                xOffset = -xOffset
            end
            child:ClearAllPoints()
            child:SetPoint(point, xOffset, yOffset)

            -- A great opportunity to do something
            self:OnLayout()
            self.__LayoutRequested = false
        end

        -- Viewgroup should override this function to call Layout on each of it's children and place child to it's position
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
            return not parent or not IView.IsView(parent)
        end

        -- Pass UIParent's measurespec to root view
        local function DoMeasure(self)
            local rootWidthMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, UIParent:GetWidth())
            local rootHeightMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, UIParent:GetHeight())
            local margin = self.Margin
            
            self:Measure(IView.GetChildMeasureSpec(rootWidthMeasureSpec, margin.left + margin.right, self.Width, self.MaxWidth),
                IView.GetChildMeasureSpec(rootHeightMeasureSpec, margin.top + margin.bottom, self.Height, self.MaxHeight))
        end

        local function DoLayout(self)
            DoMeasure(self)
            self:Layout()
            self:Refresh()
        end

        __Async__()
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
                return self:GetParent():RequestLayout()
            end
        end

        __Final__()
        function GetMeasuredWidth(self)
            return self.__MeasuredWidth or MIN_NUMBER
        end

        __Final__()
        function GetMeasuredHeight(self)
            return self.__MeasuredHeight or MIN_NUMBER
        end

        __Final__()
        function GetMeasuredSize(self)
            return self.__MeasuredWidth or 0, self.__MeasuredHeight or 0
        end

        __Final__()
        __Arguments__{ NonNegativeNumber, NonNegativeNumber }
        function SetMeasuredSize(self, width, height)
            self.__MeasuredWidth = width
            self.__MeasuredHeight = height
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
            self:RequestLayout()
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
            handler                 = OnLayoutParamsChanged,
            default                 = function(self)
                return Margin(0)
            end
        }

        property "MinHeight"        {
            type                    = NonNegativeNumber,
            default                 = 0,
            throwable               = true,
            handler                 = function(self, minHeight)
                if minHeight > self.MaxHeight then
                    throw(self:GetName() + "'s MinHeight can not be larger than MaxHeight")
                end
                self:OnLayoutParamsChanged()
            end
        }

        property "MinWidth"         {
            type                    = NonNegativeNumber,
            default                 = 0,
            throwable               = true,
            handler                 = function(self, minWidth)
                if minWidth > self.MaxWidth then
                    throw(self:GetName() + "'s MinWidth can not be larger than MaxWidth")
                end
                self:OnLayoutParamsChanged()
            end
        }

        property "MaxWidth"         {
            type                    = NonNegativeNumber,
            default                 = 0,
            throwable               = true,
            handler                 = function(self, maxWidth)
                if maxWidth < self.MinWidth then
                    throw(self:GetName() + "'s MaxWidth can not be lower than MinWidth")
                end
                self:OnLayoutParamsChanged()
            end
        }

        property "MaxHeight"        {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = function(self, maxHeight)
                if maxHeight < self.MinHeight then
                    throw(self:GetName() + "'s MaxHeight can not be lower than MinHeight")
                end
                self:OnLayoutParamsChanged()
            end
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

        property "LayoutParams"     {
            type                    = LayoutParams,
            handler                 = OnLayoutParamsChanged
        }

        function __init(self)
            self:RequestLayout()
        end

    end)

    -- Frame, implement IView
    class "View" { Frame, IView }

end)