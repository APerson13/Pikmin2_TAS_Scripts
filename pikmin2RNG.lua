---@diagnostic disable: lowercase-global
---@diagnostic disable: undefined-global
local pikmin2RNG = {}

---- Malleo's RNG Code ----
-- Massive thanks to Malleo for helping me out with this.
local slope = 0x41c64e6d
local constant = 0x3039
local intLimit = 0x100000000

local powers = {
    1,
    2,
    4,
    8,
    16,
    32,
    64,
    128,
    256,
    512,
    1024,
    2048,
    4096,
    8192,
    16384,
    32768,
    65536,
    131072,
    262144,
    524288,
    1048576,
    2097152,
    4194304,
    8388608,
    16777216,
    33554432,
    67108864,
    134217728,
    268435456,
    536870912,
    1073741824,
    2147483648
}

local function powmod(m, n, q) -- b^n mod q, computed by repeated squaring
	if n == 0 then
		return 1
	else
		local factor1 = powmod(m, math.floor(n/2), q)
		local factor2 = 1
		if n%2 == 1 then
			factor2 = m
		end
		return (factor1 * factor1 * factor2)% q
	end
end

local function v2(a) -- The 2-adic valuation of a (that is, the largest integer v such that 2^v divides a)
    if a == 0 then
        return 1000000
	end
    local n = a
    local v = 0
    while n % 2 == 0 do
        n = math.floor(n/2)
        v = v+1
	end
    return v
end

local function inv(w) -- modular inverse of w modulo q (assuming w is odd)
    return powmod(w, math.floor(intLimit/2) - 1, intLimit)
end

local function rnginverse(r) -- Given an RNG value r, compute the unique x in range [0, 2^32) such that rng(x) = r.
    local xpow = (r * 4 * math.floor((slope-1)/4) * inv(constant) + 1) % (4*intLimit) -- Recover m^x mod 4q from algebra (inverting steps in rng function above)
    local xguess = 0
    for i,p in ipairs(powers) do -- Guess binary digits of x one by one
        -- Technique is based on Mihai's lemma / lifting the exponent
        if v2(powmod(slope, xguess + p, 4*intLimit) - xpow) > v2(powmod(slope, xguess, 4*intLimit) - xpow) then
            xguess = xguess + p
		end
	end
    return xguess
end

-- Uses Malleo's RNG index functions
function pikmin2RNG.RngCalls(oldSeed, newSeed)
    if newSeed and oldSeed then
        return rnginverse(newSeed) - rnginverse(oldSeed)
    end
    return nil
end

return pikmin2RNG