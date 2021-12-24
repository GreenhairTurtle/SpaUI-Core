local data = {}
for i = 1, 10 do
    data[i] = "测试" .. i
end

local count = 1
for i = 10, 1, -1 do
    print(i, data[i], #data)
    if count%2 == 0 then
        table.remove(data, i)
    end
    count = count + 1
end

print("====")

for k, v in ipairs(data) do
    print(k, v)
end