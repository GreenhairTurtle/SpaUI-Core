PLoop(function()

    namespace "MeowMeow.Layout"

    class "ViewAnimation"(function()

        -- Animation repeat mode
        __Sealed__()
        __AutoIndex__()
        enum "RepeatMode" {
            "RESTART",
            "REVERSE"
        }
    
        property "Duration"     {
            type                = NonNegativeNumber,
            require             = true,
            default             = 1.5
        }

        property "RepeatCount"  {
            type                = NonNegativeNumber,
            require             = true,
            default             = 1
        }

        property "RepeatMode"   {
            type                = RepeatMode,
            require             = true,
            default             = RepeatMode.RESTART
        }

        property "Interpolator" {
            type                = Interpolator,
            require             = true,
            default             = AccelerateInterpolator()
        }

        __Arguments__{ IView }
        function Attach(self, view)
            self.__View = view
        end

        function Dettach(self)
            self:Reset()
        end

        function Reset(self)
            self.__View = nil
            self.__TargetTime = 0
            self.__Stoped = false
        end

        __Final__()
        __Async__()
        function Start(self)
            self.__Stoped = false
            self.__StartTime = GetTime()
            self.__TargetTime = ceil(self.__StartTime + self.Duration)

            while not self.__Stoped and GetTime() < self.__TargetTime do
                local progress = (GetTime() - self.__StartTime) / self.Duration
                progress = max(0, min(progress, 1))
                local interpolatedTime = self.Interpolator:GetInterpolation(progress)
                self:Apply(interpolatedTime)
                
                Next()
            end
        end

        __Abstract__()
        function Stop(self)
            self.__Stoped = true
        end

        -- interpolatedTime – The value of the normalized time (0 to 1) after it has been run through the interpolation function.
        __Abstract__()
        function Apply(self, interpolatedTime)
        end

    end)

    -- Alpha animation
    class "AlphaAnimation"(function()
        inherit "ViewAnimation"
    
        __Arguments__{ NonNegativeNumber, NonNegativeNumber }
        function SetAlpha(self, from, to)
            self.__FromAlpha = min(from, 1)
            self.__ToAlpha = min(to, 1)
        end

        function Apply(self, interpolatedTime)
            local alpha = self.__FromAlpha + (self.__ToAlpha - self.__FromAlpha) * interpolatedTime
            self.__View:SetAlpha(alpha)
        end

    end)

    interface "ILayoutAnimation"(function()

        -----------------------------------------
        --              Propertys              --
        -----------------------------------------


    end)

end)