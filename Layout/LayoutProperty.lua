-- package.path = package.path .. ";D:/Github/?/init.lua;D:/Github/?.lua"
-- require "PLoop"
-- require "Extend"

PLoop(function()
    
    namespace "SpaUI.Widget"

    __Sealed__()
    struct "Padding"(function()

        member "left"   { Type = NonNegativeNumber, Require = true }
        member "top"    { Type = NonNegativeNumber }
        member "right"  { Type = NonNegativeNumber }
        member "bottom" { Type = NonNegativeNumber }

        -- If only pass 1 param, all padding values are this value
        __init  = function(value)
            if not value.top and not value.right and not value.bottom then
                value.top = value.left
                value.right = value.left
                value.bottom = value.left
            else
                value.top = value.top or 0
                value.right = value.right or 0
                value.bottom = value.bottom or 0
            end
        end
    end)

    __Sealed__()
    struct "Margin"(function()

        -- Margin value's type is number, so you can set it to negative
        -- May be useful in some scenarios
        member "left"   { Type = Number, Require = true }
        member "top"    { Type = Number }
        member "right"  { Type = Number }
        member "bottom" { Type = Number }

        -- If only pass 1 param, all margin values are this value
        __init  = function(value)
            if not value.top and not value.right and not value.bottom then
                value.top = value.left
                value.right = value.left
                value.bottom = value.left
            else
                value.top = value.top or 0
                value.right = value.right or 0
                value.bottom = value.bottom or 0
            end
        end

    end)

    -- Indicates the position of the child relative to the parent
    -- Can be combined arbitrarily, like Gravity.TOP + Gravity.START
    __Flags__()
    __Sealed__()
    enum "Gravity"{
        "TOP",
        "BOTTOM",
        "START",
        "END",
        "CENTER",
        "CENTER_HORIZONTAL",
        "CENTER_VERTICAL"
    }

    -- Layout direction
    -- Can be combined arbitrarily, like LEFT_TO_RIGHT + BOTTOM_TO_TOP
    __Flags__()
    __Sealed__()
    enum "LayoutDirection"{
        "LEFT_TO_RIGHT",
        "RIGHT_TO_LEFT",
        "TOP_TO_BOTTOM",
        "BOTTOM_TO_TOP"
    }

    -- Size mode
    __Sealed__()
    enum "SizeMode"{
        ["MATCH_PARENT"] = -1,
        ["WRAP_CONTENT"] = -2
    }

    -- A MeasureSpec encapsulates the layout requirements passed from parent to child.
    -- Each MeasureSpec represents a requirement for either the width or the height.
    -- A MeasureSpec is comprised of a size and a mode. There are three possible modes:
    __Sealed__()
    __AutoIndex__()
    enum "MeasureSpecMode"{
        -- The parent has not imposed any constraint on the child.
        -- It can be whatever size it wants.
        UNSPECIFIED,
        -- The parent has determined an exact size for the child.
        -- The child is going to be given those bounds regardless of how big it wants to be.
        -- This situation is usually not considered.
        EXACTLY,
        -- The child can be as large as it wants up to the specified size.
        AT_MOST
    }

    -- MeasureSpecMode and width/height struct
    __Sealed__()
    struct "MeasureSpec"(function()

        member "mode"   { Type = MeasureSpecMode,   Require = true }
        member "size"   { Type = NonNegativeNumber }

        __valid = function(self, value)
            if value.mode ~= MeasureSpecMode.UNSPECIFIED and not value.size then
                return "%s.size can not be nil"
            end
        end
        
    end)

    __Sealed__()
    struct "LayoutParams"(function()

        member "width"  { Type = NonNegativeNumber + SizeMode, Require = true }
        member "height" { Type = NonNegativeNumber + SizeMode, Require = true }
        member "margin" { Type = Margin }

    end)
    
end)