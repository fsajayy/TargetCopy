local NS = TargetCopy
NS.Unit = {}
local U = NS.Unit

function U:Exists(unit)
    if type(UnitExists) ~= "function" then return false end
    local ok, value = pcall(UnitExists, unit)
    return ok and value and true or false
end

function U:GetName(unit)
    if not self:Exists(unit) then return nil, "NO_UNIT" end
    if type(UnitName) ~= "function" then return nil, "API_UNAVAILABLE" end
    local ok, name, realm = pcall(UnitName, unit)
    if not ok or not name or name == "" then return nil, "NO_NAME" end
    if realm and realm ~= "" then return name .. "-" .. realm end
    return name
end

function U:GetMeta(unit)
    if not self:Exists(unit) then return "Select a unit to enable target actions." end
    local level, creature
    if type(UnitLevel) == "function" then pcall(function() level = UnitLevel(unit) end) end
    if type(UnitCreatureType) == "function" then pcall(function() creature = UnitCreatureType(unit) end) end
    local parts = {}
    if level and level > 0 then parts[#parts+1] = "Level " .. level end
    if creature and creature ~= "" then parts[#parts+1] = creature end
    return #parts > 0 and table.concat(parts, " | ") or "Target available"
end
