local camera
local Cam = {}

function Cam.CamPed()
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, -0.5, 4.5, 0)
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1550, 1, 0)
    SetCamCoord(camera, coords.x, coords.y, coords.z- 0.5)
    SetCamFov(camera, 38.0)
    SetCamRot(camera, 0.0, 0.0, GetEntityHeading(cache.ped) + 180)

    local coords = GetCamCoord(camera)
    TaskLookAtCoord(cache.ped, coords.x, coords.y, coords.z, -1, 1, 1)
    SetCamUseShallowDofMode(camera, true)
    SetCamNearDof(camera, 0.5)
    SetCamFarDof(camera, 12.0)
    SetCamDofStrength(camera, 1.0)
    SetCamDofMaxNearInFocusDistance(camera, 1.0)
    CreateThread(function()
        repeat
            SetUseHiDof()
            Wait(0)
        until not DoesCamExist(camera)
    end)
end

function Cam.DestroyCam()
    RenderScriptCams(false, true, 1250, 1, 0)
    DestroyCam(camera, false)
    camera = nil
end

function Cam.GetCam()
    return camera
end

return Cam
