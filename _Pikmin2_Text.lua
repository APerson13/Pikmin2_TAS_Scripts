
pTwoRng = require("pikminTwoRNG")
pTwoCmn = require("Pikmin2_Common")

--Uses Malleo's RNG index functions
function RngCalls(oldSeed, newSeed)
    if newSeed and oldSeed then
        return pTwoRng.rnginverse(newSeed) - pTwoRng.rnginverse(oldSeed)
    end
    return nil
end

--Add an underscore (_) to the beginning of the filename if you want the script to auto launch once you start a game!

function onScriptStart()
    pTwoCmn.Initialize()
end

function onScriptCancel()
	SetScreenText("")
end

function onScriptUpdate()
    if OldFrame ~= GetFrameCount() then
        if MoviePlayerPtrPtr > 0x80000000 then --Make sure no bad pointers are read
            MoviePlayerPtr = ReadValue32(MoviePlayerPtrPtr)
            if MoviePlayerPtr > 0x80000000 then DemoState = ReadValue32(MoviePlayerPtr + 0x18) end
        end

        OldRNG = RNG
        RNG = ReadValue32(RNGPtr)
        Calls = RngCalls(OldRNG, RNG)

        if NaviMgrPtr > 0x80000000 then
            NaviMgr = ReadValue32(NaviMgrPtr)
            pTwoCmn.NaviObjects(NaviMgr)
        end

        local text = ""
        if IsDemo then
            text = text .. "\nVersion: US Demo 1\n"
        elseif GameID == "GPVE01" then
            text = text .. "\nVersion: US Final\n"
        end

	    text = text .. string.format("\n===RNG===\nSeed on this frame: %x", RNG)
        -- if OldRNG then text = text .. string.format("\nLast frame seed: %x", OldRNG) end
        if Calls then text = text .. string.format("\nCalls since last frame: %d", Calls) end

        if DemoState then text = text .. string.format("\n\n===Cutscenes===\nButton lockout: %d", DemoState) end

        text = text .. "\n\n===Positions and Velocities==="
        if OlimarPosX and OlimarVelX then text = text .. string.format("\nOlimar:\nX pos: %5f | X speed: %5f", OlimarPosX, OlimarVelX) end
        if OlimarPosY and OlimarVelY then text = text .. string.format("\nY pos: %5f | Y speed: %5f", OlimarPosY, OlimarVelY) end
        if OlimarPosZ and OlimarVelZ then text = text .. string.format("\nZ pos: %5f | Z speed: %5f", OlimarPosZ, OlimarVelZ) end
        if OlimarVelXZ then text = text .. string.format("\nXZ speed: %5f", OlimarVelXZ) end
        if OlimarColl then text = text .. string.format("\nCollision version: %d", OlimarColl) end
        if LouiePosX and LouieVelX then text = text .. string.format("\nLouie:\nX pos: %5f | X speed: %5f", LouiePosX, LouieVelX) end
        if LouiePosY and LouieVelY then text = text .. string.format("\nY pos: %5f | Y speed: %5f", LouiePosY, LouieVelY) end
        if LouiePosZ and LouieVelZ then text = text .. string.format("\nZ pos: %5f | Z speed: %5f", LouiePosZ, LouieVelZ) end
        if LouieVelXZ then text = text .. string.format("\nXZ speed: %5f", LouieVelXZ) end
        if LouieColl then text = text .. string.format("\nCollision version: %d", LouieColl) end

        ----TESTS----

	    SetScreenText(text)
    end
    OldFrame = GetFrameCount()
end

function onStateLoaded()

end

function onStateSaved()

end
