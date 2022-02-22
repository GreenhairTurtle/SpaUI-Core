PLoop(function(Env)

    namespace "SpaUI.Widget.Layout"

    -----------------------------------------------------------
    --                    FrameLayout                        --
    -----------------------------------------------------------

    -- 子元素将根据其顺序决定显示层级

    class "FrameLayout"(function()
        
        property "Padding"      {
            type                = Padding,
            default             = 0
        }

    end)

end)