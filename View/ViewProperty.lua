PLoop(function()
    
    namespace "SpaUI.Layout"

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
        -- left or right, depends on layout direction
        "START",
        -- right or left, depends on layout direction
        "END",
        "CENTER_HORIZONTAL",
        "CENTER_VERTICAL"
    }

    -- Layout direction
    __Sealed__()
    enum "LayoutDirection"{
        -- Top to bottom, left to right
        "TOPLEFT",
        "TOPRIGHT",
        "BOTTOMLEFT",
        "BOTTOMRIGHT"
    }

    -- Size mode
    __Sealed__()
    enum "SizeMode"{
        ["MATCH_PARENT"] = -1,
        ["WRAP_CONTENT"] = -2
    }

    struct "ViewSize" { __base = SizeMode + NonNegativeNumber }

    __Sealed__()
    __AutoIndex__()
    enum "Visibility"{
        -- This view is Shown
        "VISIBLE",
        -- This view is invisible, but it still takes up space for layout purposes
        "INVISIBLE",
        -- This view is hidden
        "GONE"
    }

    __Sealed__()
    interface "MeasureSpec"(function()

        local MODE_SHIFT = 30
        local MODE_MASK = bit.lshift(0x3, MODE_SHIFT)

        -- The parent has not imposed any constraint on the child.
        -- It can be whatever size it wants.
        __Static__()
        property "UNSPECIFIED" {
            default             = bit.lshift(0, MODE_SHIFT),
            set                 = false
        }

        -- The parent has determined an exact size for the child.
        -- The child is going to be given those bounds regardless of how big it wants to be.
        -- This situation is usually not considered.
        __Static__()
        property "EXACTLY"      {
            default             = bit.lshift(1, MODE_SHIFT),
            set                 = false
        }

        -- The child can be as large as it wants up to the specified size.
        __Static__()
        property "AT_MOST"      {
            default             = bit.lshift(2, MODE_SHIFT),
            set                 = false
        }

        local function checkModeValid(mode)
            return mode == MeasureSpec.UNSPECIFIED or mode == MeasureSpec.EXACTLY or mode == MeasureSpec.AT_MOST
        end

        __Static__()
        __Arguments__{ Number, NonNegativeNumber }:Throwable()
        function MakeMeasureSpec(mode, size)
            if not checkModeValid(mode) then
                throw("MeasureSpec's mode must be one of UNSPECIFIED, EXACTLY or AT_MOST")
            end
            return size + mode
        end

        -- only return UNSPECIFIED, AT_MOST or EXACTLY
        __Static__()
        __Arguments__{ Number }
        function GetSize(measureSpec)
            return bit.band(measureSpec, bit.bnot(MODE_MASK))
        end

        __Static__()
        __Arguments__{ Number }
        function GetMode(measureSpec)
            return bit.band(measureSpec, MODE_MASK)
        end

    end)

    __Sealed__()
    struct "LayoutParams" {}
    
end)