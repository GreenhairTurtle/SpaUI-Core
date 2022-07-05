-- copied from android
PLoop(function()
    
    namespace "MeowMeow.Layout"

    -- A time interpolator defines the rate of change of an animation. This allows animations to have non-linear motion, such as acceleration and deceleration.
    interface "Interpolator"(function()
        
        -- Maps a value representing the elapsed fraction of an animation to a value that represents the interpolated fraction. This interpolated value is then multiplied by the change in value of an animation to derive the animated value at the current elapsed animation time.
        -- Params:input – A value between 0 and 1.0 indicating our current point in the animation where 0 represents the start and 1.0 represents the end
        -- Returns:The interpolation value. This value can be more than 1.0 for interpolators which overshoot their targets, or less than 0 for interpolators that undershoot their targets.
        __Arguments__{ Number }
        function GetInterpolation(self, input)
        end

    end)

    -- An interpolator where the rate of change starts out slowly and and then accelerates.
    class "AccelerateInterpolator"(function()
        extend "Interpolator"
        
        -- Constructor
        -- Params:factor – Degree to which the animation should be eased. Seting factor to 1.0f produces a y=x^2 parabola. Increasing factor above 1.0f exaggerates the ease-in effect (i.e., it starts even slower and ends evens faster)
        __Arguments__{ Number/1 }
        function __ctor(self, factor)
            self.__factor = factor
            self.__doubleFactor = 2 * factor
        end

        function GetInterpolation(self, input)
            if self.__factor == 1 then
                return input * input
            else
                return input ^ self.__doubleFactor
            end
        end

    end)

    -- An interpolator where the rate of change starts and ends slowly but accelerates through the middle
    class "AccelerateDecelerateInterpolator"(function()
        extend "Interpolator"
        
        function GetInterpolation(self, input)
            return math.cos(((input + 1) * math.pi) / 2) + 0.5
        end

    end)

    -- An interpolator where the rate of change starts out quickly and and then decelerates.
    class "DecelerateInterpolator"(function()
        extend "Interpolator"
    
        -- Params:factor – Degree to which the animation should be eased. Setting factor to 1.0f produces an upside-down y=x^2 parabola. Increasing factor above 1.0f exaggerates the ease-out effect (i.e., it starts even faster and ends evens slower).
        __Arguments__{ Number/1 }
        function __ctor(self, factor)
            self.__factor = factor
        end

        function GetInterpolation(self, input)
            if self.__factor == 1 then
                return 1 - (1 - input) * (1 - input)
            else
                return 1 - (1 - input) ^ (2 * self.__factor)
            end
        end

    end)

    -- An interpolator where the change starts backward then flings forward
    class "AnticipateInterpolator"(function()
        extend "Interpolator"

        __Arguments__{ Number/2 }
        function __ctor(self, tension)
            self.__Tension = tension
        end

        function GetInterpolation(self, input)
            return input * input * ((self.__Tension + 1) * input - self.__Tension)
        end

    end)

    -- An interpolator where the change starts backward then flings forward and overshoots the target value and finally goes back to the final value.
    class "AnticipateOvershootInterpolator"(function()
        extend "Interpolator"

        __Arguments__{ Number/2 }
        function __ctor(self, tension)
            self.__Tension = tension * 1.5
        end

        local function a(t, s)
            return t * t * ((s + 1) * t - s)
        end

        local function o(t, s)
            return t * t * ((s + 1) * t + s)
        end

        function GetInterpolation(self, input)
            -- a(t, s) = t * t * ((s + 1) * t - s)
            -- o(t, s) = t * t * ((s + 1) * t + s)
            -- f(t) = 0.5 * a(t * 2, tension * extraTension), when t < 0.5
            -- f(t) = 0.5 * (o(t * 2 - 2, tension * extraTension) + 2), when t <= 1.0
            if input < 0.5 then 
                return 0.5 * a(input * 2, self.__Tension)
            else
                return 0.5 * (o(input * 2 - 2, self.__Tension) + 2)
            end
        end

    end)

    -- An interpolator where the change bounces at the end.
    class "BounceInterpolator"(function()
        extend "Interpolator"

        local function bounce(t)
            return t * t * 8
        end

        function GetInterpolation(self, input)
            -- _b(t) = t * t * 8
            -- bs(t) = _b(t) for t < 0.3535
            -- bs(t) = _b(t - 0.54719) + 0.7 for t < 0.7408
            -- bs(t) = _b(t - 0.8526) + 0.9 for t < 0.9644
            -- bs(t) = _b(t - 1.0435) + 0.95 for t <= 1.0
            -- b(t) = bs(t * 1.1226)
            input = input * 1.1226
            if (input < 0.3535) then
                return bounce(input)
            elseif input < 0.7408 then
                return bounce(input - 0.54719) + 0.7
            elseif (input < 0.9644) then
                return bounce(input - 0.8526) + 0.9
            else
                return bounce(input - 1.0435) + 0.95
            end
        end

    end)

    -- Repeats the animation for a specified number of cycles. The rate of change follows a sinusoidal pattern.
    class "CycleInterpolator"(function()
        extend "Interpolator"

        __Arguments__{ Number }
        function __ctor(self, cycles)
            self.__Cycles = cycles
        end

        function GetInterpolation(self, input)
            return math.sin(2 * self.__Cycles * math.pi * input)
        end

    end)

    -- An interpolator where the rate of change is constant
    class "LinearInterpolator"(function()
        extend "Interpolator"
        
        function GetInterpolation(self, input)
            return input
        end

    end)

end)