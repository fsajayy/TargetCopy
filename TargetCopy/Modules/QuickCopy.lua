local NS = TargetCopy
NS.QuickCopy = {}
local Q = NS.QuickCopy

function Q:Build(name)
    local mode = (NS.db and NS.db.quickCopy and NS.db.quickCopy.mode) or "target"
    if mode == "name" then return name end
    if mode == "both" then return name .. "\n/target " .. name end
    return "/target " .. name
end

function Q:Trigger()
    if not NS.db or not NS.db.quickCopy.enabled then
        NS:Print("Quick Copy is disabled.")
        return
    end
    local name = NS.Unit:GetName("target")
    if not name then
        NS.QuickCopyPopup:ShowNotice("No target selected", 1.5)
        return
    end
    NS.QuickCopyPopup:ShowCopy(self:Build(name))
end
