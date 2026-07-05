
local gran = ...
local sin, cos, pi, abs, asin = math.sin, math.cos, math.pi, math.abs, math.asin

local tv = {}

for i = 0, gran do
      local theta = pi * i / gran
      local pisinphi = theta + sin(theta)
      local dydt = 1 + cos(theta)
      tv[#tv+1] = {pisinphi, theta, 1/dydt}
end

local max_err, step = 0, 1
for i = 0, 1000 do
      local theta = pi * i / 1000
      local pisinphi = theta + sin(theta)
      while tv[step+1][1] < pisinphi do
            step = step+1
      end
      print("init:", tv[step][1], pisinphi, tv[step+1][1])
      local theta_1, dtdy1 = tv[step][2], tv[step][3]
      local theta_2, dtdy2 = tv[step+1][2], tv[step+1][3]
      local gap = (tv[step+1][1] - tv[step][1])
      local t = (pisinphi - tv[step][1]) / gap
--      print(t, theta_1, dtdy1, theta_2, dtdy2)
      h1 = (1 + t * t * (-3 + 2 * t)) * theta_1
      h2 = t * (1 + t * (-2 + t)) * dtdy1 * gap
      h3 = t * t * (3 - 2 * t) * theta_2
      h4 = t * t * (-1 + t) * dtdy2 * gap
      local theta_y = h1 + h2 + h3 + h4
--      print(t, h1, h2, h3, h4)
      if tv[step+1][1] == pi then
            theta_y = asin(t*t) * (2/pi) * (theta_2 - theta_1) + theta_1
      end
      print(theta_1, theta, theta_y, theta_2)
      local err = abs(theta - theta_y)
      if err > max_err then max_err = err print(err) end
end

for _, v in ipairs(tv) do
      print("{" .. table.concat(v, ", ") .. "}")
end

print("Maximum error: ", max_err)

