-- pikmin 2 helper library imports --
package.path = GetScriptsDir() .. "pikmin2RNG.lua"
local p2Rng = require("pikmin2RNG")

package.path = GetScriptsDir() .. "Pikmin2Common.lua"
local p2Cmn = require("pikmin2Common")

-- full script-scope variables --
local OldFrame
local OldRNG
local RNG
local FrameRNGCalls
local BaseRNG

-- helper functions --
-- checks if an object is in valid memory range.
local function validatePtr(ptr)
    if ptr > 0x80000000 and ptr < 0x817ffff0 then
        return true
    end
    return false
end

-- the part lua core cares about --

function onScriptStart()
    p2Cmn.Initialize()
end

function onScriptCancel()
    SetScreenText("")
end

function onScriptUpdate()
    if OldFrame ~= GetFrameCount() then

        -- RNG
        OldRNG = RNG
        if validatePtr(p2Cmn.RNGPtr) then
            RNG = ReadValue32(p2Cmn.RNGPtr)
        end

        if RNG and OldRNG then
            FrameRNGCalls = p2Rng.RngCalls(OldRNG, RNG)
        end

        if FrameRNGCalls and FrameRNGCalls < 0 and FrameRNGCalls > -1000000 then
            BaseRNG = RNG
        end

        if BaseRNG then
            StateRNGCalls = p2Rng.RngCalls(BaseRNG, RNG)
        end

        -- update demostate
        p2Cmn.movieState()

        -- update navi object things
        p2Cmn.naviObjects()

        -- print things
        local text = "\n"
        if IsDemo then
            text = text .. "Version: US Demo 1\n"
        elseif GetGameID() == "GPVE01" then
            text = text .. "Version: US Final\n"
        elseif GetGameID() == "GPVJ01" then
            text = text .. "Version: JPN\n"
        end

        text = text .. string.format("\n===RNG===\nSeed on this frame: 0x%08X\n", RNG)
        if FrameRNGCalls then
            text = text .. string.format("Calls since last frame: %d\n", FrameRNGCalls)
        end
        if BaseRNG then
            text = text .. string.format("Calls since state loaded: %d\n", StateRNGCalls)
        end

        if p2Cmn.DemoState then
            text = text .. string.format(
                "\n===Cutscenes===\nDemo state: %d\n(A nonzero demo state implies button lockout.)\n",
                p2Cmn.DemoState)
        end

        text = text .. "\n===Positions and Velocities===\n"
        -- for the vectors we assume that the x field existing implies all fields exist.
        if p2Cmn.OlimarPos.x then
            text = text .. string.format(
                "Olimar:\nPosition: x = %.5f|y = %.5f|z = %.5f\n",
                p2Cmn.OlimarPos.x,p2Cmn.OlimarPos.y,p2Cmn.OlimarPos.z
            )
        end
        if p2Cmn.OlimarVel.x then
            text = text .. string.format(
                "Velocity: x = %.5f|y = %.5f|z = %.5f\n",
                p2Cmn.OlimarVel.x,p2Cmn.OlimarVel.y,p2Cmn.OlimarVel.z
            )
            text = text .. string.format("         xz = %.5f\n", p2Cmn.OlimarVel.xz)
        end
        if p2Cmn.OlimarColl then
            text = text .. string.format("Collision version: %d\n", p2Cmn.OlimarColl)
        end
        if p2Cmn.OlimarStateID and p2Cmn.NaviStateIDs[p2Cmn.OlimarStateID] then
            text = text .. "State: " .. p2Cmn.NaviStateIDs[p2Cmn.OlimarStateID] .. "\n"
        end

        if p2Cmn.LouiePos.x then
            text = text .. string.format(
                "\nLouie:\nPosition: x = %.5f|y = %.5f|z = %.5f\n",
                p2Cmn.LouiePos.x,p2Cmn.LouiePos.y,p2Cmn.LouiePos.z
            )
        end
        if p2Cmn.LouieVel.x then
            text = text .. string.format(
                "Velocity: x = %.5f|y = %.5f|z = %.5f\n",
                p2Cmn.LouieVel.x,p2Cmn.LouieVel.y,p2Cmn.LouieVel.z
            )
            text = text .. string.format("         xz = %.5f\n", p2Cmn.LouieVel.xz)
        end
        if p2Cmn.LouieColl then
            text = text .. string.format("Collision version: %d\n", p2Cmn.LouieColl)
        end
        if p2Cmn.LouieStateID and p2Cmn.NaviStateIDs[p2Cmn.LouieStateID] then
            text = text .. "State: " .. p2Cmn.NaviStateIDs[p2Cmn.LouieStateID] .. "\n"
        end

        SetScreenText(text)
    end
    OldFrame = GetFrameCount()
end

function onStateLoaded()
end

function onStateSaved()
end