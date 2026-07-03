
-- luajit 2

png = require "luapng/init"

data = io.open("dataset/ne_110m_coastline.geojson", "r")

coord_t = {}
for line in data:lines() do
      local coord_str = line:match("\"coordinates\": (%[ %[.*%] %])") 
      if coord_str ~= nil then
            coord_str = coord_str:gsub("%[", "{")
            coord_str = coord_str:gsub("%]", "}")
            local coord_row = load("return " .. coord_str)()
            if type(coord_row[1][1]) == "number" then
                  -- LineString
                  coord_t[#coord_t + 1] = coord_row
            elseif type(coord_row[1][1]) == "table" then
                  -- MultiLineString
                  for _, row in ipairs(coord_row) do
                        print(type(row[1][1]))
                        coord_t[#coord_t + 1] = row
                  end
            end
      end
end

for k, v in ipairs(coord_t) do print(table.concat(v[1], ", ")) end

