local NS=TargetCopy
BINDING_NAME_TARGETCOPY_QUICKCOPY = "Quick Copy current target"

function TargetCopy_QuickCopyBinding()
    if NS and NS.QuickCopy then NS.QuickCopy:Trigger() end
end
