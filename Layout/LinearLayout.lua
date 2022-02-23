PLoop(function()

    namespace "SpaUI.Widget.Layout"

    __Sealed__()
    class "LinearLayout"(function()
        inherit "ViewGroup"

        property "Orientation"      {
            type                    = Orientation,
            default                 = Orientation.VERTICAL
        }

        -- @Override
        function SetupScrollChild(self)
            
        end

    end)

end)