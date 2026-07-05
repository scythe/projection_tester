
-- luajit 2

local png = require "luapng/init"
local obj = require "obj"
local math = require "math"
local pi = math.pi

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
            lat, lon, asia = get_hemisphere(lat, lon)
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
            img.drawLine(x + r1 * cos(phi1), y + r1 * sin(phi1),
                         x + r2 * cos(phi2), y + r2 * sin(phi2),
                         color[1], color[2], color[3], color[4])
      end
end

function line_arr:plot(name, scale, color)
      img = png.new(4 * scale, 2 * scale, "rgba")
      for k, line in ipairs(self) do
            draw(line, img, scale, color)
      end
      img:save(name)
end

function get_quadrant(lat, lon)
      local south, east = false, false
      if lat < 0 then
            lat = lat + pi/2
            south = true
      else
            lat = pi/2 - lat
      end
      if lon <= pi/2 then
            lon = pi/2 - lon
      else
            lon = lon - pi/2
            east = true
      end
      return lat, lon, south, east
end

function decode_quadrant(lat, lon, south, east)
      if south and east then
            lon = pi + lon
      elseif south and not east then
            lon = pi - lon
      elseif not south and east then
            lon = 2 * pi - lon
      end
      return lat, lon, oct.asia
end

-- rotates lat, lon measured from the north pole to measured from Null Island
-- new_lat = parallels around Null Island
-- new_lon = angle from the prime meridian
function rotate_sphere(lat, lon)
      local sin, cos, acos, asin = math.sin, math.cos, math.acos, math.asin
      new_lat = acos(sin(lat) * cos(lon))
      new_lon = asin(sin(lat) * sin(lon) / sin(new_lat))
      return new_lat, new_lon
end

function proj_stereo(lat, lon)
      local olat, olon, south, east = get_quadrant(lat, lon)
      olat, olon = rotate_sphere(olat, olon)
      olat, olon = decode_quadrant(olat, olon, south, east)
      return tan(pi/4 - olat/2), olon
end

function proj_mollweide(lat, lon)
      
