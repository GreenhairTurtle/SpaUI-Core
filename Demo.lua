Scorpio "SpaUI.Widget.RecyclerView.Demo" ""

TestRecyclerView = RecyclerView("TestRecylcerView")
TestRecyclerView:SetPoint("CENTER")
TestRecyclerView:SetSize(500, 800)

adapter = Adapter()

function adapter:OnCreateContentView(viewType, contentViewName)
    local frame = Frame(contentViewName)
    frame:SetHeight(50)
    local text = FontString("Text", frame)
    text:SetAllPoints(frame)
    return frame
end

function adapter:OnBindViewHolder(holder, position)
    local data = self.Data[position]
    local contentView = holder.ContentView
    contentView:GetChild("Text"):SetText("测试" .. data)
end

adapter.Data = List(100, function() return math.random(100) end)

TestRecyclerView.Adapter = adapter
TestRecyclerView.LayoutManager = LinearLayoutManager()