Scorpio "SpaUI.Widget.RecyclerView.Demo" ""

TestRecyclerView = RecyclerView("TestRecylcerView")
TestRecyclerView:SetPoint("CENTER")
TestRecyclerView:SetSize(500, 800)

adapter = Adapter()

function adapter:OnCreateView(viewType)
end

function adapter:OnBindViewHolder(holder, position)
end

adapter.Data = List(100, function() return math.random(100) end)

TestRecyclerView.Adapter = adapter
TestRecyclerView.LayoutManager = LinearLayoutManager()