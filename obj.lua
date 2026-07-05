
return function(...)
      local obj = {}
      local class = {}
      -- lazy multiple inheritance
      for _, parent in ipairs(...) do
            for k, v in pairs(parent) do
                  class[k] = v
            end
      end
      local function ctor()
            local clone = {}
            setmetatable(clone, getmetatable(obj))
            return clone
      end
      setmetatable(obj, {__newindex = class, __index = class, __call = ctor})
      return obj
end

