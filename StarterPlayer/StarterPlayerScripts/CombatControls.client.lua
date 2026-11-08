-- Player controls for the combat mechanics.
-- Hold F to auto-attack. Press Space while airborne to jump again.

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local combatAction = ReplicatedStorage:WaitForChild("CombatAction")
local AUTO_ATTACK_INTERVAL = 0.24

local autoAttacking = false
local lastAttack = 0
local character
local humanoid

local function updateCharacter(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
end

local function requestAttack()
    local now = os.clock()
    if now - lastAttack < AUTO_ATTACK_INTERVAL then
        return
    end
    lastAttack = now
    combatAction:FireServer("Attack")
end

local function requestExtraJump()
    if humanoid and humanoid.Health > 0 and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        combatAction:FireServer("Jump")
    end
end

if game.Players.LocalPlayer.Character then
    updateCharacter(game.Players.LocalPlayer.Character)
end

game.Players.LocalPlayer.CharacterAdded:Connect(updateCharacter)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F then
        autoAttacking = true
        requestAttack()
    elseif input.KeyCode == Enum.KeyCode.Space then
        requestExtraJump()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        autoAttacking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if autoAttacking then
        requestAttack()
    end
end)
