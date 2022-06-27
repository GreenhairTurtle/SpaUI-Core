PLoop(function()

    namespace "MeowMeow.Layout"

    -- Provide some features to all blz widgets
    -- The android style for wow
    __Sealed__()
    interface "IView"(function()
        require "Frame"

        MIN_NUMBER = -2147483648
        MAX_NUMBER = 2147483647

        local function OnLayoutParamsChanged(self, layoutParams, parent)
            parent = parent or self:GetParent()
            if parent and ViewGroup.IsViewGroup(parent) and not parent:CheckLayoutParams(layoutParams) then
                error(self:GetName() .. "'s LayoutParams is not valid for its parent", 2)
            end
        end

        local function OnParentChanged(self, parent, oldParent)
            print("OnParentChanged", self:GetName())
            -- remove view from old parent
            if oldParent and ViewGroup.IsViewGroup(oldParent) then
                print("oldParent", oldParent:GetName(), "remove view", self:GetName())
                oldParent:RemoveView(self)
            end

            if parent ~= ViewRoot.Default and ViewRoot.Default then
                if not parent or not IView.IsView(parent) then
                    -- auto add to view root if no parent or parent is not view
                    print("ViewRoot add view", self:GetName())
                    ViewRoot.Default:AddView(self)
                end
            end

            OnLayoutParamsChanged(self, self.LayoutParams, parent)
        end

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
            maxSize = (not maxSize or maxSize == 0) and MAX_NUMBER or maxSize

            local size = math.max(specSize - usedSize, 0)

            local resultSize = 0
            local resultMode = 0

            if specMode == MeasureSpec.EXACTLY then
                -- Parent has imposed an exact size on us
                if childSize >= 0 then
                    -- Child wants a specific size... so be it
                    resultSize = childSize
                    resultMode = MeasureSpec.EXACTLY
                elseif childSize == SizeMode.MATCH_PARENT then
                    -- Child wants to be parent's size. So be it.
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.EXACTLY
                elseif childSize == SizeMode.WRAP_CONTENT then
                    -- Child wants to determine its own size
                    -- It can't be bigger than us
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.AT_MOST
                end
            elseif specMode == MeasureSpec.AT_MOST then
                -- Parent has imposed a maximum size on us
                if childSize >= 0 then
                    -- Child wants a specific size... so be it
                    resultSize = childSize
                    resultMode = MeasureSpec.EXACTLY
                elseif childSize == SizeMode.MATCH_PARENT then
                    -- Child wants to be parent's size, but parent's size is not fixed.
                    -- Constrain child to not be bigger than parent.
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.AT_MOST
                elseif childSize == SizeMode.WRAP_CONTENT then
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
                    resultMode = MeasureSpec.EXACTLY
                elseif childSize == SizeMode.MATCH_PARENT then
                    -- Child wants to be parent's size... find out how big it should be
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.UNSPECIFIED
                elseif childSize == SizeMode.WRAP_CONTENT then
                    -- Child wants to determine its own size.... 
                    -- find out how big it should be
                    resultSize = math.min(size, maxSize)
                    resultMode = MeasureSpec.UNSPECIFIED
                end
            end

            return MeasureSpec.MakeMeasureSpec(resultMode, resultSize)
        end
        
        -- Measure size
        __Final__()
        function Measure(self, widthMeasureSpec, heightMeasureSpec, forceLayout)
            local specChanged = widthMeasureSpec ~= self.__OldWidthMeasureSpec or heightMeasureSpec ~= self.__OldHeightMeasureSpec
            local isSpecExactly = MeasureSpec.GetMode(widthMeasureSpec) == MeasureSpec.EXACTLY and MeasureSpec.GetMode(widthMeasureSpec) == MeasureSpec.EXACTLY
            local matchesSpecSize = self:GetMeasuredWidth() == MeasureSpec.GetSize(widthMeasureSpec) and self:GetMeasuredHeight() == MeasureSpec.GetSize(heightMeasureSpec)

            if forceLayout or (specChanged and (not isSpecExactly or not matchesSpecSize)) then
                self:OnMeasure(widthMeasureSpec, heightMeasureSpec)
            end
            
            self.__OldWidthMeasureSpec = widthMeasureSpec
            self.__OldHeightMeasureSpec = heightMeasureSpec
        end

        -- This function should call SetMeasuredSize to store measured width and measured height
        __Abstract__()
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            self:SetMeasuredSize(IView.GetDefaultMeasureSize(self.MinWidth, widthMeasureSpec),
                IView.GetDefaultMeasureSize(self.MinHeight, heightMeasureSpec))
        end

        -- Utility to return a default size
        __Static__()
        function GetDefaultMeasureSize(size, measureSpec)
            local result = size
            local mode = MeasureSpec.GetMode(measureSpec)
            
            if mode == MeasureSpec.AT_MOST then
                result = math.min(size, MeasureSpec.GetSize(measureSpec))
            elseif mode == MeasureSpec.EXACTLY then
                result = MeasureSpec.GetSize(measureSpec)
            end

            return result
        end

        -- Change size and goto it's location
        __Final__()
        function Layout(self, forceLayout)
            local width, height = self:GetSize()
            local changed =  math.abs(width - self:GetMeasuredWidth()) >= 0.01 or math.abs(height - self:GetMeasuredHeight()) >= 0.01

            if changed or forceLayout then
                SetSizeInternal(self, self:GetMeasuredWidth(), self:GetMeasuredHeight())
                -- A great opportunity to do something
                self:OnLayout(forceLayout)
            end
        end

        -- Viewgroup should override this function to call Layout function on each of it's children and place child to it's position
        __Abstract__()
        function OnLayout(self, forceLayout)
        end

        __Final__()
        function Refresh(self)
            self:OnRefresh()
        end
        
        -- Viewgroup should override this function to call Refresh on each of it's children
        __Abstract__()
        function OnRefresh(self)
        end

        __Static__()
        function IsView(view)
            return Class.ValidateValue(IView, view, true) and true or false
        end

        -- internal use
        __Final__()
        function RefreshViewRoot(self)
            
        end

        function RequestLayout(self)
            if ViewRoot.IsRootView(self) then
                self:LayoutPass()
            else
                ViewRoot.Default:LayoutPass()
            end
        end

        -- ViewGroup can override this function to check child layoutParams
        -- @return true is valid layout params and false otherwise
        __Abstract__()
        function CheckLayoutParams(self, layoutParams)
        end

        -- return this view whether animating
        function IsAnimating(self)
            return self.__Animating
        end

        __Final__()
        function GetMeasuredWidth(self)
            return self.__MeasuredWidth or MIN_NUMBER
        end

        __Final__()
        function GetMeasuredHeight(self)
            return self.__MeasuredHeight or MIN_NUMBER
        end

        -- This function only can be called in OnMeasure
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

        __Final__()
        function SetPoint(self, ...)
            -- do nothing
        end

        -- internal use
        function SetViewPoint(self, ...)
            Frame.SetPoint(self, ...)
        end

        -- Only direct children of the root view can set frame strata
        __Final__()
        function SetFrameStrata(self, frameStrata)
            local parent = self:GetParent()
            if ViewRoot.IsRootView(parent) then
                self:SetViewFrameStrata(frameStrata)
            end
        end

        -- internal use
        function SetViewFrameStrata(self, frameStrata)
            Frame.SetFrameStrata(self, frameStrata)
        end

        -- Only direct children of the root view can set frame level
        __Final__()
        function SetFrameLevel(self, level)
            local parent = self:GetParent()
            if ViewRoot.IsRootView(parent) then
                self:SetViewFrameLevel(level)
            end
        end

        -- internal use
        function SetViewFrameLevel(self, level)
            Frame.SetFrameLevel(self, level)
        end

        function OnViewPropertyChanged(self)
            self:RequestLayout()
        end

        __Arguments__{ NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0 }
        function SetMargin(self, left, top, right, bottom)
            self.MarginStart = left
            self.MarginEnd = right
            self.MarginTop = top
            self.MarginBottom = bottom
        end

        __Arguments__{ NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0, NonNegativeNumber/0 }
        function SetPadding(self, left, top, right, bottom)
            self.PaddingStart = left
            self.PaddingEnd = right
            self.PaddingTop = top
            self.PaddingBottom = bottom
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

        -----------------------------------------
        --              Propertys              --
        -----------------------------------------

        property "Visibility"       {
            type                    = Visibility,
            default                 = Visibility.VISIBLE,
            handler                 = OnVisibilityChanged
        }

        property "Padding"          {
            type                    = NonNegativeNumber,
            get                     = false,
            set                     = function(self, padding)
                self.PaddingStart = padding
                self.PaddingEnd = padding
                self.PaddingTop = padding
                self.PaddingBottom = padding
            end
        }

        property "PaddingHorizontal"{
            type                    = NonNegativeNumber,
            get                     = false,
            set                     = function(self, paddingHorizontal)
                self.paddingStart = paddingHorizontal
                self.paddingEnd = paddingHorizontal
            end
        }

        property "PaddingVertical"  {
            type                    = NonNegativeNumber,
            get                     = false,
            set                     = function(self, paddingVertical)
                self.paddingStart = paddingVertical
                self.paddingEnd = paddingVertical
            end
        }

        property "PaddingEnd"       {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "PaddingStart"     {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "PaddingTop"       {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "PaddingBottom"    {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "Margin"           {
            type                    = NonNegativeNumber,
            get                     = false,
            set                     = function(self, margin)
                self.MarginStart = margin
                self.MarginEnd = margin
            end
        }

        property "MarginHorizontal" {
            type                    = NonNegativeNumber,
            get                     = false,
            set                     = function(self, marginHorizontal)
                self.MarginStart = marginHorizontal
                self.MarginEnd = marginHorizontal
            end
        }
        
        property "MarginVertical"   {
            type                    = NonNegativeNumber,
            get                     = false,
            set                     = function(self, marginVertical)
                self.MarginTop      = marginVertical
                self.MarginBottom   = marginVertical
            end
        }

        property "MarginEnd"        {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "MarginStart"      {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "MarginTop"        {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "MarginBottom"     {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = OnViewPropertyChanged
        }

        property "MinHeight"        {
            type                    = NonNegativeNumber,
            default                 = 0,
            throwable               = true,
            handler                 = function(self, minHeight)
                if minHeight > self.MaxHeight then
                    throw(self:GetName() + "'s MinHeight can not be larger than MaxHeight")
                end
                self:OnViewPropertyChanged()
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
                self:OnViewPropertyChanged()
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
                self:OnViewPropertyChanged()
            end
        }

        property "MaxHeight"        {
            type                    = NonNegativeNumber,
            default                 = 0,
            handler                 = function(self, maxHeight)
                if maxHeight < self.MinHeight then
                    throw(self:GetName() + "'s MaxHeight can not be lower than MinHeight")
                end
                self:OnViewPropertyChanged()
            end
        }

        __Final__()
        property "Width"            {
            type                    = ViewSize,
            default                 = SizeMode.WRAP_CONTENT,
            handler                 = OnViewPropertyChanged
        }

        __Final__()
        property "Height"           {
            type                    = ViewSize,
            default                 = SizeMode.WRAP_CONTENT,
            handler                 = OnViewPropertyChanged
        }

        __Final__()
        property "FrameStrata"      {
            type                    = FrameStrata,
            default                 = "MEDIUM",
            handler                 = SetFrameStrata
        }

        __Final__()
        property "FrameLevel"       {
            type                    = Number,
            default                 = 1,
            handler                 = SetFrameLevel
        }

        property "LayoutParams"     {
            type                    = LayoutParams,
            throwable               = true,
            handler                 = function(self, layoutParams)
                OnLayoutParamsChanged(self, layoutParams)
                self:OnViewPropertyChanged()
            end
        }

        -----------------------------------------
        --              Constructor            --
        -----------------------------------------

        function __init(self)
            print("View __init", self:GetName())
            self.OnParentChanged = self.OnParentChanged + OnParentChanged
            -- check parent valid
            OnParentChanged(self, self:GetParent())
        end

    end)

    -- Frame, implement IView
    class "View" { Frame, IView }

end)