PLoop(function()

    namespace "SpaUI.Layout.Widget"
    import "SpaUI.Layout.View"

    -- FontString wrapper
    class "TextView"(function()
        inherit "View"

        -- @Override
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            self.__FontString:ClearAllPoints()

            local widthMode = widthMeasureSpec.Mode
            local width = widthMeasureSpec.Size
            local heightMode = heightMeasureSpec.Mode
            local height = heightMeasureSpec.Size
            local measuredWidth
            local measuredHeight

            if widthMode == MeasureSpecMode.EXACTLY then
                self.__FontString:SetWidth(width)
                measuredWidth = width
                
                if heightMode == MeasureSpecMode.EXACTLY then
                    measuredHeight = height
                elseif heightMode == MeasureSpecMode.AT_MOST then
                    self.__FontString:SetHeight(0)
                    measuredHeight = math.min(self.__FontString:GetStringHeight(), height)
                else
                    self.__FontString:SetHeight(0)
                    measuredHeight = self.__FontString:GetStringHeight()
                end
            elseif withMode == MeasueSpecMode.AT_MOST then
                -- Width can use its own size, but has a limit width
                self.__FontString:SetWidth(0)
                measuredWidth = math.min(self.__FontString:GetUnboundedStringWidth(), width)

                if heightMode == MeasureSpecMode.EXACTLY then
                    -- Height is determined
                    measuredHeight = height
                elseif heightMode == MeasureSpecMode.AT_MOST then
                    -- Height can use its own size, also has a limit height
                    self.__FontString:SetWidth(measuredWidth)
                    self.__FontString:SetHeight(0)
                    measuredHeight = math.min(self.__FontString:GetStringHeight(), height)
                else
                    self.__FontString:SetWidth(measuredHeight)
                    self.__FontString:SetHeight(0)
                    measuredHeight = self.__FontString:GetStringHeight()
                end
            else
                -- Width can be whatever size it wants
                self.__FontString:SetWidth(0)
                measuredWidth = self.__FontString:GetUnboundedStringWidth()

                if heightMode == MeasureSpecMode.EXACTLY then
                    -- Height is determined
                    measuredHeight = height
                elseif heightMode == MeasureSpecMode.AT_MOST then
                    -- Height can use its own size, also has a limit height
                    self.__FontString:SetHeight(0)
                    measuredHeight = math.min(self.__FontString:GetStringHeight(), height)
                else
                    self.__FontString:SetHeight(0)
                    measuredHeight = self.__FontString:GetStringHeight()
                end
            end

            self:SetMeasuredSize(measuredWidth, measuredHeight)
        end

        function OnLayout(self)
            self.__FontString:SetWidth(0)
            self.__FontString:SetHeight(0)
        end

        -- @Override
        function OnRefresh(self)
            local padding = self.Padding
            self.__FontString:SetPoint("TOPLEFT", self, "TOPLEFT", padding.left, -padding.top)
            self.__FontString:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -padding.right, padding.bottom)
        end

        -- @Override
        function GetPrefWidth(self)
            if self.PrefWidth >= 0 then
                return self.PrefWidth
            elseif self.PrefWidth == SizeMode.WRAP_CONTENT then
                return self.__FontString:GetWidth() + self.Padding.left + self.Padding.right
            else
                error(self:GetName() + "'s PrefWidth is invalid", 2)
            end
        end

        -- @Override
        function GetPrefHeight(self)
            if self.PrefHeight >= 0 then
                return self.PrefHeight
            elseif self.PrefHeight == SizeMode.WRAP_CONTENT then
                return self.__FontString:GetHeight() + self.Padding.top + self.Padding.bottom
            else
                error(self:GetName() + "'s PrefHeight is invalid", 2)
            end
        end

        -- Get minimum text width necessary when height is determined
        function GetWrapContentWidth(self, height)
            self.__FontString:ClearAllPoints()
            self.__FontString:SetHeight(height)
            self.__FontString:SetWidth(0)
            return self.__FontString:GetUnboundedStringWidth()
        end

        -- Get minimum text height necessary when width is determined
        function GetWrapContentHeight(self, width)
            self.__FontString:ClearAllPoints()
            self.__FontString:SetWidth(width)
            self.__FontString:SetHeight(0)
            return self.__FontString:GetStringHeight()
        end

        --------------------------------------------------
        --          FontString functions                --
        --------------------------------------------------

        -- @todo
        __Arguments__{ String/nil }
        function SetText(self, text)
            self.__FontString:SetText(text)
        end

        function GetText(self)
            return self.__FontString:GetText()
        end

        -- @todo
        function SetFormattedText(self, text, ...)
            self.__FontString:SetFormattedText(text, ...)
        end

        __Arguments__{ Number, Number }
        function SetAlphaGradient(self, start, length)
            self.__FontString:SetAlphaGradient(start, length)
        end

        function SetFixedColor(self, state)
            self.__FontString:SetFixedColor(state)
        end

        function CanWordWrap(self)
            return self.__FontString:CanWordWrap()
        end

        __Arguments__{ Boolean }
        function SetWordWrap(self, wrap)
            self.__FontString:SetWordWrap(wrap)
        end

        function GetTextScale(self)
            return self.__FontString:GetTextScale()
        end

        __Arguments__{ Number }
        function SetTextScale(self, scale)
            self.__FontString:SetTextScale(scale)
        end

        function IsTruncated(self)
            return self.__FontString:IsTruncated()
        end

        function GetWrappedWidth(self)
            return self.__FontString:GetWrappedWidth()
        end

        function GetUnboundedStringWidth(self)
            return self.__FontString:GetUnboundedStringWidth()
        end

        function GetStringWidth(self)
            return self.__FontString:GetStringWidth()
        end

        function GetStringHeight(self)
            return self.__FontString:GetStringHeight()
        end

        function GetNumLines(self)
            return self.__FontString:GetNumLines()
        end

        function GetMaxLines(self)
            return self.__FontString:GetMaxLines()
        end

        __Arguments__{ Number }
        function SetMaxLines(self, maxLines)
            self.__FontString:SetMaxLines(maxLines)
        end

        function GetLineHeight(self)
            return self.__FontString:GetLineHeight()
        end

        __Arguments__{ Number }
        function SetTextHeight(self, height)
            self.__FontString:SetTextHeight(height)
        end

        function GetFieldSize(self)
            return self.__FontString:GetFieldSize()
        end

        __Arguments__{ Number, Number }
        function FindCharacterIndexAtCoordinate(self, x, y)
            return self.__FontString:FindCharacterIndexAtCoordinate(x, y)
        end

        function CanNonSpaceWrap(self)
            return self.__FontString:CanNonSpaceWrap()
        end

        __Arguments__{ Boolean }
        function SetNonSpaceWrap(self, wrap)
            self.__FontString:SetNonSpaceWrap(wrap)
        end

        __Arguments__{ NaturalNumber, NaturalNumber }
        function CalculateScreenAreaFromCharacterSpan(self, leftCharacterIndex, rightCharacterIndex)
            return self.__FontString:CalculateScreenAreaFromCharacterSpan(leftCharacterIndex, rightCharacterIndex)
        end

        function GetTextColor(self)
            return self.__FontString:GetTextColor()
        end

        __Arguments__{ ColorType }
        function SetTextColor(self, color)
            self.__FontString:SetTextColor(color.r, color.g, color.b, color.a)
        end

        __Arguments__{ ColorFloat, ColorFloat, ColorFloat, ColorFloat/nil }
        function SetTextColor(self, r, g, b, a)
            self.__FontString:SetTextColor(r, g, b, a)
        end

        function GetShadowOffset(self)
            return self.__FontString:GetShadowOffset()
        end

        __Arguments__{ Dimension }
        function SetShadowOffset(self, offset)
            self.__FontString:SetShadowOffset(offset.x, offset.y)
        end

        __Arguments__{ Number, Number }
        function SetShadowOffset(self, offsetX, offsetY)
            self.__FontString:SetShadowOffset(offsetX, offsetY)
        end

        function GetShadowColor(self)
            return self.__FontString:GetShadowColor()
        end

        __Arguments__{ ColorType }
        function SetShadowColor(self, color)
            self.__FontString:SetShadowColor(color.r, color.g, color.b, color.a)
        end

        __Arguments__{ ColorFloat, ColorFloat, ColorFloat, ColorFloat/nil }
        function SetShadowColor(self, r, g, b, a)
            self.__FontString:SetShadowColor(r, g, b, a)
        end

        function GetSpacing(self)
            return self.__FontString:GetSpacing()
        end

        __Arguments__{ Number }
        function SetSpacing(self, spacing)
            self.__FontString:SetSpacing(spacing)
        end

        function GetJustifyV(self)
            return self.__FontString:GetJustifyV()
        end

        __Arguments__{ JustifyVType }
        function SetJustifyV(self, justifyV)
            self.__FontString:SetJustifyV(self, justifyV)
        end

        function GetJustifyH(self)
            return self.__FontString:GetJustifyH()
        end

        __Arguments__{ JustifyHType }
        function SetJustifyH(self, justifyH)
            self.__FontString:SetJustifyH(justifyH)
        end

        function GetIndentedWordWrap(self)
            return self.__FontString:GetIndentedWordWrap()
        end

        __Arguments__{ Boolean }
        function SetIndentedWordWrap(self, indented)
            self.__FontString:SetIndentedWordWrap(indented)
        end

        function GetFont(self)
            return self.__FontString:GetFont()
        end

        __Arguments__{ NEString, Number, NEString/nil }
        function SetFont(self, path, size, flags)
            self.__FontString:SetFont(path, size, flags)
        end

        function GetFontObject(self)
            return self.__FontString:GetFontObject()
        end

        __Arguments__{ FontObject }
        function SetFontObject(self, fontObject)
            self.__FontString:SetFontObject(fontObject)
        end

        function GetDrawLayer(self)
            return self.__FontString:GetDrawLayer()
        end

        __Arguments__{ DrawLayer, Integer/nil }
        function SetDrawLayer(self, layer, subLevel)
            self.__FontString:SetDrawLayer(layer, subLevel)
        end

        __Arguments__{ ColorType/Color.WHITE }
        function SetVertexColor(self, color)
            self.__FontString:SetVertexColor(color.r, color.g, color.b, color.a)
        end

        __Arguments__{ ColorFloat, ColorFloat, ColorFloat, ColorFloat/nil }
        function SetVertexColor(self, r, g, b, a)
            self.__FontString:SetVertexColor(r, g, b, a)
        end

        ------------------------------------------
        --               Constructor            --
        ------------------------------------------

        function __ctor(self)
            self.__FontString = FontString("__TextView_FontString", self)
        end

    end)


end)