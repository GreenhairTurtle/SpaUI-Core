PLoop(function()

    namespace "SpaUI.Layout.Widget"
    import "SpaUI.Layout.View"
    import "SpaUI.Layout"

    -- FontString wrapper
    class "TextView"(function()
        inherit "View"

        -- @Override
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            self.__FontString:ClearAllPoints()

            local padding = self.Padding
            local widthMode = MeasureSpec.GetMode(widthMeasureSpec)
            local width = math.max(MeasureSpec.GetSize(widthMeasureSpec) - padding.left - padding.right, 0)
            local heightMode = MeasureSpec.GetMode(heightMeasureSpec)
            local height = math.max(MeasureSpec.GetSize(heightMeasureSpec) - padding.top - padding.bottom, 0)
            local measuredWidth
            local measuredHeight

            if widthMode == MeasureSpec.EXACTLY then
                self.__FontString:SetWidth(width)
                measuredWidth = width
                
                if heightMode == MeasureSpec.EXACTLY then
                    measuredHeight = height
                elseif heightMode == MeasureSpec.AT_MOST then
                    self.__FontString:SetHeight(0)
                    measuredHeight = math.min(self.__FontString:GetStringHeight(), height)
                else
                    self.__FontString:SetHeight(0)
                    measuredHeight = self.__FontString:GetStringHeight()
                end
            elseif widthMode == MeasureSpec.AT_MOST then
                -- Width can use its own size, but has a limit width
                self.__FontString:SetWidth(0)
                measuredWidth = math.min(self.__FontString:GetUnboundedStringWidth(), width)

                if heightMode == MeasureSpec.EXACTLY then
                    -- Height is determined
                    measuredHeight = height
                elseif heightMode == MeasureSpec.AT_MOST then
                    -- Height can use its own size, also has a limit height
                    self.__FontString:SetWidth(measuredWidth)
                    self.__FontString:SetHeight(0)
                    measuredHeight = math.min(self.__FontString:GetStringHeight(), height)
                else
                    self.__FontString:SetWidth(measuredWidth)
                    self.__FontString:SetHeight(0)
                    measuredHeight = self.__FontString:GetStringHeight()
                end
            else
                -- Width can be whatever size it wants
                self.__FontString:SetWidth(0)
                measuredWidth = self.__FontString:GetUnboundedStringWidth()

                if heightMode == MeasureSpec.EXACTLY then
                    -- Height is determined
                    measuredHeight = height
                elseif heightMode == MeasureSpec.AT_MOST then
                    -- Height can use its own size, also has a limit height
                    self.__FontString:SetHeight(0)
                    measuredHeight = math.min(self.__FontString:GetStringHeight(), height)
                else
                    self.__FontString:SetHeight(0)
                    measuredHeight = self.__FontString:GetStringHeight()
                end
            end

            measuredWidth = math.max(measuredWidth + padding.left + padding.right, self.MinWidth)
            measuredHeight = math.max(measuredHeight + padding.top + padding.bottom, self.MinHeight)

            self:SetMeasuredSize(measuredWidth, measuredHeight)
        end

        function OnLayout(self)
            self.__FontString:SetWidth(0)
            self.__FontString:SetHeight(0)
        end
        
        local function reverseText(text)
            return XList(UTF8Encoding.Decodes(text)):Map(UTF8Encoding.Encode):Reverse()
        end

        -- @Override
        function OnRefresh(self)
            local padding = self.Padding
            self.__FontString:SetPoint("TOPLEFT", self, "TOPLEFT", padding.left, -padding.top)
            self.__FontString:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -padding.right, padding.bottom)
            self.__FontString:SetText(self.__OriginText)
        end


        --------------------------------------------------
        --          FontString functions                --
        --------------------------------------------------

        __Arguments__{ String/nil }
        function SetText(self, text)
            self.__OriginText = text
            self:RequestLayout()
        end

        function GetText(self)
            return self.__OriginText or ""
        end

        -- @todo
        function SetFormattedText(self, text, ...)
            self.__OriginText = string.format(text, ...)
            self:RequestLayout()
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
            self:RequestLayout()
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
            self:RequestLayout()
        end

        function GetLineHeight(self)
            return self.__FontString:GetLineHeight()
        end

        __Arguments__{ Number }
        function SetTextHeight(self, height)
            self.__FontString:SetTextHeight(height)
            self:RequestLayout()
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
            self:RequestLayout()
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
            self:RequestLayout()
        end

        __Arguments__{ Number, Number }
        function SetShadowOffset(self, offsetX, offsetY)
            self.__FontString:SetShadowOffset(offsetX, offsetY)
            self:RequestLayout()
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
            self:RequestLayout()
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
            self:RequestLayout()
        end

        function GetFont(self)
            return self.__FontString:GetFont()
        end

        __Arguments__{ NEString, Number, NEString/nil }
        function SetFont(self, path, size, flags)
            self.__FontString:SetFont(path, size, flags)
            self:RequestLayout()
        end

        function GetFontObject(self)
            return self.__FontString:GetFontObject()
        end

        __Arguments__{ FontObject }
        function SetFontObject(self, fontObject)
            self.__FontString:SetFontObject(fontObject)
            self:RequestLayout()
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
        --              Propertys               --
        ------------------------------------------
        
        property "TextReverse"      {
            type                    = Boolean,
            default                 = false,
            handler                 = OnTextReverseChanged
        }

        property "TextOrientation"  {
            type                    = Orientation,
            default                 = Orientation.HORIZONTAL,
            handler                 = OnTextOrientationChanged
        }

        ------------------------------------------
        --               Constructor            --
        ------------------------------------------

        function __ctor(self)
            self.__FontString = FontString("__TextView_FontString", self)
        end

    end)


end)