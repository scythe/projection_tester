
-- luajit 2

local png = require "luapng/init"
local obj = require "obj"
local proj_stereo = require "stereographic"
local proj_mollweide = require "mollweide"
local pi, sin, cos, atan, sqrt, floor = math.pi, math.sin, math.cos, math.atan, math.sqrt, math.floor

local data = io.open("dataset/ne_110m_coastline.geojson", "r")

local coord_t = {}
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

function get_hemisphere(lat, lon, clon)
      lon = lon - clon
      if lon < 0 then
            lon = lon + 2 * pi
      end
      if lon <= pi then
            return lat, lon, true
      else
            return lat, lon - pi, false
      end
end

local line_arr = obj(table)

function line_arr:add_row(row, clon, project)
      local line = {}
      for _, point in ipairs(row) do
            local lat, lon, asia = point[2] * pi / 180, point[1] * pi / 180
            lat, lon, asia = get_hemisphere(lat, lon, clon)
            local r, phi = project(lat, lon)
            if line.asia == nil then
                  line.asia = asia
            end
            if line.asia ~= asia then
                  line[#line + 1] = {1, line[#line][2]}
                  self:insert(line)
                  line = {asia = asia, {1, 2 * pi - line[#line][2]}}
            end
            line[#line + 1] = {r, phi}
      end
      self:insert(line)
end

function draw(line, img, scale, color)
      local x, y = line.asia and scale or 3 * scale, scale
      for i, point1 in ipairs(line) do
            if i == #line then break end
            local point2 = line[i+1]
            local r1, phi1, r2, phi2 = point1[1], point1[2], point2[1], point2[2]
            local x1, y1, x2, y2 = x - r1 * sin(phi1) * scale, y - r1 * cos(phi1) * scale,
                                   x - r2 * sin(phi2) * scale, y - r2 * cos(phi2) * scale
            img:drawLine(floor(x1 + 0.5), floor(y1 + 0.5),
                         floor(x2 + 0.5), floor(y2 + 0.5),
                         color[1], color[2], color[3], color[4])
      end
end

function line_arr:plot(name, scale, color)
      local img = png.new(4 * scale, 2 * scale, "rgba")
      for k, line in ipairs(self) do
            draw(line, img, scale, color)
      end
      local outline = {asia = true}
      for i = 0, 720 do
            outline[#outline + 1] = {1, pi * i / 360}
      end
      draw(outline, img, scale, color)
      outline.asia = false
      draw(outline, img, scale, color)
      img:save(name)
end

-- average of Mollweide and stereographic projections along Archimedean spirals
function proj_mollstereo(lat, lon)
      local r1, phi1 = proj_stereo(lat, lon)
      local r2, phi2 = proj_mollweide(lat, lon)
      if phi2 < 0 then phi2 = phi2 + 2 * pi end
      print("stereo: " .. r1 .. ", " .. phi1, "moll: " .. r2 .. ", " .. phi2)
      return (r1 + r2)/2, (phi1 + phi2)/2
end

local clon, scale = ...
clon = clon or -pi/8
scale = scale or 1024

for name, proj in pairs{ster = proj_stereo, moll = proj_mollweide, ms = proj_mollstereo} do
      for _, curve in ipairs(coord_t) do
            line_arr:add_row(curve, clon, proj)
      end
      line_arr:plot(name .. ".png", scale, {60, 140, 220, 255})
      line_arr = line_arr()
end

