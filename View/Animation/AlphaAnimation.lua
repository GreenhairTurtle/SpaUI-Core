PLoop(function()

    namespace "MeowMeow.Layout"

    class "AlphaAnimation"(function()
        inherit "ViewAnimation"

        -- @Override
        function Apply(self, interpolatedTime, transformation)
            transformation.alpha = self.__FromAlpha + (self.__ToAlpha - self.__FromAlpha) * interpolatedTime
        end

        function __ctor(self, fromAlpha, toAlpha)
            super.__ctor(self)
            self.__FromAlpha = fromAlpha or 1
            self.__ToAlpha = toAlpha or 0
        end

    end)

end)