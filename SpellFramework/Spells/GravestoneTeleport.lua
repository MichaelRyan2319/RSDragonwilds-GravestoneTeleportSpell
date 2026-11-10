-- Gravestone Teleport: takes you to your gravestone, the spot where you last died.
-- Nothing is cast (and no runes are used) when you have no gravestone in this world.
-- (Dying empties your hotbar and Items tab into the gravestone; you keep your runes.)
--
-- The teleport is the game's own (the one Home Teleport and the lodestones use), so the
-- world around the gravestone is loaded before you arrive.

local LAND_BESIDE = 150   -- you arrive this far from the gravestone (1.5 m), facing it
local LAND_ABOVE = 100    -- and this far above its base, so you land on your feet
local TOO_CLOSE = 500     -- within 5 m of the gravestone the spell does nothing
local CAST_POINT = 3.7    -- seconds into the cast animation at which you vanish

local NO_GRAVESTONE = "Gravestone Teleport: you have no gravestone in this world."

local function GuidText(g)
    return string.format("%08X%08X%08X%08X", g.A & 0xFFFFFFFF, g.B & 0xFFFFFFFF, g.C & 0xFFFFFFFF, g.D & 0xFFFFFFFF)
end

-- Where this character's newest gravestone is ({X, Y, Z}), or nil. The game keeps every
-- gravestone of the world in one list and adds new ones at the end.
local function FindGravestone(sf)
    local found = nil
    pcall(function()
        local mine = GuidText(sf.Controller():GetCharacterGuid().InnerGuid)
        local registry = FindFirstOf("GameplayObjectRegistry")
        local list = registry.Gravestones
        for i = 1, list:GetArrayNum() do
            local grave = list[i]
            if GuidText(grave.OwningCharGuid.InnerGuid) == mine then
                local at = grave.Location
                found = { X = at.X, Y = at.Y, Z = at.Z }
            end
        end
    end)
    return found
end

local function DistanceTo(pawn, grave)
    local ok, d = pcall(function()
        local at = pawn:K2_GetActorLocation()
        return math.sqrt((at.X - grave.X) ^ 2 + (at.Y - grave.Y) ^ 2 + (at.Z - grave.Z) ^ 2)
    end)
    return ok and d or math.huge
end

local function IsTeleporting(pawn)
    local ok, busy = pcall(function() return pawn:IsTeleporting() end)
    return ok and busy == true
end

local function IsDead(pawn)
    local ok, dead = pcall(function() return pawn.HealthComponent:IsDead() end)
    return ok and dead == true
end

-- Whether the cast animation is still the one playing (a hit or a dodge replaces it).
-- Anything that can't be read counts as still casting.
local function StillCasting(pawn)
    local ok, name = pcall(function()
        local montage = pawn.Mesh:GetAnimInstance():GetCurrentActiveMontage()
        if montage and montage:IsValid() then return montage:GetFName():ToString() end
        return ""
    end)
    if not ok then return true end
    return name:find("HomeTeleport", 1, true) ~= nil
end

-- Asks the game to teleport the player. True if the game accepted it.
local function Teleport(pawn, x, y, z, yaw)
    local ok, accepted = pcall(function()
        return pawn:BP_TriggerDelayedTeleport({
            LocationName = FName("None"),
            TargetLocation = { X = x, Y = y, Z = z },
            TargetRotation = { Pitch = 0.0, Yaw = yaw, Roll = 0.0 },
            bShowLoadingScreen = true,
            bVFXOnTeleportStart = false,   -- the cast animation has its own
            bVFXOnTeleportEnd = true,
            bIsATest = false,
            bNoCheck = false,
            TeleportationType = 2,         -- ETeleportationType::HomeTeleport
            TeleportBeginVFXDelayOverride = 0.0,
            bDropAnyLoadoutExclusiveEquipment = true,   -- what the game's teleports do
        })
    end)
    return ok and accepted == true, (not ok) and tostring(accepted) or nil
end

local function GoTo(sf, pawn, grave)
    -- Beside the gravestone, facing it; if the game refuses that spot, on the gravestone.
    local done, err = Teleport(pawn, grave.X + LAND_BESIDE, grave.Y, grave.Z + LAND_ABOVE, 180.0)
    if not done and not err then
        done, err = Teleport(pawn, grave.X, grave.Y, grave.Z + LAND_ABOVE, 180.0)
    end
    if err and sf.Log then sf.Log("Gravestone Teleport: the teleport call failed: %s", err) end
    if not done then sf.Toast("Gravestone Teleport: the game refused the teleport.") end
    return done
end

return {
    id = "gravestone_teleport",
    name = "Gravestone Teleport",
    description = "Teleports you to your gravestone, where you last died. With several gravestones, the newest.",
    icon = "/Game/Art/UI/Icons/Icons_0_10_02/T_Icon_Gravestone",
    base = "HomeTeleport",
    cost = { Law = 5 },
    cooldown = 10,
    castTime = CAST_POINT,
    animation = "manual",   -- look for a gravestone first; the cast animation only plays if there is one

    OnCast = function(sf, ctx)
        local pawn = sf.Player()
        if not pawn or IsDead(pawn) or IsTeleporting(pawn) then return end
        local grave = FindGravestone(sf)
        if not grave then
            sf.Toast(NO_GRAVESTONE)
            return
        end

        -- Spell Framework 1.x has no manual spells: the game has played the whole cast by now.
        if ctx.paid then
            GoTo(sf, pawn, grave)
            return
        end

        if DistanceTo(pawn, grave) < TOO_CLOSE then
            sf.Toast("Gravestone Teleport: your gravestone is right here.")
            return
        end
        local started = os.clock()
        ctx.Cast(function()
            local caster = sf.Player()
            if not caster or IsDead(caster) or IsTeleporting(caster) then return end
            -- (If the animation couldn't be played at all, this runs at once: nothing to interrupt.)
            if os.clock() - started > 1 and not StillCasting(caster) then
                sf.Toast("Gravestone Teleport was interrupted.")
                return
            end
            local target = FindGravestone(sf)
            if not target then
                sf.Toast(NO_GRAVESTONE)
                return
            end
            if GoTo(sf, caster, target) then ctx.Pay() end   -- takes the runes, starts the cooldown
        end)
    end,
}
