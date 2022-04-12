PLoop(function()

    -------------------------------------------------------
    --                Fork of Scorpio UI                 --
    -------------------------------------------------------

    namespace "SpaUI.Layout.Widget"
    import "SpaUI.Layout.IView"

    class "Button" { Scorpio.UI.Widget.Button, IView }

    class "CheckBox" { Scorpio.UI.Widget.CheckButton, IView }

    class "EditText" { Scorpio.UI.Widget.EditBox, IView }

    class "ScrollView" { Scorpio.UI.Widget.ScrollFrame, IView }

    class "Slider" { Scorpio.UI.Widget.Slider, IView }

    class "ProgressBar" { Scorpio.UI.Widget.StatusBar, IView }

end)