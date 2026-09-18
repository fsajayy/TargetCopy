local NS = TargetCopy
NS.Compat = {}
local C = NS.Compat

function C:Has(name) return type(_G[name]) == "function" end
function C:InCombat() return type(InCombatLockdown) == "function" and InCombatLockdown() or false end
function C:CanRaidMark() return self:Has("SetRaidTarget") end
function C:CanCreateMacro() return self:Has("CreateMacro") end
function C:CanEditMacro() return self:Has("EditMacro") end

function C:GetBindingText()
    if type(GetBindingKey) ~= "function" then return "Unbound" end
    local ok, key = pcall(GetBindingKey, "TARGETCOPY_QUICKCOPY")
    return (ok and key and key ~= "") and key or "Unbound"
end

function C:GetDebugReport()
    local version, build, _, interface = GetBuildInfo()
    local name, err = NS.Unit:GetName("target")

    local lines = {
        "TargetCopy Diagnostics",
        "----------------------",
        "Addon Version: " .. tostring(NS.version),
        "Client Version: " .. tostring(version),
        "Build: " .. tostring(build),
        "Interface: " .. tostring(interface),
        "",
        "Capabilities",
        "SetRaidTarget: " .. tostring(self:CanRaidMark()),
        "CreateMacro: " .. tostring(self:CanCreateMacro()),
        "EditMacro: " .. tostring(self:CanEditMacro()),
        "",
        "Quick Copy",
        "Enabled: " .. tostring(NS.db and NS.db.quickCopy.enabled),
        "Mode: " .. tostring(NS.db and NS.db.quickCopy.mode),
        "Key: " .. self:GetBindingText(),
        "",
        "Runtime",
        "Combat: " .. tostring(self:InCombat()),
        "Target: " .. tostring(name or err),
        "SavedVariables: " .. tostring(NS.db ~= nil),
    }

    return table.concat(lines, "\n")
end
