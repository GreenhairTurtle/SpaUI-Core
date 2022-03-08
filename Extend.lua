PLoop(function()

    __Sealed__()
    struct "System.NonNegativeNumber" {
        __base          = Number,
        __valid         = function(val, onlyValid)
            return val < 0 and (onlyValid or "the %s must be a non negative number") or nil
        end
    }

end)