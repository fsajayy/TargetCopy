local NS=TargetCopy
NS.FloatingButton={}
local FB=NS.FloatingButton
local b=CreateFrame("Button","TargetCopyFloatingButton",UIParent,"UIPanelButtonTemplate")
FB.frame=b
b:SetSize(38,32); b:SetText("TC"); b:SetFrameStrata("MEDIUM"); b:SetClampedToScreen(true); b:SetMovable(true); b:RegisterForDrag("LeftButton")
b:SetScript("OnClick",function() NS.UI:Toggle() end)
b:SetScript("OnDragStart",function(self) if not (NS.db and NS.db.floatingButton.locked) then self:StartMoving() end end)
b:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    if not NS.db then return end
    local p,_,rp,x,y=self:GetPoint(1); local d=NS.db.floatingButton
    d.point=p or "CENTER"; d.relativePoint=rp or "CENTER"; d.x=x or 250; d.y=y or 0
end)
b:SetScript("OnEnter",function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:SetText("TargetCopy")
    GameTooltip:AddLine("Click: open / close",1,1,1); GameTooltip:AddLine("Drag: move button",.8,.8,.8); GameTooltip:Show()
end)
b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)

function FB:ApplySettings()
    if not NS.db then return end
    local d=NS.db.floatingButton; b:ClearAllPoints()
    local ok=pcall(function() b:SetPoint(d.point or "CENTER",UIParent,d.relativePoint or "CENTER",d.x or 250,d.y or 0) end)
    if not ok then self:ResetPosition() end
    if d.enabled then b:Show() else b:Hide() end
end
function FB:ResetPosition()
    b:ClearAllPoints(); b:SetPoint("CENTER",UIParent,"CENTER",250,0)
    if NS.db then
        local d=NS.db.floatingButton; d.point="CENTER"; d.relativePoint="CENTER"; d.x=250; d.y=0
    end
end
