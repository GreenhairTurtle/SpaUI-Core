PLoop(function()

    namespace "SpaUI.Layout.Widget"
    import "SpaUI.Layout.View"

    -- FontString wrapper
    class "TextView"(function()
        inherit "View"

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
            self.__FontString:SetAllPoints(self)
        end

    end)


end)