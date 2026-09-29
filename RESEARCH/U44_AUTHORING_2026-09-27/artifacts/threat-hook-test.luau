local v11
  v11 = function(prototype, instruction, arguments)
    if prototype == 16 and instruction == 597 then
      arguments[2] = 5
    end
  end

for _, value in {0, 1, 2, 3, 4, 5} do
 local a = {"receiver", value}
 v11(16, 597, a)
 assert(a[1] == "receiver" and a[2] == 5)
end
for _, site in {{15,597},{16,596},{18,27}} do
 local a = {"receiver", 1}
 v11(site[1],site[2],a)
 assert(a[2] == 1)
end
print("PASS threat hook: six input levels, three unrelated callsites")
