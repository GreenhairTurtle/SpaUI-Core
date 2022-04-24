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
                self:RequestLayout()
            end
        }

        -- This property determines the layout alignment of childs
        property "Gravity"          {
            type                    = Gravity,
            default                 = Gravity.TOP + Gravity.START,
            handler                 = function(self)
                self:Layout()
            end
        }

        local function getHorizontalGravity(gravity)
            if Enum.ValidateFlags(Gravity.CENTER_HORIZONTAL, gravity) then
                return Gravity.CENTER_HORIZONTAL
            elseif Enum.ValidateFlags(Gravity.END, gravity) then
                return Gravity.END
            else
                return Gravity.START
            end
        end

        local function layoutVertical(self)
            local gravity = self.Gravity
            local padding = self.Padding
            local paddingStart, paddingTop, paddingEnd, paddingBottom = padding.left, padding.top, padding.right, padding.bottom
            local width, height = self:GetSize()

            local heightAvaliable = height - paddingTop - paddingBottom
            local widthAvaliable = width - paddingStart - paddingEnd
            local defaultHGravity = getHorizontalGravity(gravity)

            local yOffset
            if Enum.ValidateFlags(Gravity.CENTER_VERTICAL, gravity) then
                local centerYOffset = paddingTop + heightAvaliable/2
                yOffset = centerYOffset - self.__ContentHeight/2
            elseif Enum.ValidateFlags(Gravity.BOTTOM, gravity) then
                yOffset = paddingTop + (heightAvaliable - self.__ContentHeight)
            else
                yOffset = paddingTop
            end

            for _, child in self:GetNonGoneChilds() do
                child:Layout()
                local lp = child.LayoutParams
                local margin = child.Margin
                local marginStart, marginTop, marginEnd, marginBottom = margin.left, margin.top, margin.right, margin.bottom
                local childHGravity = lp and lp.gravity and getHorizontalGravity(lp.gravity) or defaultHGravity
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

        
        local function getVerticalGravity(gravity)
            if Enum.ValidateFlags(Gravity.CENTER_VERTICAL, gravity) then
                return Gravity.CENTER_VERTICAL
            elseif Enum.ValidateFlags(Gravity.BOTTOM, gravity) then
                return Gravity.BOTTOM
            else
                return Gravity.TOP
            end
        end

        local function layoutHorizontal(self)
            local gravity = self.Gravity
            local padding = self.Padding
            local paddingStart, paddingTop, paddingEnd, paddingBottom = padding.left, padding.top, padding.right, padding.bottom

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
                local margin = child.Margin
                local marginStart, marginTop, marginEnd, marginBottom = margin.left, margin.top, margin.right, margin.bottom
                local childVGravity = lp and lp.gravity and getVerticalGravity(lp.gravity) or defaultVGravity
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
            local padding = self.Padding

            local measuredWidth = padding.left + padding.right
            local measuredHeight = 0
            local totalWeight = 0

            for index, child in self:GetNonGoneChilds() do
                local lp = child.LayoutParams
                totalWeight = totalWeight + (lp and lp.weight or 0)

                local margin = child.Margin
                local usedHeight = padding.top + padding.bottom + margin.top + margin.bottom
                measuredWidth = measuredWidth + margin.left + margin.right

                child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, measuredWidth, child.Width, child.MaxWidth),
                    IView.GetChildMeasureSpec(heightMeasureSpec, usedHeight, child.Height, child.MaxHeight))
                measuredWidth = measuredWidth + child:GetMeasuredWidth()
                measuredHeight = math.max(measuredHeight, usedHeight + child:GetMeasuredHeight())
            end

            -- Obviously, weight only work when parent has imposed an exact size on us
            if widthMode == MeasureSpec.EXACTLY and totalWeight > 0 then
                local widthRemain = expectWidth - measuredWidth
                if widthRemain ~= 0 then
                    for index, child in self:GetNonGoneChilds() do
                        local lp = child.LayoutParams
                        if lp and lp.weight then
                            local newWidth = math.max(0, child:GetMeasuredWidth() + widthRemain * lp.weight/totalWeight)
                            child:Measure(MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, newWidth),
                                MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, child:GetMeasuredHeight()))
                        end
                    end
                end
            end

            self.__ContentWidth = measuredWidth - padding.left - padding.right
            self.__ContentHeight = measuredHeight - padding.top - padding.bottom

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
            local padding = self.Padding

            local measuredWidth = 0
            local measuredHeight = padding.top + padding.bottom
            local totalWeight = 0

            for index, child in self:GetNonGoneChilds() do
                local lp = child.LayoutParams
                totalWeight = totalWeight + (lp and lp.weight or 0)

                local margin = child.Margin
                local usedWidth = padding.left + padding.right + margin.left + margin.bottom
                measuredHeight = measuredHeight + margin.top + margin.bottom

                child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, usedWidth, child.Width, child.MaxWidth),
                    IView.GetChildMeasureSpec(heightMeasureSpec, measuredHeight, child.Height, child.MaxHeight))
                measuredWidth = math.max(measuredWidth, usedWidth + child:GetMeasuredWidth())
                measuredHeight = measuredHeight + child:GetMeasuredHeight()
            end

            -- Obviously, weight only work when parent has imposed an exact size on us
            if heightMode == MeasureSpec.EXACTLY and totalWeight > 0 then
                local heightRemain = expectHeight - measuredHeight
                if heightRemain ~= 0 then
                    for index, child in self:GetNonGoneChilds() do
                        local lp = child.LayoutParams
                        if lp and lp.weight then
                            local newHeight = math.max(0, child:GetMeasuredHeight() + heightRemain * lp.weight/totalWeight)
                            child:Measure(MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, child:GetMeasuredWidth()),
                                MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, newHeight))
                        end
                    end
                end
            end

            self.__ContentWidth = measuredWidth - padding.left - padding.right
            self.__ContentHeight = measuredHeight - padding.top - padding.bottom

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