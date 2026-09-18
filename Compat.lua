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

function C:Debug()
    local version, build, _, interface = GetBuildInfo()
    NS:Print("Diagnostics")
    NS:Print("Addon="..tostring(NS.version).." Client="..tostring(version).." Build="..tostring(build).." Interface="..tostring(interface))
    NS:Print("SetRaidTarget="..tostring(self:CanRaidMark()).." CreateMacro="..tostring(self:CanCreateMacro()).." EditMacro="..tostring(self:CanEditMacro()))
    NS:Print("QuickCopy="..tostring(NS.db and NS.db.quickCopy.enabled).." Mode="..tostring(NS.db and NS.db.quickCopy.mode).." Key="..self:GetBindingText())
    NS:Print("Combat="..tostring(self:InCombat()))
    local name, err = NS.Unit:GetName("target")
    NS:Print("Target="..tostring(name or err))
end
