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

end)