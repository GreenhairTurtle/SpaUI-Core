PLoop(function()

    namespace "SpaUI.Widget.Layout"

    __Sealed__()
    class "LinearLayout"(function()
        inherit "BaseLayout"

        property "Orientation"      {
            type                    = Orientation,
            default                 = Orientation.VERTICAL
        }

    end)

end)