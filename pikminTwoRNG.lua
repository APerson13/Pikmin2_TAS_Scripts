local pikminTwoRNG = {}

---- Malleo's RNG Code ----
-- Massive thanks to Malleo for helping me out with this.
m = 0x41c64e6d
b = 0x3039
q = 0x100000000
powers = {
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

function powmod(m, n, q) -- b^n mod q, computed by repeated squaring
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

function v2(a) -- The 2-adic valuation of a (that is, the largest integer v such that 2^v divides a)
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

function inv(w) -- modular inverse of w modulo q (assuming w is odd)
    return powmod(w, math.floor(q/2) - 1, q)
end

function rnginverse(r) -- Given an RNG value r, compute the unique x in range [0, 2^32) such that rng(x) = r.
    local xpow = (r * 4 * math.floor((m-1)/4) * inv(b) + 1) % (4*q) -- Recover m^x mod 4q from algebra (inverting steps in rng function above)
    local xguess = 0
    for i,p in ipairs(powers) do -- Guess binary digits of x one by one
        -- Technique is based on Mihai's lemma / lifting the exponent
        if v2(powmod(m, xguess + p, 4*q) - xpow) > v2(powmod(m, xguess, 4*q) - xpow) then
            xguess = xguess + p
		end
	end
    return xguess
end

return pikminTwoRNG