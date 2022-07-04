PLoop(function()

    namespace "MeowMeow.Layout"

    -- Note:Do not constructor this class, it can only has an instance which is ViewManager.ViewRoot
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
                    print(self:GetName(), "OnMeasure")
                    child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, usedWidth, child.Width, child.MaxWidth),
                        IView.GetChildMeasureSpec(heightMeasureSpec, usedHeight, child.Height, child.MaxHeight))
                else
                    widthMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, math.max(childParent:GetWidth() - marginStart - marginEnd, 0))
                    heightMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, math.max(childParent:GetHeight() - marginTop - marginBottom, 0))
                    child:Measure(IView.GetChildMeasureSpec(widthMeasureSpec, 0, child.Width, child.MaxWidth),
                        IView.GetChildMeasureSpec(heightMeasureSpec, 0, child.Height, child.MaxHeight))
                end
            end

            self:SetMeasuredSize(specWidth, specHeight)
        end

        function OnLayout(self)
            local paddingStart, paddingTop, paddingEnd, paddingBottom = self.PaddingStart, self.PaddingTop, self.PaddingEnd, self.PaddingBottom
            local width, height = self:GetSize()
            local widthAvaliable = width - paddingStart - paddingEnd
            local heightAvaliable = height - paddingTop - paddingBottom

            for _, child in self:GetNonGoneChilds() do
                child:Layout()

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

        -- @Override
        function RequestLayout(self)
            ViewManager.Scheduler:LayoutPass()
        end

        function CheckLayoutParams(self, layoutParams)
            if not layoutParams then return true end

            return Struct.ValidateValue(ViewRoot.LayoutParams, layoutParams, true) and true or false
        end

        __Static__()
        function IsRootView(view)
            return view and view == ViewManager.ViewRoot
        end

        -----------------------------------------
        --              Constructor            --
        -----------------------------------------

        function __ctor(self)
            super.__ctor(self)
            self:RequestLayout()
        end

    end)

    -- This scheduler handles the timing pulse that is shared by all all views, animations, etc.
    -- Schedule to do layout pass, animate and all other components which need time scheduling 
    class "ViewScheduler" (function()
        inherit "Frame"
        
        function LayoutPass(self)
            self.__RequestLayoutFlag = true
        end

        function AddAnimation(self, animation)
            tinsert(self.__Animations, animation)
        end

        function RemoveAnimation(self, animation)
            tremove(self.__Animations, animation)
        end

        local function DoLayoutPass(self)
            print("DoLayoutPass")
            local root = ViewManger.ViewRoot
            local widthMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, root:GetWidth() - root.MarginStart - root.MarginEnd)
            local heightMeasureSpec = MeasureSpec.MakeMeasureSpec(MeasureSpec.EXACTLY, root:GetHeight() - root.MarginTop - root.MarginBottom)
            root:Measure(widthMeasureSpec, heightMeasureSpec)
            root:Layout()
            root:Refresh()
        end

        local function OnUpdate(self, elapsed)
            if self.__RequestLayoutFlag then
                DoLayoutPass(self)
                self.__RequestLayoutFlag = false
            end
        end

        function __ctor(self)
            self.__RequestLayoutFlag = false
            self.__Animations = {}
            self.OnUpdate = self.OnUpdate + OnUpdate
        end

    end)

    Class "ViewManager"(function()

        -- create scheduler
        DefaultViewScheduler = ViewScheduler("MeowMeowViewScheduler")

        -- create view root
        DefaultViewRoot = ViewRoot("MeowMeowViewRoot")
        DefaultViewRoot:SetAllPoints(UIParent)
        
        __Static__()
        property "ViewRoot" {
            set             = false,
            default         = DefaultViewRoot
        }

        property "Scheduler"{
            set             = false,
            default         = DefaultViewScheduler
        }

    end)

end)