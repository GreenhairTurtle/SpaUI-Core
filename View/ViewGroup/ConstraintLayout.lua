PLoop(function()

    namespace "KittyBox.Layout"

    class "ConstraintLayout"(function()
        
        struct "LayoutParams"(function()

            __base = KittyBox.Widget.LayoutParams

            member "StartToStartOf"     { Type = NEString }
            member "StartToEndOf"       { Type = NEString }
            member "TopToTopOf"         { Type = NEString }
            member "TopToBottomOf"      { Type = NEString }
            member "EndToStartOf"       { Type = NEString }
            member "EndToEndOf"         { Type = NEString }
            member "BottomToTopOf"      { Type = NEString }
            member "BottomToBottomOf"   { Type = NEString }

        end)

    end)

end)