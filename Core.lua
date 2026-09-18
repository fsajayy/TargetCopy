local ADDON_NAME, NS = ...
NS = NS or {}
TargetCopy = NS
NS.name = ADDON_NAME or "TargetCopy"
NS.version = "@project-version@"

local defaults = {
    window = { point="CENTER", relativePoint="CENTER", x=0, y=0 },
    floatingButton = { enabled=true, locked=false, point="CENTER", relativePoint="CENTER", x=250, y=0 },
    quickCopy = { enabled=true, mode="target" },
    macroName = "TC_Target",
    macroIcon = 134400,
}

local function MergeDefaults(src, dst)
    for k,v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            MergeDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function NS:Print(msg)
    local text = "|cffd6ae5fTargetCopy|r " .. tostring(msg)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(text)
    else
        print(text)
    end
end

function NS:InitDB()
    TargetCopyDB = TargetCopyDB or {}
    MergeDefaults(defaults, TargetCopyDB)
    self.db = TargetCopyDB
end

function NS:CloseAuxiliaryWindows()
    if self.Settings then self.Settings:Hide() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == NS.name then
        NS:InitDB()
        if NS.UI then NS.UI:RestorePosition() end
        if NS.FloatingButton then NS.FloatingButton:ApplySettings() end
    elseif event == "PLAYER_LOGIN" then
        if NS.UI then NS.UI:Refresh() end
        if NS.FloatingButton then NS.FloatingButton:ApplySettings() end
        NS:Print("Loaded. /tc to open; /tc debug for diagnostics.")
    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        if NS.UI then NS.UI:Refresh() end
    end
end)

SLASH_TARGETCOPY1 = "/tc"
SLASH_TARGETCOPY2 = "/targetcopy"
SlashCmdList["TARGETCOPY"] = function(msg)
    msg = (msg or ""):match("^%s*(.-)%s*$"):lower()
    if msg == "" then
        NS.UI:Toggle()
    elseif msg == "show" then
        NS.UI:Show()
    elseif msg == "hide" then
        NS.UI:Hide()
    elseif msg == "settings" or msg == "config" then
        NS.UI:Show()
        NS.Settings:Show()
    elseif msg == "quick" then
        NS.QuickCopy:Trigger()
    elseif msg == "reset" then
        NS.UI:ResetPosition()
        NS.FloatingButton:ResetPosition()
    elseif msg == "debug" then
        NS.DebugPanel:Show()
    elseif msg == "help" then
        NS:Print("/tc - toggle | settings | quick | reset | debug | help")
    else
        NS:Print("Unknown command. Use /tc help.")
    end
end
