local NS = TargetCopy
NS.Macro = {}
local M = NS.Macro

local function Clean(s)
    return tostring(s or ""):gsub("[\r\n]", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

function M:Build(mode, name, mark)
    name = Clean(name)
    mark = tonumber(mark) or 0
    local target = name ~= "" and ("/target " .. name) or ""
    local marker = "/tm " .. mark
    if mode == "target" then return target end
    if mode == "mark" then return marker end
    if mode == "both" then return target ~= "" and (target .. "\n" .. marker) or marker end
    return ""
end

function M:CreateOrUpdate(body)
    if not body or body == "" then return false, "EMPTY" end
    if NS.Compat:InCombat() then return false, "COMBAT" end
    local name = (NS.db and NS.db.macroName) or "TC_Target"
    local icon = (NS.db and NS.db.macroIcon) or 134400
    local index
    if type(GetMacroIndexByName) == "function" then
        local ok, value = pcall(GetMacroIndexByName, name)
        if ok then index = value end
    end
    if index and index > 0 and NS.Compat:CanEditMacro() then
        local ok, err = pcall(EditMacro, index, name, icon, body, 1)
        return ok, ok and "UPDATED" or err
    end
    if not NS.Compat:CanCreateMacro() then return false, "API_UNAVAILABLE" end
    local ok, value = pcall(CreateMacro, name, icon, body, 1)
    return ok, ok and "CREATED" or value
end
