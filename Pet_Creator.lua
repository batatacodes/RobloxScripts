-- LocalScript para criar um Pet apenas para o jogador local

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer -- O jogador que este script está executando

-- Configurações do Pet
local PET_NAME = "Meu Pet Pessoal" -- Nome do pet para o jogador local
local PET_BODY_SIZE = Vector3.new(2, 2, 2)
local PET_COLOR = Color3.fromRGB(0, 150, 255) -- Azul brilhante
local WING_SIZE = Vector3.new(0.3, 1.5, 2.5)
local WING_OFFSET_X = 1.5
local WING_ANGLE = math.rad(45)
local LABEL_TEXT_COLOR = Color3.fromRGB(255, 255, 0) -- Amarelo
local LABEL_OFFSET_Y = 2.5

-- Configurações de Seguimento
local FOLLOW_DISTANCE = 7
local FLOAT_HEIGHT = 4
local SMOOTHNESS = 0.1

-- Função principal para criar o pet localmente
local function createLocalPet()
    -- Garante que temos um jogador e um personagem
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Jogador local ou personagem não encontrado, não é possível criar o pet.")
        return
    end

    -- Cria o modelo base do pet
    local petModel = Instance.new("Model")
    petModel.Name = LocalPlayer.Name .. "'s LocalPet"
    -- Coloca o pet no workspace, mas como é um LocalScript, só existirá para este cliente
    petModel.Parent = workspace 

    -- 1. Cria o corpo do pet (Quadrado)
    local bodyPart = Instance.new("Part")
    bodyPart.Name = "Body"
    bodyPart.Shape = Enum.PartType.Block
    bodyPart.Size = PET_BODY_SIZE
    bodyPart.Color = PET_COLOR
    bodyPart.Material = Enum.Material.Neon
    bodyPart.CanCollide = false
    bodyPart.Anchored = false
    bodyPart.Parent = petModel

    -- 2. Cria as asas
    local function createWing(parentPart, offsetX, rotationY)
        local wing = Instance.new("Part")
        wing.Name = "Wing"
        wing.Shape = Enum.PartType.Block
        wing.Size = WING_SIZE
        wing.Color = PET_COLOR
        wing.Material = Enum.Material.Neon
        wing.CanCollide = false
        wing.Anchored = false
        wing.Parent = petModel

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = parentPart
        weld.Part1 = wing
        weld.Parent = parentPart

        wing.CFrame = parentPart.CFrame * CFrame.new(offsetX, 0, 0) * CFrame.fromEulerAnglesXYZ(0, rotationY, 0)
        return wing
    end

    createWing(bodyPart, -WING_OFFSET_X, WING_ANGLE)
    createWing(bodyPart, WING_OFFSET_X, -WING_ANGLE)

    -- 3. Cria a label do nome
    local nameBillboardGui = Instance.new("BillboardGui")
    nameBillboardGui.Name = "PetNameTag"
    nameBillboardGui.AlwaysOnTop = true
    nameBillboardGui.Size = UDim2.new(5, 0, 2, 0)
    nameBillboardGui.StudsOffset = Vector3.new(0, LABEL_OFFSET_Y, 0)
    nameBillboardGui.Parent = bodyPart

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Text = LocalPlayer.Name .. "'s " .. PET_NAME
    nameLabel.TextColor3 = LABEL_TEXT_COLOR
    nameLabel.TextScaled = true
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.Parent = nameBillboardGui

    -- 4. Lógica para o pet seguir o jogador local
    local function followPlayer()
        local character = LocalPlayer.Character
        local humanRootPart = character and character:FindFirstChild("HumanoidRootPart")

        if humanRootPart then
            local targetPosition = humanRootPart.CFrame * CFrame.new(0, FLOAT_HEIGHT, -FOLLOW_DISTANCE)
            bodyPart.CFrame = bodyPart.CFrame:Lerp(targetPosition, SMOOTHNESS)
        end
    end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        -- Se o jogador local ou o personagem não existirem mais, ou se o pet foi destruído
        if not LocalPlayer or not LocalPlayer.Character or not bodyPart.Parent then
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if petModel and petModel.Parent then
                petModel:Destroy() -- Garante que o pet seja removido se o jogador sair
            end
            return
        end
        followPlayer()
    end)
end

-- Espera o personagem do jogador local ser carregado para criar o pet
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Pequeno atraso para garantir que o HumanoidRootPart esteja pronto
    task.wait(0.5) 
    createLocalPet()
end)

-- Se o jogador já tiver um personagem ao entrar no jogo (ex: re-spawns rápidos no Studio)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    task.wait(0.5)
    createLocalPet()
end