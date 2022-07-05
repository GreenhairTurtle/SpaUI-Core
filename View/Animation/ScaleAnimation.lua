PLoop(function()

    class "ScaleAnimation"(function()
        inherit "ViewAnimation"

        -- @Override
        function Apply(self, interpolatedTime, transformation)
            transformation.scale = self.__FromScale + (self.__ToScale - self.__FromScale) * interpolatedTime
        end

        function __ctor(self, fromScale, toScale)
            super.__ctor(self)
            self.__FromScale = fromScale or 1
            self.__ToScale = toScale or 0
        end

    end)

end)