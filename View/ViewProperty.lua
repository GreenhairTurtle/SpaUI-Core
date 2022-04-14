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

    -- A MeasureSpec encapsulates the layout requirements passed from parent to child.
    -- Each MeasureSpec represents a requirement for either the width or the height.
    -- A MeasureSpec is comprised of a size and a mode. There are three possible modes:
    __Sealed__()
    __AutoIndex__()
    enum "MeasureSpecMode"{
        -- The parent has not imposed any constraint on the child.
        -- It can be whatever size it wants.
        "UNSPECIFIED",
        -- The parent has determined an exact size for the child.
        -- The child is going to be given those bounds regardless of how big it wants to be.
        -- This situation is usually not considered.
        "EXACTLY",
        -- The child can be as large as it wants up to the specified size.
        "AT_MOST"
    }

    -- MeasureSpecMode and width/height struct
    __Sealed__()
    struct "MeasureSpec"(function()

        member "mode"   { Type = MeasureSpecMode, Require = true }
        member "size"   { Type = Number }

        __valid = function(value)
            if value.mode ~= MeasureSpecMode.UNSPECIFIED and not value.size then
                return "%s.size can not be nil"
            end
        end

        __init = function(value)
            if not value.size or value.size < 0 then
                value.size = 0
            end
        end
        
    end)

    __Sealed__()
    struct "LayoutParams"(function()

        member "width"      { Type = NonNegativeNumber + SizeMode, Require = true }
        member "height"     { Type = NonNegativeNumber + SizeMode, Require = true }
        -- Works when width is wrap content or match parent
        -- if pref width is wrap content also, use view's width
        -- pref width can not be set to match parent
        member "prefWidth"  { Type = NonNegativeNumber + SizeMode }
        -- Works when height is wrap content or match parent
        -- if pref height is wrap content also, use view's height
        -- pref height can not be set to match parent
        member "prefHeight" { Type = NonNegativeNumber + SizeMode }
        member "margin"     { Type = Margin }

        __valid = function(value, onlyValid)
            if value.width < 0 then
                if value.prefWidth == SizeMode.MATCH_PARENT then
                    return onlyValid or "the %s's prefWidth can not be set to match parent"
                end
            end
            if value.height < 0 then
                if value.prefHeight == SizeMode.MATCH_PARENT then
                    return onlyValid or "the %s's prefHeight can not be set to match parent"
                end
            end
        end

    end)

    __Static__()
    __Arguments__{ LayoutFrame, LayoutParams }
    function LayoutParams.GetPrefWidth(view, layoutParams)
        -- @todo
        -- if layoutParams.width 
    end

    __Static__()
    __Arguments__{ LayoutFrame, LayoutParams }
    function LayoutParams.GetPrefHeight(view, layoutParams)
        -- @todo
    end
    
end)