-- Server-authoritative combat, attack cooldowns, damage, and knockback.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("CombatAction")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "CombatAction"
    remote.Parent = ReplicatedStorage
end

local ATTACK_RANGE = 12
local ATTACK_DOT_THRESHOLD = 0.35
local ATTACK_DAMAGE = 10
local ATTACK_COOLDOWN = 0.22
local ATTACK_REQUEST_LIMIT = 12
local KNOCKBACK_FORCE = 52
local UPWARD_FORCE = 14
local JUMP_REQUEST_LIMIT = 8
local REQUEST_WINDOW = 1

local attackTimes = {}
local attackRequests = {}
local jumpRequests = {}

local function getRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function isAlive(character)
    local humanoid = getHumanoid(character)
    return humanoid and humanoid.Health > 0 and getRoot(character) ~= nil
end

local function requestAllowed(bucket, player, limit)
    local now = os.clock()
    local data = bucket[player]
    if not data or now - data.startedAt >= REQUEST_WINDOW then
        bucket[player] = { startedAt = now, count = 1 }
        return true
    end

    if data.count >= limit then
        return false
    end

    data.count += 1
    return true
end

local function findTarget(player)
    local character = player.Character
    local attackerRoot = getRoot(character)
    if not isAlive(character) then
        return nil
    end

    local bestHumanoid
    local bestRoot
    local bestDistance = ATTACK_RANGE

    for _, candidate in ipairs(Players:GetPlayers()) do
        if candidate ~= player and candidate.Character and isAlive(candidate.Character) then
            local candidateRoot = getRoot(candidate.Character)
            local offset = candidateRoot.Position - attackerRoot.Position
            local distance = offset.Magnitude
            if distance <= bestDistance and distance > 0 then
                local direction = offset.Unit
                local facing = attackerRoot.CFrame.LookVector:Dot(direction)
                if facing >= ATTACK_DOT_THRESHOLD then
                    bestHumanoid = getHumanoid(candidate.Character)
                    bestRoot = candidateRoot
                    bestDistance = distance
                end
            end
        end
    end

    return bestHumanoid, bestRoot
end

local function attack(player)
    local now = os.clock()
    if now - (attackTimes[player] or 0) < ATTACK_COOLDOWN then
        return
    end
    if not requestAllowed(attackRequests, player, ATTACK_REQUEST_LIMIT) then
        return
    end
    attackTimes[player] = now

    local targetHumanoid, targetRoot = findTarget(player)
    if not targetHumanoid or not targetRoot then
        return
    end

    local attackerRoot = getRoot(player.Character)
    local direction = (targetRoot.Position - attackerRoot.Position).Unit
    targetHumanoid:TakeDamage(ATTACK_DAMAGE)
    targetRoot:ApplyImpulse((direction * KNOCKBACK_FORCE + Vector3.new(0, UPWARD_FORCE, 0)) * targetRoot.AssemblyMass)
end

local function allowJump(player)
    if not requestAllowed(jumpRequests, player, JUMP_REQUEST_LIMIT) then
        return
    end

    local character = player.Character
    local humanoid = getHumanoid(character)
    local root = getRoot(character)
    if not humanoid or humanoid.Health <= 0 or not root then
        return
    end

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    root:ApplyImpulse(Vector3.new(0, root.AssemblyMass * humanoid.JumpPower, 0))
end

remote.OnServerEvent:Connect(function(player, action)
    if action == "Attack" then
        attack(player)
    elseif action == "Jump" then
        allowJump(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    attackTimes[player] = nil
    attackRequests[player] = nil
    jumpRequests[player] = nil
end)
