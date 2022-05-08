PLoop(function()

    namespace "KittyBox.Layout"

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

        function AnimToOpaque(self)
            self:SetAlpha(0, 1)
            self:Start()
        end

        function AnimToTransparent(self)
            self:SetAlpha(self.__View:GetAlpha(), 0)
            self:Start()
        end

        function Apply(self, interpolatedTime)
            local alpha = self.__FromAlpha + (self.__ToAlpha - self.__FromAlpha) * interpolatedTime
            self.__View:SetAlpha(alpha)
        end

    end)

    interface "IViewAnimate"(function()

        function CancelAnims(self)
            if self.ShowAnimation then
                self.ShowAnimation:Stop()
            end
            if self.HideAnimation then
                self.HideAnimation:Stop()
            end
            if self.SizeAnimation then
                self.SizeAnimation:Stop()
            end
            if self.AlphaAnimation then
                self.AlphaAnimation:Stop()
            end
            if self.MoveAnimation then
                self.MoveAnimation:Stop()
            end
        end

        function AnimateShow(self)
            if self.HideAnimation then
                self.HideAnimation:Stop()
            end

            if self.ShowAnimation then
                self.ShowAnimation:AnimToOpaque()
            end
        end

        __Abstract__()
        function AnimateHide(self)
        end

        __Abstract__()
        function AnimateSize(self)
        end

        __Abstract__()
        function AnimateAlpha(self)
        end

        __Abstract__()
        function AnimateMove(self)
        end

        -----------------------------------------
        --              Propertys              --
        -----------------------------------------

        property "ShowAnimation"    {
            type                    = ViewAnimation,
            default                 = function(self)
                local anim = AlphaAnimation()
                anim:Attach(self)
                return anim
            end
        }

        property "HideAnimation"    {
            type                    = ViewAnimation,
            default                 = AlphaAnimation()
        }
        
    end)

end)