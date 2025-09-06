-- LocalScript - Colocar em StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variáveis do bloco
local blockCharacter = nil
local blockPart = nil
local bodyVelocity = nil
local bodyAngularVelocity = nil
local rotationConnection = nil
local movementConnection = nil
local touchConnections = {}

-- Configurações
local KNOCKBACK_FORCE = 200
local KNOCKBACK_DISTANCE = 5 -- 5 studs
local BLOCK_SIZE = Vector3.new(4, 4, 4)
local MOVEMENT_SPEED = 50
local JUMP_POWER = 50

-- Função para criar a mensagem na tela
local function showMessage()
    -- ScreenGui para a mensagem
    local messageGui = Instance.new("ScreenGui")
    messageGui.Name = "BlockMessage"
    messageGui.Parent = playerGui
    
    -- Frame da mensagem
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(0, 300, 0, 60)
    messageFrame.Position = UDim2.new(0, -320, 1, -80) -- Começa fora da tela (esquerda)
    messageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    messageFrame.BorderSizePixel = 0
    messageFrame.Parent = messageGui
    
    -- Gradiente da mensagem
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
    }
    gradient.Rotation = 45
    gradient.Parent = messageFrame
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = messageFrame
    
    -- Borda brilhante
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 2
    stroke.Parent = messageFrame
    
    -- Ícone do bloco
    local blockIcon = Instance.new("TextLabel")
    blockIcon.Size = UDim2.new(0, 40, 0, 40)
    blockIcon.Position = UDim2.new(0, 10, 0.5, -20)
    blockIcon.BackgroundTransparency = 1
    blockIcon.Text = "🟫"
    blockIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
    blockIcon.TextScaled = true
    blockIcon.Font = Enum.Font.SourceSansBold
    blockIcon.Parent = messageFrame
    
    -- Texto da mensagem
    local messageText = Instance.new("TextLabel")
    messageText.Size = UDim2.new(1, -60, 1, 0)
    messageText.Position = UDim2.new(0, 55, 0, 0)
    messageText.BackgroundTransparency = 1
    messageText.Text = "Agora você é um bloco!"
    messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageText.TextScaled = true
    messageText.Font = Enum.Font.SourceSansBold
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.Parent = messageFrame
    
    -- Animação de entrada (deslizar da esquerda)
    local enterTween = TweenService:Create(messageFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 20, 1, -80)
    })
    enterTween:Play()
    
    -- Animação de pulsação do ícone
    local function pulseIcon()
        local pulseTween = TweenService:Create(blockIcon, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 45, 0, 45),
            Rotation = blockIcon.Rotation + 15
        })
        pulseTween:Play()
        
        pulseTween.Completed:Connect(function()
            local returnTween = TweenService:Create(blockIcon, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 40, 0, 40),
                Rotation = blockIcon.Rotation - 15
            })
            returnTween:Play()
            returnTween.Completed:Connect(pulseIcon)
        end)
    end
    pulseIcon()
    
    -- Aguardar 4 segundos e fazer animação de saída
    wait(4)
    
    local exitTween = TweenService:Create(messageFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0, -320, 1, -80)
    })
    exitTween:Play()
    
    exitTween.Completed:Connect(function()
        messageGui:Destroy()
    end)
end

-- Função para aplicar knockback
local function applyKnockback(hit, hitPart)
    local character = hit.Parent
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Verificar se é um personagem válido e não é o próprio jogador
    if humanoid and humanoidRootPart and character ~= blockCharacter then
        -- Calcular direção do knockback
        local knockbackDirection = (humanoidRootPart.Position - blockPart.Position).Unit
        knockbackDirection = knockbackDirection + Vector3.new(0, 0.5, 0) -- Adicionar componente vertical
        
        -- Aplicar knockback
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVel.Velocity = knockbackDirection * KNOCKBACK_FORCE
        bodyVel.Parent = humanoidRootPart
        
        -- Remover BodyVelocity após um tempo
        game:GetService("Debris"):AddItem(bodyVel, 1)
        
        -- Efeito visual de knockback
        local explosion = Instance.new("Explosion")
        explosion.Position = hitPart.Position
        explosion.BlastRadius = 0
        explosion.BlastPressure = 0
        explosion.Visible = false
        explosion.Parent = workspace
        
        -- Efeito sonoro (opcional)
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://131961136" -- Som de impacto
        sound.Volume = 0.5
        sound.Pitch = 1.2
        sound.Parent = blockPart
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
end

-- Função para criar o bloco personagem
local function createBlockCharacter()
    -- Criar modelo do personagem bloco
    blockCharacter = Instance.new("Model")
    blockCharacter.Name = player.Name .. "_Block"
    blockCharacter.Parent = workspace
    
    -- Criar HumanoidRootPart (invisível, serve como âncora)
    local humanoidRootPart = Instance.new("Part")
    humanoidRootPart.Name = "HumanoidRootPart"
    humanoidRootPart.Size = Vector3.new(0.1, 0.1, 0.1)
    humanoidRootPart.Material = Enum.Material.ForceField
    humanoidRootPart.Transparency = 1
    humanoidRootPart.CanCollide = false
    humanoidRootPart.Anchored = false
    humanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Spawnar no ar
    humanoidRootPart.Parent = blockCharacter
    
    -- Criar Humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.WalkSpeed = 0 -- Não usar sistema de movimento padrão
    humanoid.JumpPower = 0
    humanoid.PlatformStand = true
    humanoid.Parent = blockCharacter
    
    -- Criar o bloco visual
    blockPart = Instance.new("Part")
    blockPart.Name = "BlockPart"
    blockPart.Size = BLOCK_SIZE
    blockPart.Material = Enum.Material.Neon
    blockPart.BrickColor = BrickColor.new("Bright yellow")
    blockPart.Shape = Enum.PartType.Block
    blockPart.CanCollide = false -- Não colide, mas pode tocar
    blockPart.Anchored = false
    blockPart.Parent = blockCharacter
    
    -- Efeito de brilho no bloco
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 2
    pointLight.Color = Color3.fromRGB(255, 215, 0)
    pointLight.Range = 10
    pointLight.Parent = blockPart
    
    -- Weld para conectar o bloco ao HumanoidRootPart
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = humanoidRootPart
    weld.Part1 = blockPart
    weld.Parent = humanoidRootPart
    
    -- BodyVelocity para movimento controlado
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    -- BodyAngularVelocity para rotação contínua
    bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 5, 0) -- Rotação no eixo Y
    bodyAngularVelocity.Parent = blockPart
    
    -- Conectar evento de toque
    local touchConnection = blockPart.Touched:Connect(function(hit)
        applyKnockback(hit, blockPart)
    end)
    table.insert(touchConnections, touchConnection)
    
    -- Definir como personagem do jogador
    player.Character = blockCharacter
    
    -- Aguardar um frame para garantir que tudo está configurado
    wait()
    
    -- Posicionar câmera
    local camera = workspace.CurrentCamera
    camera.CameraSubject = humanoid
end

-- Função para controlar movimento
local function controlMovement()
    movementConnection = RunService.Heartbeat:Connect(function()
        if not blockCharacter or not blockCharacter:FindFirstChild("HumanoidRootPart") or not bodyVelocity then
            return
        end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local moveVector = Vector3.new(0, 0, 0)
        
        -- Controles WASD
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        
        -- Aplicar movimento
        if moveVector.Magnitude > 0 then
            bodyVelocity.Velocity = moveVector.Unit * MOVEMENT_SPEED
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- Função para controlar rotação contínua
local function controlRotation()
    rotationConnection = RunService.Heartbeat:Connect(function()
        if blockPart and bodyAngularVelocity then
            -- Rotação contínua mais complexa
            local time = tick()
            bodyAngularVelocity.AngularVelocity = Vector3.new(
                math.sin(time) * 2,
                5,
                math.cos(time) * 2
            )
        end
    end)
end

-- Função para limpar conexões
local function cleanup()
    if rotationConnection then
        rotationConnection:Disconnect()
        rotationConnection = nil
    end
    if movementConnection then
        movementConnection:Disconnect()
        movementConnection = nil
    end
    for _, connection in pairs(touchConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    touchConnections = {}
end

-- Função principal
local function transformIntoBlock()
    -- Destruir personagem original se existir
    if player.Character then
        player.Character:Destroy()
    end
    
    -- Aguardar um momento
    wait(0.5)
    
    -- Criar novo personagem bloco
    createBlockCharacter()
    
    -- Iniciar controles
    controlMovement()
    controlRotation()
    
    -- Mostrar mensagem (em uma thread separada para não bloquear)
    spawn(showMessage)
end

-- Iniciar transformação
transformIntoBlock()

-- Limpeza quando o script é removido
game:BindToClose(cleanup)

-- Reconectar se o personagem for resetado
player.CharacterRemoving:Connect(function()
    cleanup()
end)

-- Opcional: Atalho para resetar personagem (tecla R)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        cleanup()
        wait(1)
        transformIntoBlock()
    end
end)