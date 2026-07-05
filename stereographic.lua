
local sin, cos, acos, asin, tan, pi = math.sin, math.cos, math.acos, math.asin, math.tan, math.pi

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
      return lat, lon
end

-- rotates lat, lon measured from the north pole to measured from Null Island
-- new_lat = parallels around Null Island
-- new_lon = angle from the prime meridian
function rotate_sphere(lat, lon)
      new_lat = acos(sin(lat) * cos(lon))
      new_lon = asin(sin(lat) * sin(lon) / sin(new_lat))
      return new_lat, new_lon
end

function proj_stereo(lat, lon)
      local olat, olon, south, east = get_quadrant(lat, lon)
      olat, olon = rotate_sphere(olat, olon)
      olat, olon = decode_quadrant(olat, olon, south, east)
      return tan(olat/2), olon
end

return proj_stereo

