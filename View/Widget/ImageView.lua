PLoop(function()

    namespace "SpaUI.Layout.Widget"
    import "SpaUI.Layout.View"

    -- Texture wrapper
    class "ImageView"(function()
        inherit "View"

        -- @Override
        function OnRefresh(self)
            self.__Texture:ClearAllPoints()
            self.__Texture:SetPoint("TOPLEFT", self, "TOPLEFT", self.PaddingStart, -self.PaddingTop)
            self.__Texture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.PaddingEnd, self.PaddingBottom)
        end

        --------------------------------------------------
        --             Texture functions                --
        --------------------------------------------------

        __Arguments__{ NEString/nil }
        function SetMaskTexture(self, maskName)
            self.__Texture:SetMask(maskName)
        end

        __Arguments__{ MaskTexture }
        function RemoveMaskTexture(self, texture)
            self.__Texture:RemoveMaskTexture(texture)
        end

        __Arguments__{ NaturalNumber }
        function GetMaskTexure(self, index)
            return self.__Texture:GetMaskTexure(index)
        end

        __Arguments__{ MaskTexture }
        function AddMaskTexture(self, maskTexure)
            self.__Texture:AddMaskTexture(maskTexure)
        end

        __Arguments__{ GradientType }
        function SetGradientAlpha(self, gradientType)
            self.__Texture:SetGradient(gradientType.orientation, gradientType.mincolor.r, gradientType.mincolor.g, gradientType.mincolor.b, gradientType.mincolor.a, gradientType.maxcolor.r, gradientType.maxcolor.g, gradientType.maxcolor.b, gradientType.maxcolor.a)
        end

        __Arguments__{ Orientation, ColorFloat, ColorFloat, ColorFloat, ColorFloat, ColorFloat, ColorFloat, ColorFloat, ColorFloat }
        function SetGradientAlpha(self, orientation, minR, minG, minB, minA, maxR, maxG, maxB, maxA)
            self.__Texture:SetGradient(orientation, minR, minG, minB, minA, maxR, maxG, maxB, maxA)
        end

        __Arguments__{ GradientType }
        function SetGradient(self, gradientType)
            self.__Texture:SetGradient(gradientType.orientation, gradientType.mincolor.r, gradientType.mincolor.g, gradientType.mincolor.b, gradientType.maxcolor.r, gradientType.maxcolor.g, gradientType.maxcolor.b)
        end

        __Arguments__{ Orientation, ColorFloat, ColorFloat, ColorFloat, ColorFloat, ColorFloat, ColorFloat }
        function SetGradient(self, orientation, minR, minG, minB, maxR, maxG, maxB)
            self.__Texture:SetGradient(orientation, minR, minG, minB, maxR, maxG, maxB)
        end

        __Arguments__{ ColorType }
        function SetColorTexture(self, color)
            self.__Texture:SetColorTexture(color.r, color.g, color.b, color.a)
        end

        __Arguments__{ ColorFloat, ColorFloat, ColorFloat, ColorFloat/nil }
        function SetColorTexture(self, r, g, b, a)
            self.__Texture:SetColorTexture(r, g, b, a)
        end

        function IsSnappingToPixelGrid(self)
            return self.__Texture:IsSnappingToPixelGrid()
        end

        __Arguments__{ Boolean }
        function SetSnapToPixelGrid(self, snapToPixelGrid)
            self.__Texture:SetSnapToPixelGrid(snapToPixelGrid)
        end

        function GetVertTile(self)
            return self.__Texture:GetVertTile()
        end

        __Arguments__{ Boolean }
        function SetVertTile(self, vertTile)
            self.__Texture:SetVertTile(vertTile)
        end

        __Arguments__{ NaturalNumber }
        function GetVertexOffset(self, vertexIndex)
            return self.__Texture:GetVertexOffset(vertexIndex)
        end

        __Arguments__{ NaturalNumber, Number, Number }
        function SetVertexOffset(self, vertexIndex, offsetX, offsetY)
            self.__Texture:SetVertexOffset(vertexIndex, offsetX, offsetY)
        end

        __Arguments__{ NaturalNumber, Dimension }
        function SetVertexOffset(self, vertexIndex, offset)
            self.__Texture:SetVertexOffset(vertexIndex, offset.x, offset.y)
        end

        function GetTextureFilePath(self)
            return self.__Texture:GetTextureFilePath()
        end

        function GetTextureFileID(self)
            return self.__Texture:GetTextureFileID()
        end

        function GetTexture(self)
            return self.__Texture:GetTexture()
        end

        __Arguments__{ (NEString + Number)/nil, WrapMode/nil, WrapMode/nil, FilterMode/nil }
        function SetTexture(self, file, horizWrap, vertWrap, filterMode)
            self.__Texture:SetTexture(file, horizWrap, vertWrap, filterMode)
        end

        function GetTexelSnappingBias(self)
            return self.__Texture:GetTexelSnappingBias()
        end

        __Arguments__{ Number }
        function SetTexelSnappingBias(self, snappingBias)
            self.__Texture:SetTexelSnappingBias(snappingBias)
        end

        function GetBlendMode(self)
            return self.__Texture:GetBlendMode()
        end

        __Arguments__{ AlphaMode }
        function SetBlendMode(self, mode)
            self.__Texture:SetBlendMode(mode)
        end

        function GetTexCoord(self)
            return self.__Texture:GetTexCoord()
        end

        __Arguments__{ RectType }
        function SetTexCoord(self, rect)
            if not val.ULx then
                self.__Texture:SetTexCoord(rect.left, rect.right, rect.top, rect.bottom)
            else
                self.__Texture:SetTexCoord(rect.ULx, rect.ULy, rect.LLx, rect.LLy, rect.URx, rect.URy, rect.LRx, rect.LRy)
            end
        end

        __Arguments__{ Number, Number }
        function SetTexCoord(self, ulx, uly, llx, lly, urx, ury, lrx, lry)
            self.__Texture:SetTexCoord(ulx, uly, llx, lly, urx, ury, lrx, lry)
        end

        function GetRotation(self)
            return self.__Texture:GetRotation()
        end

        __Arguments__{ Number, Number/nil, Number/nil }
        function SetRotation(self, radians, cx, cy)
            self.__Texture:SetRotation(radians, cx, cy)
        end

        function GetNumMaskTextures(self)
            return self.__Texture:GetNumMaskTextures()
        end

        function GetNonBlocking(self)
            return self.__Texture:GetNonBlocking()
        end

        __Arguments__{ Boolean }
        function SetNonBlocking(self, nonBlocking)
            self.__Texture:SetNonBlocking(nonBlocking)
        end

        function GetHorizTile(self)
            return self.__Texture:GetHorizTile()
        end

        __Arguments__{ Boolean }
        function SetHorizTile(self, horizTile)
            self.__Texture:SetHorizTile(horizTile)
        end
        
        function GetDesaturation(self)
            return self.__Texture:GetDesaturation()
        end

        __Arguments__{ ColorFloat }
        function SetDesaturation(self, desaturation)
            return self.__Texture:SetDesaturation(desaturation)
        end

        function IsDesaturated(self)
            return self.__Texture:IsDesaturated()
        end

        __Arguments__{ Boolean }
        function SetDesaturated(self, desaturated)
            return self.__Texture:SetDesaturated(desaturated)
        end

        function GetAtlas(self)
            return self.__Texture:GetAtlas()
        end

        __Arguments__{ AtlasType }
        function SetAtlas(self, atlas)
            self.__Texture:SetAtlas(atlas.atlas, atlas.useAtlasSize)
        end

        __Arguments__{ NEString/nil, Boolean/nil, FilterMode/nil }
        function SetAtlas(self, atlasName, useAtlasSize, filterMode)
            self.__Texture:SetAtlas(atlasName, useAtlasSize, filterMode)
        end

        function GetDrawLayer(self)
            return self.__Texture:GetDrawLayer()
        end

        __Arguments__{ DrawLayer, Integer/nil }
        function SetDrawLayer(self, layer, subLevel)
            self.__Texture:SetDrawLayer(layer, subLevel)
        end

        function GetVertexColor(self)
            return self.__Texture:GetVertexColor()
        end

        __Arguments__{ ColorType/Color.WHITE }
        function SetVertexColor(self, color)
            self.__Texture:SetVertexColor(color.r, color.g, color.b, color.a)
        end

        __Arguments__{ ColorFloat, ColorFloat, ColorFloat, ColorFloat/nil }
        function SetVertexColor(self, r, g, b, a)
            self.__Texture:SetVertexColor(r, g, b, a)
        end

        ------------------------------------------
        --               Constructor            --
        ------------------------------------------

        function __ctor(self)
            self.__Texture = Texture("__ImageView_Texture", self)
        end
        
    end)

    --------------------------------------------------------------------
    --                Properties, copy from Scorpio.UI                --
    --------------------------------------------------------------------

    do
        UI = Scorpio.UI

        local _Texture_Deps = { "Color", "Atlas", "FileID", "File" }
        local _HWrapMode    = setmetatable({}, META_WEAKKEY)
        local _VWrapMode    = setmetatable({}, META_WEAKKEY)
        local _FilterMode   = setmetatable({}, META_WEAKKEY)
    
        --- the atlas setting of the texture
        UI.Property         {
            name            = "Atlas",
            type            = AtlasType,
            require         = ImageView,
            get             = function(self) return AtlasType(self:GetAtlas()) end,
            set             = function(self, val) self:SetAtlas(val.atlas, val.useAtlasSize) end,
            clear           = function(self) self:SetAtlas(nil) end,
            override        = { "Color", "FileID", "File" },
        }
    
        --- the alpha mode of the texture
        UI.Property         {
            name            = "AlphaMode",
            type            = AlphaMode,
            require         = ImageView,
            default         = "BLEND",
            get             = function(self) return self:GetBlendMode() end,
            set             = function(self, val) self:SetBlendMode(val) end,
            depends         = _Texture_Deps,
        }
    
        --- the texture's color
        UI.Property         {
            name            = "Color",
            type            = ColorType,
            require         = ImageView,
            set             = function(self, color) self:SetColorTexture(color.r, color.g, color.b, color.a) end,
            clear           = function(self) self:SetTexture(nil) end,
            override        = { "Atlas", "FileID", "File" },
        }
    
        --- whether the texture image should be displayed with zero saturation
        UI.Property         {
            name            = "Desaturated",
            type            = Boolean,
            require         = ImageView,
            default         = false,
            get             = function(self) return self:IsDesaturated() end,
            set             = function(self, val) self:SetDesaturated(val) end,
            depends         = _Texture_Deps,
        }
    
        --- The texture's desaturation
        UI.Property         {
            name            = "Desaturation",
            type            = ColorFloat,
            require         = { Texture, Line, Model },
            default         = 0,
            get             = function(self) return self:GetDesaturation() end,
            set             = function(self, val) self:SetDesaturation(val) end,
            depends         = _Texture_Deps,
        }
    
        --- The wrap behavior specifying what should appear when sampling pixels with an x coordinate outside the (0, 1) region of the texture coordinate space.
        UI.Property         {
            name            = "HWrapMode",
            type            = WrapMode,
            require         = ImageView,
            default         = "CLAMP",
            get             = function(self) return _HWrapMode[self] or "CLAMP" end,
            set             = function(self, val) if val == "CLAMP" then val = nil end _HWrapMode[self] = val end,
        }
    
        --- Wrap behavior specifying what should appear when sampling pixels with a y coordinate outside the (0, 1) region of the texture coordinate space
        UI.Property         {
            name            = "VWrapMode",
            require         = ImageView,
            type            = WrapMode,
            default         = "CLAMP",
            get             = function(self) return _VWrapMode[self] or "CLAMP" end,
            set             = function(self, val) if val == "CLAMP" then val = nil end _VWrapMode[self] = val end,
        }
    
        --- Texture filtering mode to use
        UI.Property         {
            name            = "FilterMode",
            require         = ImageView,
            type            = FilterMode,
            default         = "LINEAR",
            get             = function(self) return _FilterMode[self] or "LINEAR" end,
            set             = function(self, val) if val == "LINEAR" then val = nil end _FilterMode[self] = val end,
        }
    
        --- Whether the texture is horizontal tile
        UI.Property         {
            name            = "HorizTile",
            type            = Boolean,
            require         = ImageView,
            default         = false,
            get             = function(self) return self:GetHorizTile() end,
            set             = function(self, val) self:SetHorizTile(val) end,
        }
    
        --- Whether the texture is vertical tile
        UI.Property         {
            name            = "VertTile",
            require         = ImageView,
            type            = Boolean,
            default         = false,
            get             = function(self) return self:GetVertTile() end,
            set             = function(self, val) self:SetVertTile(val) end,
        }
    
        --- The gradient color shading for the texture
        UI.Property         {
            name            = "Gradient",
            type            = GradientType,
            require         = ImageView,
            set             = function(self, val) self:SetGradient(val.orientation, val.mincolor.r, val.mincolor.g, val.mincolor.b, val.maxcolor.r, val.maxcolor.g, val.maxcolor.b) end,
            clear           = function(self) self:SetGradient("HORIZONTAL", 1, 1, 1, 1, 1, 1) end,
            depends         = _Texture_Deps,
        }
    
        --- The gradient color shading (including opacity in the gradient) for the texture
        UI.Property         {
            name            = "GradientAlpha",
            type            = GradientType,
            require         = ImageView,
            set             = function(self, val) self:SetGradientAlpha(val.orientation, val.mincolor.r, val.mincolor.g, val.mincolor.b, val.mincolor.a, val.maxcolor.r, val.maxcolor.g, val.maxcolor.b, val.maxcolor.a) end,
            clear           = function(self) self:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, 1, 1, 1, 1) end,
            depends         = _Texture_Deps,
        }
    
        --- whether the texture object loads its image file in the background
        UI.Property         {
            name            = "NonBlocking",
            type            = Boolean,
            require         = ImageView,
            default         = false,
            get             = function(self) return self:GetNonBlocking() end,
            set             = function(self, val) self:SetNonBlocking(val) end,
        }
    
        --- The rotation of the texture
        UI.Property         {
            name            = "Rotation",
            type            = Number,
            require         = { Texture, Line, Cooldown },
            default         = 0,
            get             = function(self) return self:GetRotation() end,
            set             = function(self, val) self:SetRotation(val) end,
            depends         = _Texture_Deps,
        }
    
        --- whether snap to pixel grid
        UI.Property         {
            name            = "SnapToPixelGrid",
            type            = Boolean,
            require         = ImageView,
            default         = false,
            get             = function(self) return self:IsSnappingToPixelGrid() end,
            set             = function(self, val) self:SetSnapToPixelGrid(val) end,
            depends         = _Texture_Deps,
        }
    
        --- the texel snapping bias
        UI.Property         {
            name            = "TexelSnappingBias",
            type            = Number,
            require         = ImageView,
            default         = 0,
            get             = function(self) return self:GetTexelSnappingBias() end,
            set             = function(self, val) self:SetTexelSnappingBias(val) end,
            depends         = _Texture_Deps,
        }
    
        --- The corner coordinates for scaling or cropping the texture image
        UI.Property         {
            name            = "TexCoords",
            type            = RectType,
            require         = ImageView,
            get             = function(self) local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = self:GetTexCoord() if URx then return { ULx = ULx, ULy = ULy, LLx = LLx, LLy = LLy, URx = URx, URy = URy, LRx = LRx, LRy = LRy } elseif ULx then return { left = ULx, right = ULy, top = LLx, bottom = LLy } end end,
            set             = function(self, val) if not val.ULx then self:SetTexCoord(val.left, val.right, val.top, val.bottom) else self:SetTexCoord(val.ULx, val.ULy, val.LLx, val.LLy, val.URx, val.URy, val.LRx, val.LRy) end end,
            clear           = function(self) self:SetTexCoord(0, 1, 0, 1) end,
            depends         = { "Color", "Atlas", "FileID", "File" },
        }
    
        --- The texture file id
        UI.Property         {
            name            = "FileID",
            type            = Number,
            require         = ImageView,
            get             = function(self) return self:GetTextureFileID() end,
            set             = function(self, val) self:SetTexture(val, _HWrapMode[self], _VWrapMode[self], _FilterMode[self]) end,
            clear           = function(self) self:SetTexture(nil) end,
            override        = { "Atlas", "Color", "File" },
            depends         = { "HWrapMode", "VWrapMode", "FilterMode" },
        }
    
        --- The texture file path
        UI.Property         {
            name            = "File",
            type            = String + Number,
            require         = ImageView,
            get             = function(self) return self:GetTextureFilePath() end,
            set             = function(self, val) self:SetTexture(val, _HWrapMode[self], _VWrapMode[self], _FilterMode[self]) end,
            clear           = function(self) self:SetTexture(nil) end,
            override        = { "Atlas", "Color", "FileID" },
            depends         = { "HWrapMode", "VWrapMode", "FilterMode" },
        }
    
        --- The mask file path
        UI.Property         {
            name            = "Mask",
            type            = String,
            require         = ImageView,
            set             = function(self, val) self:SetMask(val) end,
            nilable         = true,
            depends         = _Texture_Deps,
        }
    
        --- The vertex offset of upperleft corner
        UI.Property         {
            name            = "VertexOffsetUpperLeft",
            type            = Dimension,
            require         = ImageView,
            get             = function(self) return Dimension(self:GetVertexOffset(VertexIndexType.UpperLeft)) end,
            set             = function(self, val) self:SetVertexOffset(VertexIndexType.UpperLeft, val.x, val.y) end,
            clear           = function(self) self:SetVertexOffset(VertexIndexType.UpperLeft, 0, 0) end,
            depends         = _Texture_Deps,
        }
    
        --- The vertex offset of lowerleft corner
        UI.Property         {
            name            = "VertexOffsetLowerLeft",
            type            = Dimension,
            require         = ImageView,
            get             = function(self) return Dimension(self:GetVertexOffset(VertexIndexType.LowerLeft)) end,
            set             = function(self, val) self:SetVertexOffset(VertexIndexType.LowerLeft, val.x, val.y) end,
            clear           = function(self) self:SetVertexOffset(VertexIndexType.LowerLeft, 0, 0) end,
            depends         = _Texture_Deps,
        }
    
        --- The vertex offset of upperright corner
        UI.Property         {
            name            = "VertexOffsetUpperRight",
            type            = Dimension,
            require         = ImageView,
            get             = function(self) return Dimension(self:GetVertexOffset(VertexIndexType.UpperRight)) end,
            set             = function(self, val) self:SetVertexOffset(VertexIndexType.UpperRight, val.x, val.y) end,
            clear           = function(self) self:SetVertexOffset(VertexIndexType.UpperRight, 0, 0) end,
            depends         = _Texture_Deps,
        }
    
        --- The vertex offset of lowerright corner
        UI.Property         {
            name            = "VertexOffsetLowerRight",
            type            = Dimension,
            require         = ImageView,
            get             = function(self) return Dimension(self:GetVertexOffset(VertexIndexType.LowerRight)) end,
            set             = function(self, val) self:SetVertexOffset(VertexIndexType.LowerRight, val.x, val.y) end,
            clear           = function(self) self:SetVertexOffset(VertexIndexType.LowerRight, 0, 0) end,
            depends         = _Texture_Deps,
        }
    end

end)