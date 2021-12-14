PLoop(function()

    namespace "SpaUI.Widget.RecyclerView"

    -- 修改自Scorpio.Widget.UIPanelScrollFrame.UIPanelScrollBar
    -- 无视ValueSetp的ScrollBar，每次滚动只移动1，对应列表1个item
    __Sealed__()
    class "ScrollBar"(function()
        inherit "Slider"

        local function RefreshScrollButtonStates(self)
            local value = self:GetValue()
            local min, max = self:GetMinMaxValues()
            local scrollUpButton = self:GetChild("ScrollUpButton")
            local scrollDownButton = self:GetChild("ScrollDownButton")

            if value <= min then
                scrollUpButton:Disable()
            else
                scrollDownButton:Enable()
            end
            if value >= max then
                scrollDownButton:Disable()
            else
                scrollDownButton:Enable()
            end
        end

        local function OnValueChanged(self, value)
            RefreshScrollButtonStates(self)
            self:GetParent():SetVerticalScroll(value)
        end

        local function OnMouseWheel(self, delta)
            local value = self:GetValue() - delta
            local min, max = self:GetMinMaxValues()
            if value < min then
                value = min
            elseif value > max then
                value = max
            end
            self:SetValue(value)
        end

        -- Hold down
        local function ScrollButton_Update(self, elapsed)
            self.timeSinceLast = self.timeSinceLast + elapsed
            if self.timeSinceLast >= 0.08 then
                if not IsMouseButtonDown("LeftButton") then
                    self:SetScript("OnUpdate", nil)
                elseif self:IsMouseOver() then
                    OnMouseWheel(self:GetParent(), self.direction)
                    self.timeSinceLast = 0
                end
            end
        end

        local function ScrollButton_OnClick(self, button, down)
            if down and button == "LeftButton" then
                self.timeSinceLast = -0.2
                self:SetScript("OnUpdate", ScrollButton_Update)
                OnMouseWheel(self:GetParent(), self.direction)
                PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            else
                self:SetScript("OnUpdate", nil)
            end
        end

        local function OnEnter(self)
            if self.Fadeout then
                self:SetAlpha(1)
            end
        end

        local function OnLeave(self)
        end

        local function OnUpdate(self, elapsed)
            if self:IsMouseOver() then
                self:SetAlpha(1000)
            else

            end
        end

        local function ScrollButton_OnEnter(self)
            OnEnter(self:GetParent())
        end

        local function ScrollButton_OnLeave(self)
            OnLeave(self:GetParent())
        end

        -- @Override
        function SetValueStep(self, step)
            -- do nothing
        end

        -- 渐隐
        property "Fadeout"          {
            type                    = Boolean,
            default                 = true,
            handler                 = function(self, fadeout)
                if fadeout then
                    self.OnUpdate = self.OnUpdate + OnUpdate
                else
                    self.OnUpdate = self.OnUpdate - OnUpdate
                end
            end
        }

        -- 渐隐时间
        property "FadeoutDuration" {
            type                    = Number,
            default                 = 1500
        }

        __Template__{
            ScrollUpButton          = Button,
            ScrollDownButton        = Button,
        }
        function __ctor(self)
            self:SetAlpha(0)

            local scrollUpButton    = self:GetChild("ScrollUpButton")
            local scrollDownButton  = self:GetChild("ScrollDownButton")
            
            scrollUpButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
            scrollUpButton.direction = 1
            scrollDownButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
            scrollDownButton.direction = -1
            scrollUpButton.OnClick  = scrollUpButton.OnClick + ScrollButton_OnClick
            scrollUpButton.OnEnter = scrollUpButton.OnEnter + ScrollButton_OnEnter
            scrollUpButton.OnLeave = scrollUpButton.OnLeave + ScrollButton_OnLeave
            scrollDownButton.OnClick= scrollDownButton.OnClick + ScrollButton_OnClick
            scrollDownButton.OnEnter = scrollDownButton.OnEnter + ScrollButton_OnEnter
            scrollDownButton.OnLeave = scrollDownButton.OnLeave + ScrollButton_OnLeave

            self.OnValueChanged     = self.OnValueChanged + OnValueChanged
            self.OnMouseWheel       = self.OnMouseWheel + OnMouseWheel
            self.OnEnter            = self.OnEnter + OnEnter
            self.OnLeave            = self.OnLeave + OnLeave
        end

    end)

    __Sealed__()
    class "RecyclerView"(function()
        inherit "ScrollFrame"


    end)
end)