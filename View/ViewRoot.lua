PLoop(function()

    namespace "MeowMeow.Layout"

    -- Note:Do not constructor this class, it can only has an instance which is ViewRoot.Default
    -- ViewRoot is a special frame layout, it set all widgets which no parent or parent is UIParent as it's child(use blz api, can access by Region:GetChildren()),
    -- but also store all widgets which parent is not view (see View.OnParentChanged)
    class "ViewRoot"(function()
        inherit "ViewGroup"

        __Sealed__()
        struct "LayoutParams"(function()
        
            __base = MeowMeow.Layout.LayoutParams

            -- The gravity to apply with the View to which these layout parameters are associated.
            member "gravity"    { Type = Gravity }

        end)

        function LayoutPass(self)
            self.__RequestLayoutFlag = true
        end

        -- @Override
        function OnChildAdd(self, child)
            -- only no parent or parent is UIParent will set parent(blz api) as view root
            local parent = child:GetParent()
            if not parent or parent == UIParent then
                child:SetParent(self)
            end

            child:SetViewFrameStrata(child.FrameStrata)
            child:SetViewFrameLevel(child.FrameLevel)
        end

        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom
            local specWidth, specHeight = MeasureSpec.GetSize(widthMeasureSpec), MeasureSpec.GetSize(heightMeasureSpec)
            
            for _, child in self:GetNonGoneChilds() do
                local marginStart, marginEnd, marginTop, marginBottom = child.MarginStart, child.MarginEnd, child.MarginTop, child.MarginBottom
                local usedWidth = paddingStart + paddingEnd + marginStart + marginEnd
                local usedHeight = paddingTop + paddingBottom + marginTop + marginBottom
                local childParent = child:GetParent()
                
                -- parent is view root
                if childParent == self then
                    child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, usedWidth, child.Width, child.MaxWidth),
                        IView.GetChildMeasureSpec(heightMeasureSpec, usedHeight, child.Height, child.MaxHeight))
                else
                    widthMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, childParent:GetWidth() - marginStart - marginEnd)
                    heightMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, childParent:GetHeight() - marginTop - marginBottom)
                    child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, 0, child.Width, child.MaxWidth),
                        IView.GetChildMeasureSpec(heightMeasureSpec, 0, child.Height, child.MaxHeight))
                end
            end

            self:SetMeasuredSize(specWidth, specHeight)
        end

        function OnLayout(self, forceLayout)
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom
            local width, height = self:GetSize()
            local widthAvaliable = width - paddingStart - paddingEnd
            local heightAvaliable = height - paddingTop - paddingBottom

            for _, child in self:GetNonGoneChilds() do
                print(self:GetName(), "OnLayout", child:GetName())
                child:Layout(forceLayout)

                local childParent = child:GetParent()

                -- parent is view root
                if childParent == self then
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
                else
                    -- parent is blz widget, do nothing
                end
            end
        end

        function CheckLayoutParams(self, layoutParams)
            if not layoutParams then return true end

            return Struct.ValidateValue(ViewRoot.LayoutParams, layoutParams, true) and true or false
        end

        local function DoLayoutPass(self, forceLayout)
            print("DoLayoutPass")
            local widthMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, self:GetWidth() - self.MarginStart - self.MarginEnd)
            local heightMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, self:GetHeight() - self.MarginTop - self.MarginBottom)
            self:Measure(widthMeasureSpec, heightMeasureSpec, forceLayout)
            self:Layout(forceLayout)
            self:Refresh()
        end

        local function OnUpdate(self, elapsed)
            if self.__RequestLayoutFlag then
                DoLayoutPass(self, true)
                self.__RequestLayoutFlag = false
            end
        end

        -----------------------------------------
        --              Constructor            --
        -----------------------------------------
        function __ctor(self)
            super.__ctor(self)
            self.__RequestLayoutFlag = true
            self.OnUpdate = self.OnUpdate + OnUpdate
        end

        __Static__()
        function IsRootView(view)
            return view == ViewRoot.Default
        end

    end)

    Class "ViewRoot"(function()
                
        DefaultViewRoot = ViewRoot("MeowMeowViewRoot")
        DefaultViewRoot:SetAllPoints(UIParent)
        
        __Static__()
        property "Default" {
            set             = false,
            default         = DefaultViewRoot
        }

    end)

end)