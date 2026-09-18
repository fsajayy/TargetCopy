local NS = TargetCopy
NS.Marker = {}
local M = NS.Marker
M.names = {"Star","Circle","Diamond","Triangle","Moon","Square","Cross","Skull"}

function M:Get(unit)
    if type(GetRaidTargetIndex) ~= "function" then return 0 end
    local ok, value = pcall(GetRaidTargetIndex, unit)
    return ok and (value or 0) or 0
end

function M:Set(unit, index)
    if not NS.Unit:Exists(unit) then return false, "NO_UNIT" end
    if not NS.Compat:CanRaidMark() then return false, "API_UNAVAILABLE" end
    index = tonumber(index) or 0
    if index < 0 or index > 8 then return false, "BAD_INDEX" end
    local ok, err = pcall(SetRaidTarget, unit, index)
    return ok, ok and "OK" or err
end
