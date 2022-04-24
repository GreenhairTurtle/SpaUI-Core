PLoop(function()

    namespace "SpaUI.Layout"
    import "SpaUI.Layout"

    interface "ViewAnimate"(function()
        
        property "Duration" {
            type            = NonNegativeNumber,
            default         = 2
        }

        property "Loop"     {
            type            = AnimLoopType,
            default         = AnimLoopType.NONE
        }
        
    end)

end)