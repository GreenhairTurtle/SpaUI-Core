PLoop(function()

    namespace "SpaUI.Layout.ViewGroup"
    import "SpaUI.Layout"

    class "ViewGroup"(function()
        inherit "View"
        
        __Arguments__{ IView, NonNegativeNumber/0 }
        function AddView(self, view, index)
            if index <= 0 then
                index = self:GetChildViews() + 1
            end
            tinset(self.__ChildViews, view, index)
            self:RequestLayout()
        end

        __Arguments__{ NaturalNumber }
        function GetChildViewAt(self, index)
            return self.__ChildViews[index]
        end

        function GetChildViewCount(self)
            return #self.__ChildViews
        end

        function GetChildViews(self)
            return self.__ChildViews
        end

        function __ctor(self)
            self.__ChildViews = {}
        end

    end)

end)