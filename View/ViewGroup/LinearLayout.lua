PLoop(function()

    namespace "SpaUI.Layout"
    import "SpaUI.Layout"

    __Sealed__()
    class "LinearLayout"(function()
        inherit "ViewGroup"

        __Sealed__()
        struct "LayoutParams"(function()
        
            __base = SpaUI.Layout.LayoutParams

            member "gravity"    { Type = Gravity }
            -- This property indicates the weight of the length of the child
            -- in the orientation of the Linearlayout to the remaining allocated space
            member "weight"     { Type = NonNegativeNumber }

        end)

        property "Orientation"      {
            type                    = Orientation,
            default                 = Orientation.HORIZONTAL,
            handler                 = function(self)
                self:OnViewPropertyChanged()
            end
        }

        -- This property determines the layout alignment of childs
        property "Gravity"          {
            type                    = Gravity,
            default                 = Gravity.TOP + Gravity.START,
            handler                 = function(self)
                self:OnViewPropertyChanged()
            end
        }

        local function getHorizontalGravity(gravity, defaultHGravity)
            if Enum.ValidateFlags(Gravity.CENTER_HORIZONTAL, gravity) then
                return Gravity.CENTER_HORIZONTAL
            elseif Enum.ValidateFlags(Gravity.END, gravity) then
                return Gravity.END
            else
                return defaultHGravity or Gravity.START
            end
        end

        local function getVerticalGravity(gravity, defaultVGravity)
            if Enum.ValidateFlags(Gravity.CENTER_VERTICAL, gravity) then
                return Gravity.CENTER_VERTICAL
            elseif Enum.ValidateFlags(Gravity.BOTTOM, gravity) then
                return Gravity.BOTTOM
            else
                return defaultVGravity or Gravity.TOP
            end
        end

        local function layoutVertical(self)
            local gravity = self.Gravity
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom
            local width, height = self:GetSize()

            local heightAvaliable = height - paddingTop - paddingBottom
            local widthAvaliable = width - paddingStart - paddingEnd
            local defaultHGravity = getHorizontalGravity(gravity)

            local yOffset
            if Enum.ValidateFlags(Gravity.CENTER_VERTICAL, gravity) then
                local centerYOffset = paddingTop + heightAvaliable/2
                yOffset = centerYOffset - self.__ContentHeight/2
            elseif Enum.ValidateFlags(Gravity.BOTTOM, gravity) then
                yOffset = paddingTop + heightAvaliable - self.__ContentHeight
            else
                yOffset = paddingTop
            end

            for _, child in self:GetNonGoneChilds() do
                child:Layout()
                local lp = child.LayoutParams

                local marginStart, marginTop, marginEnd, marginBottom = child.MarginStart, child.MarginTop, child.MarginEnd, child.MarginBottom
                local childHGravity = lp and getHorizontalGravity(lp.gravity, defaultHGravity)
                local childWidth, childHeight = child:GetSize()
                local xOffset
                if childHGravity == Gravity.CENTER_HORIZONTAL then
                    xOffset = paddingStart + widthAvaliable/2 - (childWidth + marginStart + marginEnd)/2
                elseif childHGravity == Gravity.END then
                    xOffset = width - paddingEnd - marginEnd - childWidth
                else
                    xOffset = paddingStart
                end
                yOffset = yOffset + marginTop
                self:LayoutChild(child, xOffset, yOffset)
                yOffset = yOffset + childHeight + marginBottom
            end
        end

        local function layoutHorizontal(self)
            local gravity = self.Gravity
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom

            local width, height = self:GetSize()

            local heightAvaliable = height - paddingTop - paddingBottom
            local widthAvaliable = width - paddingStart - paddingEnd
            local defaultVGravity = getVerticalGravity(gravity)

            local xOffset
            if Enum.ValidateFlags(Gravity.CENTER_HORIZONTAL, gravity) then
                local centerXOffset = paddingStart + widthAvaliable/2
                xOffset = centerXOffset - self.__ContentWidth/2
            elseif Enum.ValidateFlags(Gravity.END, gravity) then
                xOffset = paddingStart + (widthAvaliable - self.__ContentWidth)
            else
                xOffset = paddingStart
            end

            for _, child in self:GetNonGoneChilds() do
                child:Layout()
                local lp = child.LayoutParams

                local marginStart, marginTop, marginEnd, marginBottom = child.MarginStart, child.MarginTop, child.MarginEnd, child.MarginBottom
                local childVGravity = lp and getVerticalGravity(lp.gravity, defaultVGravity)
                local childWidth, childHeight = child:GetSize()
                local yOffset
                if childVGravity == Gravity.CENTER_VERTICAL then
                    yOffset = paddingTop + heightAvaliable/2 - (childHeight + marginTop + marginBottom)/2
                elseif childVGravity == Gravity.BOTTOM then
                    yOffset = height - paddingBottom - marginBottom - childHeight
                else
                    yOffset = paddingTop
                end
                xOffset = xOffset + marginStart
                self:LayoutChild(child, xOffset, yOffset)
                xOffset = xOffset + childWidth + marginEnd
            end
        end

        -- Override
        function OnLayout(self)
            if self.Orientation == Orientation.HORIZONTAL then
                layoutHorizontal(self)
            else
                layoutVertical(self)
            end
        end

        local function MeasureHorizontal(self, widthMeasureSpec, heightMeasureSpec)
            local widthMode = MeasureSpec.GetMode(widthMeasureSpec)
            local heightMode = MeasureSpec.GetMode(heightMeasureSpec)
            local expectWidth = MeasureSpec.GetSize(widthMeasureSpec)
            local expectHeight = MeasureSpec.GetSize(heightMeasureSpec)
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom

            local measuredWidth = paddingStart + paddingEnd
            local measuredHeight = 0
            local totalWeight = 0

            for index, child in self:GetNonGoneChilds() do
                local lp = child.LayoutParams
                totalWeight = totalWeight + (lp and lp.weight or 0)

                local marginStart, marginEnd, marginTop, marginBottom = child.MarginStart, child.MarginEnd, child.MarginTop, child.MarginBottom
                local usedHeight = paddingTop + paddingBottom + marginTop + marginBottom
                measuredWidth = measuredWidth + marginStart + marginEnd

                child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, measuredWidth, child.Width, child.MaxWidth),
                    IView.GetChildMeasureSpec(heightMeasureSpec, usedHeight, child.Height, child.MaxHeight))
                measuredWidth = measuredWidth + child:GetMeasuredWidth()
                measuredHeight = math.max(measuredHeight, usedHeight + child:GetMeasuredHeight())
            end

            -- Obviously, weight only work when parent has imposed an exact size on us
            if widthMode == MeasureSpec.EXACTLY and totalWeight > 0 then
                local widthRemain = expectWidth - measuredWidth
                if widthRemain ~= 0 then
                    measuredWidth = paddingStart + paddingEnd
                    for index, child in self:GetNonGoneChilds() do
                        local lp = child.LayoutParams
                        if lp and lp.weight then
                            local newWidth = math.max(0, child:GetMeasuredWidth() + widthRemain * lp.weight/totalWeight)
                            child:Measure(MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, newWidth),
                                MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, child:GetMeasuredHeight()))
                        end
                        measuredWidth = measuredWidth + child.MarginStart + child.MarginEnd + child:GetMeasuredWidth()
                    end
                end
            end

            self.__ContentWidth = measuredWidth - paddingStart - paddingEnd
            self.__ContentHeight = measuredHeight - paddingTop - paddingBottom

            if widthMode == MeasureSpec.EXACTLY then
                measuredWidth = expectWidth
            elseif widthMode == MeasureSpec.AT_MOST then
                measuredWidth = math.max(self.MinWidth, math.min(expectWidth, measuredWidth))
            else
                measuredWidth = math.max(self.MinWidth, measuredWidth)
            end

            if heightMode == MeasureSpec.EXACTLY then
                measuredHeight = expectHeight
            elseif heightMode == MeasureSpec.AT_MOST then
                measuredHeight = math.max(self.MinHeight, math.min(expectHeight, measuredHeight))
            else
                measuredHeight = math.max(self.MinHeight, measuredHeight)
            end
            
            self:SetMeasuredSize(measuredWidth, measuredHeight)
        end

        local function MeasureVertical(self, widthMeasureSpec, heightMeasureSpec)
            local widthMode = MeasureSpec.GetMode(widthMeasureSpec)
            local heightMode = MeasureSpec.GetMode(heightMeasureSpec)
            local expectWidth = MeasureSpec.GetSize(widthMeasureSpec)
            local expectHeight = MeasureSpec.GetSize(heightMeasureSpec)
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom

            local measuredWidth = 0
            local measuredHeight = paddingTop + paddingBottom
            local totalWeight = 0

            for index, child in self:GetNonGoneChilds() do
                local lp = child.LayoutParams
                totalWeight = totalWeight + (lp and lp.weight or 0)

                local marginStart, marginEnd, marginTop, marginBottom = child.MarginStart, child.MarginEnd, child.MarginTop, child.MarginBottom
                local usedWidth = paddingStart + paddingEnd + marginStart + marginEnd
                measuredHeight = measuredHeight + marginTop + marginBottom

                child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, usedWidth, child.Width, child.MaxWidth),
                    IView.GetChildMeasureSpec(heightMeasureSpec, measuredHeight, child.Height, child.MaxHeight))
                measuredWidth = math.max(measuredWidth, usedWidth + child:GetMeasuredWidth())
                measuredHeight = measuredHeight + child:GetMeasuredHeight()
            end

            -- Obviously, weight only work when parent has imposed an exact size on us
            if heightMode == MeasureSpec.EXACTLY and totalWeight > 0 then
                local heightRemain = expectHeight - measuredHeight
                if heightRemain ~= 0 then
                    measuredHeight = paddingTop + paddingBottom
                    for index, child in self:GetNonGoneChilds() do
                        local lp = child.LayoutParams
                        if lp and lp.weight then
                            local newHeight = math.max(0, child:GetMeasuredHeight() + heightRemain * lp.weight/totalWeight)
                            child:Measure(MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, child:GetMeasuredWidth()),
                                MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, newHeight))
                        end
                        measuredHeight = measuredHeight + child.MarginTop + child.MarginBottom + child:GetMeasuredHeight()
                    end
                end
            end

            self.__ContentWidth = measuredWidth - paddingStart - paddingEnd
            self.__ContentHeight = measuredHeight - paddingTop - paddingBottom

            if widthMode == MeasureSpec.EXACTLY then
                measuredWidth = expectWidth
            elseif widthMode == MeasureSpec.AT_MOST then
                measuredWidth = math.max(self.MinWidth, math.min(expectWidth, measuredWidth))
            else
                measuredWidth = math.max(self.MinWidth, measuredWidth)
            end

            if heightMode == MeasureSpec.EXACTLY then
                measuredHeight = expectHeight
            elseif heightMode == MeasureSpec.AT_MOST then
                measuredHeight = math.max(self.MinHeight, math.min(expectHeight, measuredHeight))
            else
                measuredHeight = math.max(self.MinHeight, measuredHeight)
            end
            
            self:SetMeasuredSize(measuredWidth, measuredHeight)
        end

        -- @Override
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            if self.Orientation == Orientation.HORIZONTAL then
                MeasureHorizontal(self, widthMeasureSpec, heightMeasureSpec)
            else
                MeasureVertical(self, widthMeasureSpec, heightMeasureSpec)
            end
        end

        function CheckLayoutParams(self, layoutParams)
            if not layoutParams then return true end

            return Struct.ValidateValue(LinearLayout.LayoutParams, layoutParams, true) and true or false
        end

    end)

end)