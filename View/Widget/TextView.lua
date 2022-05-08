PLoop(function()

    namespace "KittyBox.Layout.Widget"
    import "KittyBox.Layout.View"
    import "KittyBox.Layout"

    -- FontString wrapper
    class "TextView"(function()
        inherit "View"

        -- @Override
        function OnMeasure(self, widthMeasureSpec, heightMeasureSpec)
            self.__FontString:ClearAllPoints()

            local paddingStart, paddingEnd, paddingTop, paddingBottom = self.PaddingStart, self.PaddingEnd, self.PaddingTop, self.PaddingEnd
            local widthMode = MeasureSpec.GetMode(widthMeasureSpec)
            local width = math.max(MeasureSpec.GetSize(widthMeasureSpec) - paddingStart - paddingEnd, 0)
            local heightMode = MeasureSpec.GetMode(heightMeasureSpec)
            local height = math.max(MeasureSpec.GetSize(heightMeasureSpec) - paddingTop - paddingBottom, 0)
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

            measuredWidth = math.max(measuredWidth + paddingStart + paddingEnd, self.MinWidth)
            measuredHeight = math.max(measuredHeight + paddingTop + paddingBottom, self.MinHeight)
            self:SetMeasuredSize(measuredWidth, measuredHeight)
        end

        function OnLayout(self)
            self.__FontString:SetWidth(0)
            self.__FontString:SetHeight(0)
        end
        
        -- @Override
        function OnRefresh(self)
            self.__FontString:SetPoint("TOPLEFT", self, "TOPLEFT", self.PaddingStart, -self.PaddingTop)
            self.__FontString:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.PaddingEnd, self.PaddingBottom)
        end

        --------------------------------------------------
        --          FontString functions                --
        --------------------------------------------------

        __Arguments__{ String/nil }
        function SetText(self, text)
            self.__OriginText = text
            self.__FontString:SetText(text)
            self:RequestLayout()
        end

        function GetText(self)
            return self.__OriginText or ""
        end

        function SetFormattedText(self, text, ...)
            self.__OriginText = string.format(text, ...)
            self.__FontString:SetText(text)
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
        --               Constructor            --
        ------------------------------------------

        function __ctor(self)
            self.__FontString = FontString("__TextView_FontString", self)
        end

    end)

    --------------------------------------------------------------------
    --                Properties, copy from Scorpio.UI                --
    --------------------------------------------------------------------

    do
        UI = Scorpio.UI

        --- the layer at which the LayeredFrame's graphics are drawn relative to others in its frame
        UI.Property         {
            name            = "DrawLayer",
            type            = DrawLayer,
            require         = TextView,
            default         = "ARTWORK",
            get             = function(self) return self:GetDrawLayer() end,
            set             = function(self, layer) return self:SetDrawLayer(layer) end,
        }
    
        --- the color shading for the LayeredFrame's graphics
        UI.Property         {
            name            = "VertexColor",
            type            = ColorType,
            require         = TextView,
            default         = Color.WHITE,
            get             = function(self) if self.GetVertexColor then return Color(self:GetVertexColor()) end end,
            set             = function(self, color) self:SetVertexColor(color.r, color.g, color.b, color.a) end,
        }
    
        UI.Property         {
            name            = "SubLevel",
            type            = Integer,
            require         = TextView,
            default         = 0,
            depends         = { "DrawLayer" },
            get             = function(self) return select(2, self:GetDrawLayer()) end,
            set             = function(self, sublevel) self:SetDrawLayer(self:GetDrawLayer(), sublevel) end,
        }

        --- the font settings
        UI.Property         {
            name            = "Font",
            type            = FontType,
            require         = TextView,
            get             = function(self)
                local filename, fontHeight, flags   = self:GetFont()
                local outline, monochrome           = "NONE", false
                if flags then
                    if flags:find("THICKOUTLINE") then
                        outline         = "THICK"
                    elseif flags:find("OUTLINE") then
                        outline         = "NORMAL"
                    end
                    if flags:find("MONOCHROME") then
                        monochrome      = true
                    end
                end
                return FontType(filename, fontHeight, outline, monochrome)
            end,
            set             = function(self, font)
                local flags

                if font.outline then
                    if font.outline == "NORMAL" then
                        flags           = "OUTLINE"
                    elseif font.outline == "THICK" then
                        flags           = "THICKOUTLINE"
                    end
                end
                if font.monochrome then
                    if flags then
                        flags           = flags..",MONOCHROME"
                    else
                        flags           = "MONOCHROME"
                    end
                end
                return self:SetFont(font.font, font.height, flags)
            end,
            override        = { "FontObject" },
        }

        --- the Font object
        UI.Property         {
            name            = "FontObject",
            type            = FontObject,
            require         = TextView,
            get             = function(self) return self:GetFontObject() end,
            set             = function(self, fontObject) self:SetFontObject(fontObject) end,
            override        = { "Font" },
        }

        --- the fontstring's horizontal text alignment style
        UI.Property         {
            name            = "JustifyH",
            type            = JustifyHType,
            require         = TextView,
            default         = "CENTER",
            get             = function(self) return self:GetJustifyH() end,
            set             = function(self, justifyH) self:SetJustifyH(justifyH) end,
        }

        --- the fontstring's vertical text alignment style
        UI.Property         {
            name            = "JustifyV",
            type            = JustifyVType,
            require         = TextView,
            default         = "MIDDLE",
            get             = function(self) return self:GetJustifyV() end,
            set             = function(self, justifyV) self:SetJustifyV(justifyV) end,
        }

        --- the color of the font's text shadow
        UI.Property         {
            name            = "ShadowColor",
            type            = Color,
            require         = TextView,
            default         = Color(0, 0, 0, 0),
            get             = function(self) return Color(self:GetShadowColor()) end,
            set             = function(self, color) self:SetShadowColor(color.r, color.g, color.b, color.a) end,
        }

        --- the offset of the fontstring's text shadow from its text
        UI.Property         {
            name            = "ShadowOffset",
            type            = Dimension,
            require         = TextView,
            default         = Dimension(0, 0),
            get             = function(self) return Dimension(self:GetShadowOffset()) end,
            set             = function(self, offset) self:SetShadowOffset(offset.x, offset.y) end,
        }

        --- the fontstring's amount of spacing between lines
        UI.Property         {
            name            = "Spacing",
            type            = Number,
            require         = TextView,
            default         = 0,
            get             = function(self) return self:GetSpacing() end,
            set             = function(self, spacing) self:SetSpacing(spacing) end,
        }

        --- the fontstring's default text color
        UI.Property         {
            name            = "TextColor",
            type            = Color,
            require         = TextView,
            default         = Color(1, 1, 1),
            get             = function(self) return Color(self:GetTextColor()) end,
            set             = function(self, color) self:SetTextColor(color.r, color.g, color.b, color.a) end,
        }

        --- whether the text wrap will be indented
        UI.Property         {
            name            = "Indented",
            type            = Boolean,
            require         = TextView,
            default         = false,
            get             = function(self) return self:GetIndentedWordWrap() end,
            set             = function(self, flag) self:SetIndentedWordWrap(flag) end,
        }
    end
end)