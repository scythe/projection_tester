
local sin, cos, asin, pi, sqrt, atan2 = math.sin, math.cos, math.asin, math.pi, math.sqrt, math.atan2

-- table of values used to invert the function theta + sin(theta)
-- by cubic interpolation with Hermite splines
local tv = {
      {0, 0, 0.5},
      {0.31351409771972, 0.15707963267949, 0.50309697932855},
      {0.62317625973393, 0.31415926535898, 0.51254281546846},
      {0.92522939777802, 0.47123889803847, 0.52881890528072},
      {1.2161037830104, 0.62831853071796, 0.55278640450004},
      {1.492504944584, 0.78539816339745, 0.5857864376269},
      {1.7514947904519, 0.94247779607694, 0.62980809184125},
      {1.9905639529448, 1.0995574287564, 0.68776240297246},
      {2.2076935777311, 1.2566370614359, 0.76393202250021},
      {2.4014050347105, 1.4137166941154, 0.86472690864087},
      {2.5707963267949, 1.5707963267949, 1},
      {2.7155643000695, 1.7278759594744, 1.185444353233},
      {2.836012108449, 1.8849555921539, 1.4472135955},
      {2.9330417490217, 2.0420352248334, 1.8314699643925},
      {3.0081318518878, 2.1991148575129, 2.4259199981596},
      {3.0633012713789, 2.3561944901923, 3.4142135623731},
      {3.1010593751643, 2.5132741228718, 5.2360679774998},
      {3.1243442552909, 2.6703537555513, 9.1748610873576},
      {3.1364503826058, 2.8274333882308, 20.431729094531},
      {3.1409474859505, 2.9845130209103, 81.223819398794},
      {3.1415926535898, 3.1415926535898, inf}
}

function proj_mollweide(lat, lon)
      local step = 1
      local latsign = lat < 0 and -1 or 1
      local lat = lat * latsign
      local pisinphi = pi * sin(lat)
      while tv[step+1][1] < pisinphi do
            step = step + 1
      end
      local theta_1, dtdy1 = tv[step][2], tv[step][3]
      local theta_2, dtdy2 = tv[step+1][2], tv[step+1][3]
      local gap = (tv[step+1][1] - tv[step][1])
      local t = (pisinphi - tv[step][1]) / gap
      local h1 = (1 + t * t * (-3 + 2 * t)) * theta_1
      local h2 = t * (1 + t * (-2 + t)) * dtdy1 * gap
      local h3 = t * t * (3 - 2 * t) * theta_2
      local h4 = t * t * (-1 + t) * dtdy2 * gap
      local theta = h1 + h2 + h3 + h4
      -- cubic interpolation fails at the last interval because dy/dt diverges
      -- so we use arcsin(t^2) to approximate near the singularity
      -- this gives a maximum error near 0.015 radians
      if tv[step+1][1] == pi then
            theta = asin(t*t) * (2/pi) * (theta_2 - theta_1) + theta_1
      end
      theta = theta * latsign / 2
      local x = (2 / pi) * (lon - pi / 2) * cos(theta)
      local y = sin(theta)
      return sqrt(x * x + y * y), atan2(-x, y)
end

return proj_mollweide

