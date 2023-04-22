local pikmin2Common = {}

-- Returns a table containing zero-initialized x, y, and z fields.
local function vector3f()
    return {
        x = nil,
        y = nil,
        z = nil
    }
end

-- checks if an object is in valid memory range.
local function validatePtr(ptr)
    if ptr > 0x80000000 and ptr < 0x817ffff0 then
        return true
    end
    return false
end

-- copies a vector3f elementwise into a returned table.
local function vector3fCopy(vector)
    local newVector = {}
    newVector.x = vector.x
    newVector.y = vector.y
    newVector.z = vector.z
    return newVector
end

-- Function by LuigiM
-- Gets around weird behaviour of Dolphin Lua Core's "read float" function.
local function floatHack(intVal)
    return string.unpack("f", string.pack("I4", intVal))
end

-- Given the address of the beginning of the vector,
-- puts the contents of the vector from memory into the provided vector3f.
local function readVector3f(ptr, vector)
    vector.x = floatHack(ReadValue32(ptr))
    vector.y = floatHack(ReadValue32(ptr+4))
    vector.z = floatHack(ReadValue32(ptr+8))
end

pikmin2Common.isDemo = false
pikmin2Common.RNGPtr = 0x805147e0

local MoviePlayerPtrPtr = 0x80516114
local NaviMgrPtr = 0x805158a0

pikmin2Common.NaviStateIDs = {
    [0]="walk",
    [1]="follow",
    [2]="punch",
    [3]="change",
    [4]="gather",
    [5]="throw",
    [6]="throw wait", --not sure
    [7]="dope",
    [8]="pluck",
    [9]="pluck adjust",
    [10]="container",
    [11]="absorb",
    [12]="flick",
    [13]="damaged",
    [14]="pressed",
    [15]="fall meck",
    [16]="koke damage",
    [17]="snitchbug",
    [18]="snitchbug exit",
    [19]="dead",
    [20]="stuck",
    [21]="demo ufo",
    [22]="demo hole",
    [23]="pellet",
    [24]="carry bomb",
    [25]="climb",
    [26]="path move"
}

-- updated by naviObjects --
pikmin2Common.OldOlimarPos = vector3f()
pikmin2Common.OldLouiePos  = vector3f()
pikmin2Common.OlimarPos    = vector3f()
pikmin2Common.LouiePos     = vector3f()
pikmin2Common.OlimarVel    = vector3f()
pikmin2Common.LouieVel     = vector3f()

-- Run this to get info about the current game version.
function pikmin2Common.Initialize() -- bro i dont understand lua
    local GameID = GetGameID() -- string
	if (GameID ~= "GPVE01") and (GameID ~= "PIKE51") and (GameID ~= "GPVJ01") then
		SetScreenText("")
		CancelScript()
    --This just tests a random instruction offset in US Demo 1 that doesn't have any nearby similar instructions in US Final.
    elseif (GameID == "GPVE01" or GameID == "PIKE51") and ReadValue32(0x80471828) == 0x9421fb70 then
        pikmin2Common.isDemo = true
    elseif GameID == "GPVE01" then
        MoviePlayerPtrPtr = MoviePlayerPtrPtr + 0xc0
        pikmin2Common.RNGPtr = pikmin2Common.RNGPtr + 0xc8
        NaviMgrPtr = NaviMgrPtr + 0xc0
    elseif GameID == "GPVJ01" then
        MoviePlayerPtrPtr = MoviePlayerPtrPtr + 0x1bc0
        pikmin2Common.RNGPtr = pikmin2Common.RNGPtr + 0x1bc8
        NaviMgrPtr = NaviMgrPtr + 0x1bc0
    end
end

-- Given the old position and new position of something as 3d vectors,
-- returns the average velocity over the past frame in units per second.
-- Assumes oldPos and pos were measured one frame (1s/30) apart.
--
-- In addition to xyz vector components, the returned vector has a xz field
-- with the norm of the horizontal velocity.
function pikmin2Common.Velocity(oldPos, pos)
    -- deltaT = 1/30 s
    -- so 1/deltaT = 30/s
    if pos.x and oldPos.x then
        velocity = {
            x = 30*(pos.x-oldPos.x),
            y = 30*(pos.y-oldPos.y),
            z = 30*(pos.z-oldPos.z)
        }
        velocity.xz = math.sqrt(velocity.x*velocity.x+velocity.z*velocity.z)
        return velocity -- i love lua
    end
    return vector3f()   -- i hate lua
end

-- Given the beginning of a navimgr,
-- update various values relating to the navi objects within.
function pikmin2Common.naviObjects()
    local navimgr = ReadValue32(NaviMgrPtr)
    if validatePtr(navimgr) then
        local NaviOne = ReadValue32(navimgr+0x28)
        local NaviTwo = NaviOne + 0x320

        if validatePtr(NaviOne) then
            -- the game breaks entirely if only one navi exists
            -- so only validate NaviOne

            pikmin2Common.OldOlimarPos = vector3fCopy(pikmin2Common.OlimarPos)
            pikmin2Common.OldLouiePos = vector3fCopy(pikmin2Common.LouiePos)

            readVector3f(NaviOne+0x20c, pikmin2Common.OlimarPos)
            readVector3f(NaviTwo+0x20c, pikmin2Common.LouiePos)

            pikmin2Common.OlimarVel = pikmin2Common.Velocity(pikmin2Common.OldOlimarPos, pikmin2Common.OlimarPos)
            pikmin2Common.LouieVel = pikmin2Common.Velocity(pikmin2Common.OldLouiePos, pikmin2Common.LouiePos)

            local OlimarCurrTri = ReadValue32(NaviOne + 0xc8)
            local LouieCurrTri = ReadValue32(NaviTwo + 0xc8)

            if validatePtr(OlimarCurrTri) then
                pikmin2Common.OlimarColl = ReadValue8(OlimarCurrTri + 0x5c) >> 4
            end

            if validatePtr(LouieCurrTri) then
                pikmin2Common.LouieColl = ReadValue8(LouieCurrTri + 0x5c) >> 4
            end

            local OlimarStateObj = ReadValue32(NaviOne + 0x274)
            local LouieStateObj = ReadValue32(NaviTwo + 0x274)

            if validatePtr(OlimarStateObj) then
                pikmin2Common.OlimarStateID = ReadValue32(OlimarStateObj+4)
            end

            if validatePtr(LouieStateObj) then
                pikmin2Common.LouieStateID = ReadValue32(LouieStateObj+4)
            end
        end
    end
end

-- updates DemoState
function pikmin2Common.movieState()
    local MoviePlayerPtr = ReadValue32(MoviePlayerPtrPtr)
    if validatePtr(MoviePlayerPtr) then
        pikmin2Common.DemoState = ReadValue32(MoviePlayerPtr + 0x18)
    end
end

return pikmin2Common
