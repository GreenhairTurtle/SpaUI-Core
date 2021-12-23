---@diagnostic disable: undefined-global
-----------------------------------------------------------
--         Warcraft version of Android recyclerView      --
-----------------------------------------------------------
Scorpio "SpaUI.Widget.RecyclerView" ""

namespace "SpaUI.Widget.RecyclerView"

class "ItemDecoration" {}

class "ItemView" { Frame }

class "RecyclerView" { ScrollFrame }

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

        local orientation = self:GetOrientation()
        if orientation == Orientation.HORIZONTAL then
            self:GetParent():SetHorizontalScroll(value)
        elseif orientation == Orientation.VERTICAL then
            self:GetParent():SetVerticalScroll(value)
        end
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
    __Final__()
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
        default                 = 2.5
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

    property "ContentView"          {
        type                        = LayoutFrame
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
    function GetItemViewType(self, position)
        return 0
    end

    -- 获取item数量，必须是自然数
    __Abstract__()
    function GetItemCount(self)
        return 0
    end

    __Arguments__{ LayoutFrame, Number }
    __Final__()
    function CreateViewHolder(self, parent, viewType)
        local holder = OnCreateViewHolder(self, parent, viewType)
        holder.ItemViewType = viewType
        return holder
    end

    -- 必须返回ViewHolder并且对其设置Content view
    __Arguments__{ LayoutFrame, Number }
    __Abstract__()
    function OnCreateViewHoler(self, parent, viewType)
    end

    __Arguments__{ ViewHolder, NaturalNumber }
    __Final__()
    function BindViewHolder(self, holder, position)
        holder.Position = position
        OnBindViewHolder(self, holder, position)
    end

    __Arguments__{ ViewHolder, NaturalNumber }
    __Abstract__()
    function OnBindViewHolder(self, holder, position)
    end
    
end)

-----------------------------------------------------------
--          Decoration and item view                     --
--Each recyclerView can contain multiple item decoration --
-----------------------------------------------------------

__Sealed__()
class "ItemView"(function()
    inherit "Frame"

    property "ViewHolder"           {
        type                        = ViewHolder
    }

end)

__Sealed__()
class "ItemDecoration"(function()

    -- 返回每项item的间距
    -- left, right, top, bottom
    __Abstract__()
    function GetItemMargins()
        return 0, 0, 0, 0
    end

    __Arguments__{ RecyclerView, ItemView, Number }
    __Abstract__()
    function DrawBackground(recyclerView, itemView, position)
    end

    __Arguments__{ RecyclerView }
    __Abstract__()
    function DrawOver(recyclerView)
    end

end)

-----------------------------------------------------------
--                  LayoutManager                        --
-----------------------------------------------------------

__Sealed__()
class "LayoutManager"(function()

    property "RecylerView"          {
        type                        = RecyclerView
    }

    -- @param: position: item位置,第一个显示在RecyclerView可视范围内的item位置
    -- @param: offset: 当前滚动位置
    function Layout(self, position, offset)
        local startPosition = math.max(position - 1, 1)
        for i = 1, #self.RecyclerView.__ItemViews do
            local itemView = self.RecyclerView.__ItemViews[index]
            --@todo
        end
    end

    function NotifyDataSetChanged(self)

    end

    function ScrollToPosition(self)

    end

    function Destroy(self)
    end


end)

-----------------------------------------------------------
--                    RecyclerView                       --
-----------------------------------------------------------

__Sealed__()
class "RecyclerView"(function()

    -------------------------------------------------------
    --                    Property                       --
    -------------------------------------------------------

    property "Orientation"          {
        type                        = Orientation,
        default                     = Orientation.VERTICAL,
        handler                     = "OnOrientationChanged"
    }

    property "LayoutManager"        {
        type                        = LayoutManager,
        get                         = function(self) return self.__LayoutManager end,
        set                         = function(self, layoutManager)
            if self.__LayoutManager then
               self.__LayoutManager:Destroy()
            end
            self.__LayoutManager = layoutManager
            if layoutManager then
                layoutManager.RecyclerView = self
            end
        end
    }

    property "Adapter"              {
        type                        = Adapter,
        handler                     = "OnAdapterChanged"
    }

    -------------------------------------------------------
    --                    Functions                      --
    -------------------------------------------------------

    function OnOrientationChanged(self)
        local verticalScrollBar = self:GetChild("VerticalScrollBar")
        local horizontalScrollBar = self:GetChild("HorizontalScrollBar")

        if self.Orientation == Orientation.VERTICAL then
            verticalScrollBar:Show()
            horizontalScrollBar:Hide()
        elseif self.Orientation == Orientation.HORIZONTAL then
            verticalScrollBar:Hide()
            horizontalScrollBar:Show()
        end
    end

    function OnAdapterChanged(self)
        local adapter = self.Adapter
        if adapter then
            local scrollBar = self:GetScrollBar()
            scrollBar:SetMinMaxValues(0, adapter:GetItemCount())
            scrollBar:SetValue(0)
        end

        if self.LayoutManager then
            self.LayoutManager:NotifyDataSetChanged()
        end
    end

    -- 跳转到指定item
    __Arguments__{ NaturalNumber }
    function ScrollToPosition(self, position)
        if self.LayoutManager then
            self.LayoutManager:ScrollToPosition(position)
        end
    end

    -- 获取Scrollbar
    function GetScrollBar(self)
        if self.Orientation == Orientation.HORIZONTAL then
            return self:GetChild("HorizontalScrollBar")
        elseif self.Orientation == Orientation.VERTICAL then
            return self:GetChild("VerticalScrollBar")
        end
    end

    -- 获取内容长度
    function GetContentLength(self)
        if self.Orientation == Orientation.HORIZONTAL then
            return self:GetChild("ScrollChild"):GetWidth()
        elseif self.Orientation == Orientation.VERTICAL then
            return self:GetChild("ScrollChild"):GetHeight()
        end
    end

    -- 回收所有ItemViews
    function RecycleAllViews(self)
        
    end

    local function OnVerticalScroll(self, offset)
    end

    __Template__{
        VerticalScrollBar           = VerticalScrollBar,
        HorizontalScrollBar         = HorizontalScrollBar,
        ScrollChild                 = Frame
    }
    function __ctor(self)
        self.__ItemViews = {}
        self.__ItemViewCaches = {}

        local scrollChild = self:GetChild("ScrollChild")
        self:SetScrollChild(scrollChild)
        scrollChild:SetPoint("TOPLEFT")
        scrollChild:SetSize(1, 1)
        
        self:OnOrientationChanged()

        self.OnVerticalScroll = self.OnVerticalScroll + OnVerticalScroll
    end

end)


Style.UpdateSkin("Default", {
    [ScrollBar]                                 = {
        fadeout                                 = true
    },

    [VerticalScrollBar]                         = {
        width                                   = 16,
        thumbTexture                            = {
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
        thumbTexture                            = {
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
    },

    [RecyclerView]                              = {

        VerticalScrollBar                       = {
            location                            = {
                Anchor("TOPRIGHT", -2, -18),
                Anchor("BOTTOMRIGHT", -2, 18)
            }
        },

        HorizontalScrollBar                     = {
            location                            = {
                Anchor("BOTTOMLEFT", 18, 2),
                Anchor("BOTTOMRIGHT", -18, 2)
            }
        }
    }
})
