PLoop(function()

    namespace "SpaUI.Widget.Layout"
    import "SpaUI.Widget"

    export {
        tinsert         = table.insert,
        tremove         = table.remove,
        tDeleteItem     = tDeleteItem,
        tContains       = tContains,
        math            = math
    }

    -------------------------------
    --          ViewGroup        --
    -------------------------------

    -- Subclass need to implement the following functions:
    -- 1. OnMeasure
    -- 2. OnLayout

    -- For more details, see method comment
    class "ViewGroup"(function()
        inherit "Frame"

        local wrapContentLayoutParams = LayoutParams(SizeMode.WRAP_CONTENT, SizeMode.WRAP_CONTENT)

        -- @Override
        __Final__()
        function SetWidth(self, width)
            error("You can not call SetWidth directly in ViewGroup. Call SetLayoutParams instead", 2)
        end

        -- @Override
        __Final__()
        function SetHeight(self, height)
            error("You can not call SetHeight directly in ViewGroup. Call SetLayoutParams instead", 2)
        end

        -- @Override
        __Final__()
        function SetSize(self, width, height)
            error("You can not call SetSize directly in ViewGroup. Call SetLayoutParams instead", 2)
        end

        -- Call this function instead SetSize, only internal use
        __Final__()
        __Arguments__{ NonNegativeNumber, NonNegativeNumber }
        function SetSizeInternal(self, width, height)
            super.SetSize(self, width, height)
        end

        local function OnChildShow(child)
            local parent = child:GetParent()
            if parent then
                parent:Refresh()
            end
        end

        local function OnChildHide(child)
            local parent = child:GetParent()
            if parent then
                parent:Refresh()
            end
        end

        local function OnChildSizeChanged(child)
            local layoutParams = child:GetLayoutParams()
            -- only refresh when child layout params's width or height <=0
            if layoutParams and layoutParams.width <= 0 or layoutParams.height <= 0 then
                local parent = child:GetParent()
                if parent then
                    parent:Refresh()
                end
            end
        end

        -- add size changed and visible changed script to texture and fontstring
        local function AddScriptToTextureAndFontString(child)
            child.__Original_SetWidth = child.SetWidth
            child.__Original_SetHeight = child.SetHeight
            child.__Original_SetSize = child.SetSize
            child.__Original_Show = child.Show
            child.__Original_Hide = child.Hide
            child.__Original_SetShown = child.SetShown

            -- replace size function
            child.SetWidth = function(self, width)
                if width ~= self:GetWidth() then
                    self.__Original_SetWidth(self, width)
                    OnChildSizeChanged(self)
                end
            end

            child.SetHeight = function(self, height)
                if height ~= self:GetHeight() then
                    self.__Original_SetHeight(self, height)
                    OnChildSizeChanged(self)
                end
            end

            child.SetSize = function(self, width, height)
                if width ~= self:GetWidth() or height ~= self:GetHeight() then
                    self.__Original_SetSize(self, width, height)
                    OnChildSizeChanged(self)
                end
            end

            -- replace visibility function
            child.Show = function(self)
                if not self:IsShown() then
                    self.__Original_Show(self)
                    OnChildShow(self)
                end
            end

            child.Hide = function(self)
                if self:IsShown() then
                    self.__Original_Hide(self)
                    OnChildHide(self)
                end
            end

            child.SetShown = function(self, shown)
                local current = self:IsShown()
                if shown ~= current then
                    self.__Original_SetShown(self, shown)
                    if current then
                        OnChildHide(self)
                    else
                        OnChildShow(self)
                    end
                end
            end
        end

        local function RemoveScriptToTextureAddFontString(child)
            child.SetWidth = child.__Original_SetWidth
            child.SetHeight = child.__Original_SetHeight
            child.SetSize = child.__Original_SetSize
            child.Show = child.__Original_Show
            child.Hide = child.__Original_Hide
            child.SetShown = child.__Original_SetShown
        end

        local function AddScriptToFontString(child)
            child.__Original_SetText = child.SetText
            child.__Original_SetFormattedText = child.SetFormattedText
            child.__Original_SetMaxLines = child.SetMaxLines
            child.__Original_SetTextScale = child.SetTextScale
            child.__Original_SetTextHeight = child.SetTextHeight
            child.__Original_SetWordWrap = child.SetWordWrap
            child.__Original_SetSpacing = child.SetSpacing
            child.__Original_SetFontObject = child.SetFontObject
            child.__Original_SetFont = child.SetFont

            child.SetText = function(self, text)
                local originalText = self:GetText()
                if originalText ~= text then
                    self.__Original_SetText(self, text)
                    OnChildSizeChanged(self)
                end
            end

            child.SetFormattedText = function(self, format, ...)
                self.__Original_SetFormattedText(self, format, ...)
                OnChildSizeChanged(self)
            end

            child.SetMaxLines = function(self, maxLines)
                local originalMaxLines = self:GetMaxLines()
                if originalMaxLines ~= maxLines then
                    self.__Original_SetMaxLines(self, maxLines)
                    OnChildSizeChanged(self)
                end
            end

            child.SetTextScale = function(self, textScale)
                local originalTextScale = self:GetTextScale()
                if originalTextScale ~= textScale then
                    self.__Original_SetTextScale(self, textScale)
                    OnChildSizeChanged(self)
                end
            end

            child.SetTextHeight = function(self, textHeight)
                self.__Original_SetTextHeight(self, textHeight)
                OnChildSizeChanged(self)
            end

            child.SetWordWrap = function(self, wordWrap)
                local originalWordWrap = self:CanWordWrap()
                if originalWordWrap ~= wordWrap then
                    self.__Original_SetWordWrap(self, wordWrap)
                    OnChildSizeChanged(self)
                end
            end

            child.SetSpacing = function(self, spacing)
                local originalSpacing = self:GetSpacing()
                if originalSpacing ~= spacing then
                    self.__Original_SetSpacing(self, spacing)
                    OnChildSizeChanged(self)
                end
            end

            child.SetFontObject = function(self, ...)
                child.__Original_SetFontObject(self, ...)
                OnChildSizeChanged(self)
            end

            child.SetFont = function(self, ...)
                child.__Original_SetFont(self, ...)
                OnChildSizeChanged(self)
            end
        end

        local function RemoveScriptToFontString(child)
            child.__Original_SetText            = child.SetText
            child.__Original_SetFormattedText   = child.SetFormattedText
            child.__Original_SetMaxLines        = child.SetMaxLines
            child.__Original_SetTextScale       = child.SetTextScale
            child.__Original_SetTextHeight      = child.SetTextHeight
            child.__Original_SetWordWrap        = child.SetWordWrap
            child.__Original_SetSpacing         = child.SetSpacing
            child.__Original_SetFontObject      = child.SetFontObject
            child.__Original_SetFont            = child.SetFont
        end

        local function OnChildAdded(self, child)
            child = UI.GetWrapperUI(child)
            child:ClearAllPoints()
            child:SetParent(self)

            if not ViewGroup.IsViewGroup(child) then
                child.SetLayoutParams = ViewGroup.SetLayoutParams
                child.GetLayoutParams = ViewGroup.GetLayoutParams
                child.SetVisibility = ViewGroup.SetVisibility
                child.GetVisibility = ViewGroup.GetVisibility
            end

            if Class.ValidateValue(Frame, child, true) then
                child:SetFrameStrata(self:GetFrameStrata())
                child:SetFrameLevel(self:GetFrameLevel() + 1)
                child.OnShow = child.OnShow + OnChildShow
                child.OnHide = child.OnHide + OnChildHide
                child.OnSizeChanged = child.OnSizeChanged + OnChildSizeChanged
            end

            if Class.ValidateValue(Texture, child, true) then
                AddScriptToTextureAndFontString(child)
            end

            if Class.ValidateValue(FontString, child, true) then
                AddScriptToTextureAndFontString(child)
                AddScriptToFontString(child)
            end
        end

        local function OnChildRemoved(self, child)
            child = UI.GetWrapperUI(child)
            child.SetLayoutParams = nil
            child.OnShow = child.OnShow - OnChildShow
            child.OnHide = child.OnHide - OnChildHide
            child.OnSizeChanged = child.OnSizeChanged - OnChildSizeChanged

            if not ViewGroup.IsViewGroup(child) then
                child.SetLayoutParams = nil
                child.GetLayoutParams = nil
                child.SetVisibility = nil
                child.GetVisibility = nil
            end

            if Class.ValidateValue(Texture, child, true) then
                RemoveScriptToTextureAddFontString(child)
            end

            if Class.ValidateValue(FontString, child, true) then
                RemoveScriptToTextureAddFontString(child)
            end
        end

        __Final__()
        __Arguments__{ LayoutFrame, LayoutParams/nil, NaturalNumber/nil }:Throwable()
        function AddChild(self, child, layoutParams, index)
            if tContains(self.__Children, child) then
                throw("The child has already been added")
            end

            if not index then
                index = #self.__Children + 1
            end

            OnChildAdded(self, child)
            tinsert(self.__Children, index, child)

            -- SetLayoutParams function has installed in OnChildAdded
            child:SetLayoutParams(layoutParams or child:GetLayoutParams())
        end

        -- Remove child by name
        __Final__()
        __Arguments__{ NEString }
        function RemoveChild(self, childName)
            local child = self:GetChild(childName)
            if not child then return end

            self:RemoveChild(child)
        end

        -- Remove child by obj
        __Final__()
        __Arguments__{ LayoutFrame }
        function RemoveChild(self, child)
            if child:GetParent() == self then
                tDeleteItem(self.__Children, child)
                OnChildRemoved(self, child)
                child:SetParent(nil)
                self:Refresh()
            end
        end

        -- Call this function to set width
        -- @param width: see LayoutParams.width
        __Arguments__{ NonNegativeNumber + SizeMode }
        function SetLayoutWidth(self, width)
            local layoutParams = self:GetLayoutParams()
            layoutParams.width = width
            self:Refresh()
        end

        -- Call this function to set height
        -- @param height: see LayoutParams.height
        __Arguments__{ NonNegativeNumber + SizeMode }
        function SetLayoutHeight(self, height)
            local layoutParams = self:GetLayoutParams()
            layoutParams.height = height
            self:Refresh()
        end

        -- Call this function to set size
        -- @param width: see LayoutParams.width
        -- @param height: see LayoutParams.height
        __Arguments__{ NonNegativeNumber + SizeMode, NonNegativeNumber + SizeMode }
        function SetLayoutSize(self, width, height)
            local layoutParams = self:GetLayoutParams()
            layoutParams.width = width
            layoutParams.height = height
            self:Refresh()
        end

        __Arguments__{ Size }
        function SetLayoutSize(self, size)
            self:SetLayoutSize(size.width, size.height)
        end

        -------------------------------------
        --        Universal functions      --
        -------------------------------------

        -- will copy to child
        __Arguments__{ LayoutParams/nil }
        function SetLayoutParams(self, layoutParams)
            self.__LayoutParams = layoutParams
            -- if not viewgroup and parent is viewgroup, call parent's refresh
            if not ViewGroup.IsViewGroup(self) then
                local parent = self:GetParent()
                if ViewGroup.IsViewGroup(parent) then
                    parent:Refresh()
                end
            else
                self:Refresh()
            end
        end

        -- will copy to child
        function GetLayoutParams(self)
            if not self.__LayoutParams then
                self.__LayoutParams = Toolset.clone(wrapContentLayoutParams, true)
            end
            return self.__LayoutParams
        end

        -- will copy to child
        __Arguments__{ Visibility }
        function SetVisibility(self, visibility)
            self.__Visibility = visibility
            if visibility == Visibility.VISIBLE then
                self:Show()
            else
                self:Hide()
            end
        end

        -- will copy to child
        function GetVisibility(self)
            local shown = self:IsShown()
            if shown then
                self.__Visibility = Visibility.VISIBLE
            else
                -- not shown
                if self.__Visibility == Visibility.VISIBLE then
                    self.__Visibility = Visibility.GONE
                end
            end

            if not self.__Visibility then
                self.__Visibility = shown and Visibility.VISIBLE or Visibility.GONE
            end

            return self.__Visibility
        end

        -------------------------------------
        --     Universal functions end     --
        -------------------------------------

        -- check is refreshing now
        __Final__()
        function IsRefreshing(self)
            local parent = self:GetParent()
            if parent and ViewGroup.IsViewGroup(parent) then
                return parent:IsRefreshing()
            end

            return self.__Refresh
        end

        __Final__()
        __Arguments__{ Boolean }
        function SetRefreshStatus(self, isRefresh)
            self.__Refresh = isRefresh
        end

        __Final__()
        function Refresh(self)
            -- reduce multi call when layout
            -- because child OnSizeChanged maybe call multi times in OnMeasure
            if self:IsRefreshing() then
                return
            end
            self:SetRefreshStatus(true)

            local layoutParams = self:GetLayoutParams()
            local parent = self:GetParent()
            local inViewGroup = parent and ViewGroup.IsViewGroup(parent)
            -- if self or parent size is unspecified, so call parent's refresh function and stop further processing
            if inViewGroup then
                local parentLp = parent:GetLayoutParams()
                if  (layoutParams.width <= 0 or layoutParams.height <= 0
                        or parentLp.width <= 0 or parentLp.height <= 0) then
                    return parent:Refresh()
                end
            end

            -- must be the topest viewgroup whose size needs to be changed now.

            -- generate measure spec

            local widthMeasureSpec, heightMeasureSpec
            -- calc width
            if layoutParams.width == SizeMode.WRAP_CONTENT then
                -- width wrap content means no view group parent
                widthMeasureSpec = MeasureSpec(MeasureSpecMode.UNSPECIFIED)
            elseif layoutParams.width == SizeMode.MATCH_PARENT then
                if inViewGroup then
                    widthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, parent:GetWidth())
                else
                    widthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, self:GetWidth())
                end
            else
                widthMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, layoutParams.width)
            end

            -- calc height
            if layoutParams.width == SizeMode.WRAP_CONTENT then
                -- height wrap content means no view group parent
                heightMeasureSpec = MeasureSpec(MeasureSpecMode.UNSPECIFIED)
            elseif layoutParams.height == SizeMode.MATCH_PARENT then
                if inViewGroup then
                    heightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, parent:GetHeight())
                else
                    heightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, self:GetHeight())
                end
            else
                heightMeasureSpec = MeasureSpec(MeasureSpecMode.AT_MOST, layoutParams.height)
            end

            local newWidth, newHeight = self:Measure(widthMeasureSpec, heightMeasureSpec)
            self:SetSizeInternal(newWidth, newHeight)
            self:Layout()
        end

        __Final__()
        function Layout(self)
            for _, child in ipairs(self.__Children) do
                if (ViewGroup.IsViewGroup(child)) then
                    child:Layout()
                end
            end
            if self:GetVisibility() ~= Visibility.GONE and #self.__Children > 0 then
                self:OnLayout()
            end
            -- clear refresh status
            self:SetRefreshStatus(false)
        end

        -- Implement this function to layout child position
        -- The size of the viewgroup is determined when this function is called
        -- You can call LayoutChild function to layout child
        __Abstract__()
        function OnLayout(self)
        end

        -- Call this function to layout child. This function will automatically calculate the positions corresponding to different layoutdirections
        __Arguments__{ LayoutFrame, Number, Number }
        function LayoutChild(self, child, xOffset, yOffset)
            local direction = self.LayoutDirection
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
        end

        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        -- Return width and height
        __Final__()
        __Arguments__{ MeasureSpec, MeasureSpec }:Throwable()
        function Measure(self, widthMeasureSpec, heightMeasureSpec)
            local width, height = 0, 0
            if self:GetVisibility() ~= Visibility.GONE then
                width, height = self:OnMeasure(widthMeasureSpec, heightMeasureSpec)
                if type(width) ~= "number" or type(height) ~= "number" then
                    throw("ViewGroup's size must be number")
                end
            end
            return width, height
        end

        -- Implement this function to measure viewgroup and child size, return view group size
        -- Note: Please call MeasureChild function to get child correct size!
        -- Note: You must call SetChildSize function to set child size!
        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        __Abstract__()
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
        end

        -- Measure child size
        -- @param widthMeasureSpec: horizontal space requirements as imposed by the parent.
        -- @param heightMeasureSpec: vertical space requirements as imposed by the parent
        -- @return child measure width and height
        __Final__()
        __Arguments__{ LayoutFrame, MeasureSpec, MeasureSpec }
        function MeasureChild(self, child, widthMeasureSpec, heightMeasureSpec)
            if ViewGroup.IsViewGroup(child) then
                return child:Measure(widthMeasureSpec, heightMeasureSpec)
            else
                if child:GetVisibility() == Visibility.GONE then
                    return 0, 0
                end

                local childLayoutParams = child:GetLayoutParams()

                local width, height
                -- calc width
                if childLayoutParams.width >= 0 then
                    width = childLayoutParams.width
                elseif childLayoutParams.width == SizeMode.MATCH_PARENT then
                    if widthMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        width = LayoutParams.GetPrefWidth(child, childLayoutParams)
                    else
                        width = widthMeasureSpec.size
                    end
                else
                    -- wrap content
                    if widthMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        width = LayoutParams.GetPrefWidth(child, childLayoutParams)
                    else
                        width = math.min(childLayoutParams.prefWidth, widthMeasureSpec.size)
                    end
                end

                -- calc height
                if childLayoutParams.height >= 0 then
                    height = childLayoutParams.height
                elseif childLayoutParams.height == SizeMode.MATCH_PARENT then
                    if heightMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        height = LayoutParams.GetPrefHeight(child, childLayoutParams)
                    else
                        height = heightMeasureSpec.size
                    end
                else
                    -- wrap content
                    if heightMeasureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                        height = LayoutParams.GetPrefHeight(child, childLayoutParams)
                    else
                        height = math.min(childLayoutParams.prefHeight, heightMeasureSpec.size)
                    end
                end

                return width, height
            end
        end

        -- Get measure size, max size, child measurespec mode
        -- measure size, max size will be nil.
        -- if measure size has value, means parent's size is not determined by childs.
        -- if max size has value, means child is wrap_content but has max size limit
        -- @param measureSpec: self measuresepc
        -- @param orientation: horizontal or vertical, correspond layoutParams width or height
        __Arguments__{ MeasureSpec, Orientation }
        function GetMeasureSizeAndChildMeasureSpec(self, measureSpec, orientation)
            local size, mode, measureSize, maxSize
            local layoutParams = self:GetLayoutParams()
            if orientation == Orientation.VERTICAL then
                size = layoutParams.height
            else
                size = layoutParams.width
            end
            
            -- we respect view group declared size
            if size >= 0 then
                measureSize = size
                mode = MeasureSpecMode.AT_MOST
            elseif size == SizeMode.MATCH_PARENT then
                if measureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                    mode = MeasureSpecMode.UNSPECIFIED
                else
                    -- if measurespec mode is EXACTLY, we also set child measurespec mode AT_MOST,
                    -- you can override this function to implement yourself
                    measureSize = measureSpec.size
                    mode = MeasureSpecMode.AT_MOST
                end
            else
                -- wrap content
                if measureSpec.mode == MeasureSpecMode.UNSPECIFIED then
                    mode = MeasureSpecMode.UNSPECIFIED
                elseif measureSpec.mode == MeasureSpecMode.AT_MOST then
                    maxSize = measureSpec.size
                    mode = MeasureSpecMode.AT_MOST
                else
                    -- if measurespec mode is EXACTLY, we also set child measurespec mode AT_MOST,
                    -- you can override this function to implement yourself
                    measureSize = measureSpec.size
                    mode = MeasureSpecMode.AT_MOST
                end
            end

            if not maxSize and measureSize then
                maxSize = measureSize
            end

            return measureSize, maxSize, mode
        end

        __Arguments__{ LayoutFrame, NonNegativeNumber, NonNegativeNumber }
        function SetChildSize(self, child, width, height)
            if ViewGroup.IsViewGroup(child) then
                child:SetSizeInternal(width, height)
            else
                child:SetSize(width, height)
            end
        end

        __Arguments__{ NonNegativeNumber/nil, NonNegativeNumber/nil, NonNegativeNumber/nil, NonNegativeNumber/nil }
        function SetPadding(self, left, top, right, bottom)
            local padding = self.Padding
            padding.left = left or padding.left
            padding.top = top or padding.top
            padding.right = right or padding.right
            padding.bottom = bottom or padding.bottom
            self:Refresh()
        end

        __Arguments__{ NonNegativeNumber/nil, NonNegativeNumber/nil, NonNegativeNumber/nil, NonNegativeNumber/nil }
        function SetMargin(self, left, top, right, bottom)
            local margin = self:GetLayoutParams().margin
            margin.left = left or margin.left
            margin.top = top or margin.top
            margin.right = right or margin.right
            margin.bottom = bottom or margin.bottom
            self:Refresh()
        end

        -- Check object is view group
        __Static__()
        function IsViewGroup(viewGroup)
            return Class.ValidateValue(ViewGroup, viewGroup, true) and true or false
        end

        function __ctor(self)
            self.__Children = {}
        end

        property "Padding"      {
            type                = Padding,
            require             = true,
            default             = Padding(0),
            handler             = "Refresh"
        }

        property "LayoutDirection"{
            type                = LayoutDirection,
            default             = LayoutDirection.LEFT_TO_RIGHT + LayoutDirection.TOP_TO_BOTTOM,
            handler             = function(self)
                self:Layout()
            end
        }

    end)

end)