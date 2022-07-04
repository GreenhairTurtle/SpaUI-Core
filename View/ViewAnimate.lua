PLoop(function()

    namespace "MeowMeow.Layout"

    -- This class defined some base animation(alpha, size, scale or translate)'s base class
    -- Note: This class is lightweight to do view animation, that means it does not call request layout when animating
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
            default             = AccelerateDecelerateInterpolator()
        }

        event "OnAnimationStart"
        event "OnAnimationEnd"
        event "OnAnimationRepeat"

        -- Indicates that the animation was canceled
        START_TIME_CANCELED = -2147483648

        function Start(self)
            self:Reset()
            self:StartInternal()
        end

        function StartInternal(self)
            ViewManager.Scheduler:AddAnimation(self)
        end

        function CancelScheduler(self)
            ViewManager.Scheduler:RemoveAnimation(self)
        end

        -- Whether animation is running or not
        function IsRunning(self)
            return self.__Started and not self.__Ended
        end

        -- Cancel the animation
        function Cancel(self)
            if self.__Started and not self.__Ended then
                self.__Ended = true
                OnAnimationEnd(self)
            end
            self.__StartTime = START_TIME_CANCELED
        end

        -- Animation whether be canceled or not
        function IsCanceled(self)
            return self.__StartTime == START_TIME_CANCELED
        end

        function Reset(self)
            self.__StartTime = -1
            self.__Started = false
            self.__Ended = false
            self.__Repeated = 0
            self.__CycleFlip = false
        end

        function OnAnimate(self, currentTime)
            if self.__StartTime == -1 then
                self.__StartTime = currentTime
            end

            local progress = (currentTime - self.__StartTime) / self.Duration
            local canceled = self:IsCanceled()
            local expired = progress > 1 or canceled
            
            -- fire animation start
            if not self.__Started then
                OnAnimationStart(self)
                self.__Started = true
            end

            if not canceled then
                if progress < 0 then
                    progress = 0
                elseif progress > 1 then
                    progress = 1
                end
            
                -- if reverse
                if self.__CycleFlip then
                    progress = 1 - progress
                end

                local interpolatedTime = self.Interpolator:GetInterpolation(progress)
                self:Apply(interpolatedTime, self.__Transformation)
            end
            
            if expired then
                if self.__Repeated == self.RepeatCount or canceled then
                    if not self.__Ended then
                        self.__Ended = true
                        OnAnimationEnd(self)
                        self:EndInternal()
                    end
                else
                    -- repeat animation
                    if self.RepeatCount > 0 then
                        self.__Repeated = self.__Repeated + 1
                    end

                    if self.RepeatMode == RepeatMode.REVERSE then
                        self.__CycleFlip = not self.__CycleFlip
                    end

                    self.__StartTime = -1

                    OnAnimationRepeat(self)
                end
            end
        end

        -- interpolatedTime – The value of the normalized time (0 to 1) after it has been run through the interpolation function.
        -- transformation - modify this object to do view's animation
        __Abstract__()
        function Apply(self, interpolatedTime, transformation)

        end

        -- Get animation transformation, will be used by view to do animation
        function GetTransformation(self)
            return self.__Transformation
        end

        function __ctor(self)
            self:Reset()
        end

    end)

end)