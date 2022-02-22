PLoop(function(ENV)

    namespace "SpaUI.Widget"

    __Sealed__()
    struct "Padding"(function()
        member "left"   { Type = NonNegativeNumber, require = true }
        member "top"    { Type = NonNegativeNumber }
        member "right"  { Type = NonNegativeNumber }
        member "bottom" { Type = NonNegativeNumber }

        -- 如果传1个参数，则所有padding值都为该值
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

    -- 表明子元素相对父元素的相对位置
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

end)