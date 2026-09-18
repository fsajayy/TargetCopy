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
    if mode == "both" then
        return target ~= "" and (target .. "\n" .. marker) or marker
    end

    return ""
end

function M:GetMacroName(targetName)
    local name = Clean(targetName)

    if name == "" then
        return "TC_Target"
    end

    -- Keep the generated name predictable and macro-list friendly.
    name = name:gsub("%s+", "_")
    name = name:gsub("[^%w_%-]", "")
    name = name:gsub("_+", "_")
    name = name:gsub("^_+", ""):gsub("_+$", "")

    if name == "" then
        name = "Target"
    end

    -- Keep room for the TC_ prefix.
    name = name:sub(1, 13)

    return "TC_" .. name
end

function M:CreateOrUpdate(body, targetName)
    if not body or body == "" then return false, "EMPTY" end
    if NS.Compat:InCombat() then return false, "COMBAT" end

    local name = self:GetMacroName(targetName)
    local icon = (NS.db and NS.db.macroIcon) or 134400
    local index

    if type(GetMacroIndexByName) == "function" then
        local ok, value = pcall(GetMacroIndexByName, name)
        if ok then index = value end
    end

    if index and index > 0 and NS.Compat:CanEditMacro() then
        local ok, value = pcall(EditMacro, index, name, icon, body, 1)
        if not ok then return false, value end
        return true, "UPDATED", name
    end

    if not NS.Compat:CanCreateMacro() then
        return false, "API_UNAVAILABLE"
    end

    local ok, value = pcall(CreateMacro, name, icon, body, 1)
    if not ok then return false, value end

    return true, "CREATED", name
end
