PLoop(function()

    namespace "MeowMeow.Layout"

    class "FrameLayout"(function()
        inherit "ViewGroup"

        __Sealed__()
        struct "LayoutParams"(function()
        
            __base = MeowMeow.Layout.LayoutParams

            -- The gravity to apply with the View to which these layout parameters are associated.
            member "gravity"    { Type = Gravity }

        end)

        function OnLayout(self)
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom
            local width, height = self:GetSize()
            local widthAvaliable = width - paddingStart - paddingEnd
            local heightAvaliable = height - paddingTop - paddingBottom

            for _, child in self:GetNonGoneChilds() do
                child:Layout()

                local childWidth, childHeight = child:GetSize()
                local lp = child.LayoutParams
                local gravity = lp and lp.gravity or (Gravity.START + Gravity.TOP)
                local marginStart, marginTop, marginEnd, marginBottom = child.MarginStart, child.MarginTop, child.MarginEnd, child.MarginBottom

                local xOffset
                if Enum.ValidateFlags(Gravity.CENTER_HORIZONTAL, gravity) then
                    local centerXOffset = paddingStart +  widthAvaliable/2
                    xOffset = centerXOffset - childWidth/2
                elseif Enum.ValidateFlags(Gravity.END, gravity) then
                    xOffset = paddingStart + (widthAvaliable - childWidth)
                else
                    xOffset = paddingStart
                end
                xOffset = xOffset + marginStart
                
                local yOffset
                if Enum.ValidateFlags(Gravity.CENTER_HORIZONTAL, gravity) then
                    local centerYOffset = paddingTop + heightAvaliable/2
                    yOffset = centerYOffset - childHeight/2
                elseif Enum.ValidateFlags(Gravity.BOTTOM, gravity) then
                    yOffset = paddingTop + (heightAvaliable - childHeight)
                else
                    yOffset = paddingTop
                end
                yOffset = yOffset + marginTop

                self:LayoutChild(child, xOffset, yOffset)
            end
        end

        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom
            
            local measuredWidth, measuredHeight = 0, 0
            for _, child in self:GetNonGoneChilds() do
                local marginStart, marginEnd, marginTop, marginBottom = child.MarginStart, child.MarginEnd, child.MarginTop, child.MarginBottom
                local usedWidth = paddingStart + paddingEnd + marginStart + marginEnd
                local usedHeight = paddingTop + paddingBottom + marginTop + marginBottom
                child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, usedWidth, child.Width, child.MaxWidth),
                    IView.GetChildMeasureSpec(heightMeasureSpec, usedHeight, child.Height, child.MaxHeight))

                measuredWidth = math.max(measuredWidth, usedWidth + child:GetMeasuredWidth())
                measuredHeight = math.max(measuredHeight, usedHeight + child:GetMeasuredHeight())
            end

            self:SetMeasuredSize(IView.GetDefaultMeasureSize(measuredWidth, widthMeasureSpec), IView.GetDefaultMeasureSize(measuredHeight, heightMeasureSpec))
        end

        function OnChildAdded(self)
            for index, child in self:GetChildViews() do
                child:SetViewFrameLevel(self:GetFrameLevel() + index)
            end
        end

        function CheckLayoutParams(self, layoutParams)
            if not layoutParams then return true end

            return Struct.ValidateValue(FrameLayout.LayoutParams, layoutParams, true) and true or false
        end

    end)

end)