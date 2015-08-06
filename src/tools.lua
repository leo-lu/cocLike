function createAnimation( res )
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(res..".png", res..".plist",res..".ExportJson")
    local animation = ccs.Armature:create(res)
    --animation:getAnimation():play("walk")
    return animation
end