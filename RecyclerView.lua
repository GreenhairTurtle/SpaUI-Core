-----------------------------------------------------------
--         Warcraft version of Android recyclerView      --
-----------------------------------------------------------
Scorpio "SpaUI.Widget.RecyclerView" ""

namespace "SpaUI.Widget.RecyclerView"

-----------------------------------------------------------
--                     ScrollBar                         --
-----------------------------------------------------------

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
            scrollUpButton:Enable()
        end
        if value >= max then
            scrollDownButton:Disable()
        else
            scrollDownButton:Enable()
        end
    end
    
    local function Show(self)
        self:SetAlpha(1)
        local current = GetTime()
        self.ShowTime = current
        self.FadeoutTarget = current + self.FadeoutDelay + self.FadeoutDuration
    end

    local function OnValueChanged(self, value)
        Show(self)
        RefreshScrollButtonStates(self)
        -- self:GetParent():SetVerticalScroll(value)
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
        Show(self)
    end

    local function OnLeave(self)
    end

    local function IsMouseOver(self)
        if self:IsMouseOver() then return true end

        for _, child in self:GetChilds() do
            if child:IsMouseOver() then return true end
        end
    end

    local function OnUpdate(self, elapsed)
        if IsMouseOver(self) then
            Show(self)
        else
            local current = GetTime()
            if self.FadeoutTarget and current <= self.FadeoutTarget and current - (self.ShowTime or 0) > self.FadeoutDelay then
                local alpha = (self.FadeoutTarget - current)/self.FadeoutDuration
                self:SetAlpha(alpha)
            end
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
        handler                 = function(self, fadeout)
            if fadeout then
                self.OnUpdate = self.OnUpdate + OnUpdate
            else
                self.OnUpdate = self.OnUpdate - OnUpdate
            end
        end
    }

    -- 渐隐时间
    property "FadeoutDuration"  {
        type                    = Number,
        default                 = 5
    }

    -- 渐隐延迟
    property "FadeoutDelay"     {
        type                    = Number,
        default                 = 2
    }

    __Template__{
        ScrollUpButton          = Button,
        ScrollDownButton        = Button,
    }
    function __ctor(self)
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
class "HorizontalScrollBar" { ScrollBar }

__Sealed__()
class "VerticalScrollBar"   { ScrollBar }


-----------------------------------------------------------
--                      Adapter                          --
-----------------------------------------------------------

__Sealed__()
class "ViewHolder"(function()

    property "ItemView"             {
        type                        = -LayoutFrame
    }

    property "ItemViewType"         {
        type                        = Number
    }

    property "Position"             {
        type                        = NaturalNumber
    }

end)

__Sealed__()
class "Adapter"(function()
    
    __Arguments__{ NaturalNumber }
    __Return__{ Number }
    function GetItemViewType(self, position)
        return 0
    end

    __Abstract__()
    __Return__{ NaturalNumber }
    function GetItemCount(self)
    end

    __Final__()
    __Arguments__{ -LayoutFrame, Number }
    function CreateViewHolder(self, parent, viewType)
        local holder = OnCreateViewHolder(self, parent, viewType)
        holder.ItemViewType = viewType
        return holder
    end

    __Abstract__()
    __Arguments__{ -LayoutFrame, Number }
    function OnCreateViewHoler(self, parent, viewType)
    end

    __Final__()
    __Arguments__{ -ViewHolder, NaturalNumber }
    function BindViewHolder(self, holder, position)
        holder.Position = position
        OnBindViewHolder(self, holder, position)
    end

    __Abstract__()
    __Arguments__{ -ViewHolder, NaturalNumber }
    function OnBindViewHolder(self, holder, position)
    end

end)

-----------------------------------------------------------
--                  Decoration                           --
-----------------------------------------------------------

__Sealed__()
class "ItemDecoration"(function()

    -- return item margin
    __Abstract__()
    function GetItemMargins()
        return 0, 0, 0, 0
    end

end)

-----------------------------------------------------------
--                  LayoutManager                        --
-----------------------------------------------------------

__Sealed__()
class "LayoutManager"(function()


end)

__Sealed__()
class "RecyclerView"(function()
    inherit "ScrollFrame"
end)


Style.UpdateSkin("Default", {
    [ScrollBar]                                 = {
        fadeout                                 = true
    },

    [VerticalScrollBar]                         = {
        width                                   = 16,

        ThumbTexture                            = {
            file                                = [[Interface\Buttons\UI-ScrollBar-Knob]],
            texCoords                           = RectType(0.20, 0.80, 0.125, 0.875),
            size                                = Size(18, 24),
        },

        ScrollUpButton                          = {
            location                            = { Anchor("BOTTOM", 0, 0, nil, "TOP") },
            size                                = Size(18, 16),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Up]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Down]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Disabled]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Highlight]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
                alphamode                       = "ADD",
            }
        },

        ScrollDownButton                        = {
            location                            = { Anchor("TOP", 0, 0, nil, "BOTTOM") },
            size                                = Size(18, 16),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Up]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Down]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Disabled]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Highlight]],
                texCoords                       = RectType(0.20, 0.80, 0.25, 0.75),
                setAllPoints                    = true,
                alphamode                       = "ADD",
            }
        }
    },

    [HorizontalScrollBar]                       = {
        height                                  = 16,
        orientation                             = "HORIZONTAL",

        ThumbTexture                            = {
            file                                = [[Interface\Buttons\UI-ScrollBar-Knob]],
            texCoords                           = {
                ULx                             = 0.8,
                ULy                             = 0.125,
                LLx                             = 0.2,
                LLy                             = 0.125,
                URx                             = 0.8,
                URy                             = 0.875,
                LRx                             = 0.2,
                LRy                             = 0.875
            },
            size                                = Size(24, 18),
        },

        ScrollUpButton                          = {
            location                            = { Anchor("RIGHT", 0, 0, nil, "LEFT") },
            size                                = Size(16, 18),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Up]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Down]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Disabled]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Highlight]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
                alphamode                       = "ADD",
            }
        },

        ScrollDownButton                        = {
            location                            = { Anchor("LEFT", 0, 0, nil, "RIGHT") },
            size                                = Size(16, 18),

            NormalTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Up]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            PushedTexture                       = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Down]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            DisabledTexture                     = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Disabled]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
            },
            HighlightTexture                    = {
                file                            = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Highlight]],
                texCoords                       = {
                    ULx                         = 0.8,
                    ULy                         = 0.25,
                    LLx                         = 0.2,
                    LLy                         = 0.25,
                    URx                         = 0.8,
                    URy                         = 0.75,
                    LRx                         = 0.2,
                    LRy                         = 0.75
                },
                setAllPoints                    = true,
                alphamode                       = "ADD",
            }
        }
    }
})