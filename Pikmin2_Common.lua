local Pikmin2_Common = {}

IsDemo = false
MoviePlayerPtrPtr = 0x80516114
RNGPtr = 0x805147e0
NaviMgrPtr = 0x805158a0

--Run this to get essential offsets and info about the current game version.
function Initialize()
    GameID = GetGameID()
	if (GameID ~= "GPVE01") and (GameID ~= "PIKE51") and (GameID ~= "GPVJ01") then
		SetScreenText("")
		CancelScript()
    --This just tests a random instruction offset in US Demo 1 that doesn't have any nearby similar instructions in US Final.
    elseif (GameID == "GPVE01" or GameID == "PIKE51") and ReadValue32(0x80471828) == 0x9421fb70 then
        IsDemo = true
    elseif GameID == "GPVE01" then
        MoviePlayerPtrPtr = MoviePlayerPtrPtr + 0xc0
        RNGPtr = RNGPtr + 0xc8
        NaviMgrPtr = NaviMgrPtr + 0xc0
    elseif GameID == "GPVJ01" then
        MoviePlayerPtrPtr = MoviePlayerPtrPtr + 0x1bc0
        RNGPtr = RNGPtr + 0x1bc8
        NaviMgrPtr = NaviMgrPtr + 0x1bc0
    end
end

--Function by LuigiM
function FloatHack(intVal)
    return string.unpack("f", string.pack("I4", intVal))
end

function Velocity(oldPos, pos) --This assumes 30FPS. Currently only used for Y velocity since actual captain vertical movement is calculated differently ingame.
    if oldPos and pos then
        return (pos - oldPos) * 30
    end
    return 0
end

--Gives various values in Navi objects
function NaviObjects(navimgr)
    if navimgr > 0x80000000 then
        NaviOne = ReadValue32(navimgr + 0x28)
        NaviTwo = NaviOne + 0x320

        OldOlimarPosY, OldLouiePosY = OlimarPosY, LouiePosY
        OlimarPosX, OlimarPosY, OlimarPosZ = FloatHack(ReadValue32(NaviOne + 0x20c)), FloatHack(ReadValue32(NaviOne + 0x210)), FloatHack(ReadValue32(NaviOne + 0x214))
        LouiePosX, LouiePosY, LouiePosZ = FloatHack(ReadValue32(NaviTwo + 0x20c)), FloatHack(ReadValue32(NaviTwo + 0x210)), FloatHack(ReadValue32(NaviTwo + 0x214))

        -- if OldOlimarPosY and OldLouiePosY then OlimarVelY, LouieVelY = Velocity(OldOlimarPosY, OlimarPosY), Velocity(OldLouiePosY, LouiePosY) end
        OlimarVelX, OlimarVelZ = FloatHack(ReadValue32(NaviOne+0x200)), FloatHack(ReadValue32(NaviOne+0x208))
        LouieVelX, LouieVelZ = FloatHack(ReadValue32(NaviTwo+0x200)), FloatHack(ReadValue32(NaviTwo+0x208))
        OlimarVelY, LouieVelY = FloatHack(ReadValue32(NaviOne+0x204)), FloatHack(ReadValue32(NaviTwo+0x204))

        OlimarCurrTri = ReadValue32(NaviOne + 0xc8)
        LouieCurrTri = ReadValue32(NaviTwo + 0xc8)

        if OlimarVelX and OlimarVelZ then OlimarVelXZ = math.sqrt((OlimarVelX^2) + (OlimarVelZ^2)) end
        if LouieVelX and LouieVelZ then LouieVelXZ = math.sqrt((LouieVelX^2) + (LouieVelZ^2)) end

        if OlimarCurrTri > 0x80000000 then OlimarColl = ReadValue8(OlimarCurrTri + 0x5c) >> 4 end
        if LouieCurrTri > 0x80000000 then LouieColl = ReadValue8(LouieCurrTri + 0x5c) >> 4 end
    end
end

return Pikmin2_Common