PLoop(function()
    
    namespace "KittyBox.Layout"

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
            return cos(((input + 1) * math.pi) / 2) + 0.5
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

end)