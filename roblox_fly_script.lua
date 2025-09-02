-- LocalScript - Colocar em StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Variáveis de controle
local flyEnabled = false
local gui = nil
local toggleButton = nil
local bodyVelocity = nil
local bodyAngularVelocity = nil
local flyConnection = nil
local flySpeed = 50 -- Velocidade do voo

-- Função para criar a GUI
local function createGUI()
    -- ScreenGui principal
    gui = Instance.new("ScreenGui")
    gui.Name = "FlyGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Frame principal (lado direito da tela)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 120)
    mainFrame.Position = UDim2.new(1, -230, 0.5, -60)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 127)
    mainFrame.Parent = gui
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Efeito de brilho
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 127)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🚀 FLY SYSTEM"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Botão Toggle
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.85, 0, 0, 45)
    toggleButton.Position = UDim2.new(0.075, 0, 0, 40)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
    toggleButton.Text = "DESATIVADO"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Parent = mainFrame
    
    -- Cantos arredondados do botão
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = toggleButton
    
    -- Efeito de hover no botão
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Thickness = 0
    buttonStroke.Transparency = 0.8
    buttonStroke.Parent = toggleButton
    
    -- Status e controles
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, 0, 0, 18)
    statusLabel.Position = UDim2.new(0, 0, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Inativo | Vel: " .. flySpeed
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame
    
    -- Controles info
    local controlsLabel = Instance.new("TextLabel")
    controlsLabel.Name = "Controls"
    controlsLabel.Size = UDim2.new(1, 0, 0, 12)
    controlsLabel.Position = UDim2.new(0, 0, 1, -15)
    controlsLabel.BackgroundTransparency = 1
    controlsLabel.Text = "Tecla F para Toggle | Mouse para direção"
    controlsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    controlsLabel.TextScaled = true
    controlsLabel.Font = Enum.Font.SourceSans
    controlsLabel.Parent = mainFrame
end

-- Função para criar os objetos de voo
local function createFlyObjects()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    
    -- BodyVelocity para controlar movimento
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    -- BodyAngularVelocity para estabilidade
    bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    bodyAngularVelocity.Parent = humanoidRootPart
    
    return true
end

-- Função para limpar objetos de voo
local function cleanupFlyObjects()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyAngularVelocity then
        bodyAngularVelocity:Destroy()
        bodyAngularVelocity = nil
    end
end

-- Função principal do voo
local function flyLoop()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local camera = workspace.CurrentCamera
    
    if not camera then return end
    
    -- Obter direção da câmera (onde o jogador está olhando)
    local cameraCFrame = camera.CFrame
    local lookDirection = cameraCFrame.LookVector
    
    -- Calcular velocidade baseada na direção da câmera
    local targetVelocity = lookDirection * flySpeed
    
    -- Verificar entrada do teclado para controles adicionais
    local moveVector = Vector3.new(0, 0, 0)
    
    -- WASD para controle adicional
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + lookDirection
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector - lookDirection
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector - cameraCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + cameraCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    
    -- Se há input do teclado, usar isso; senão, voar na direção da câmera
    if moveVector.Magnitude > 0 then
        targetVelocity = moveVector.Unit * flySpeed
    end
    
    -- Aplicar velocidade suavemente
    if bodyVelocity then
        bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(targetVelocity, 0.3)
    end
    
    -- Fazer o personagem olhar na direção do movimento (opcional)
    if targetVelocity.Magnitude > 0 then
        local lookDirection2D = Vector3.new(targetVelocity.X, 0, targetVelocity.Z).Unit
        if lookDirection2D.Magnitude > 0 then
            local targetCFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + lookDirection2D)
            humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetCFrame, 0.1)
        end
    end
end

-- Função para ativar/desativar fly
local function toggleFly()
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        -- Ativar fly
        if createFlyObjects() then
            toggleButton.BackgroundColor3 = Color3.fromRGB(65, 255, 65)
            toggleButton.Text = "ATIVADO"
            gui.MainFrame.Status.Text = "Status: Voando | Vel: " .. flySpeed
            gui.MainFrame.Status.TextColor3 = Color3.fromRGB(65, 255, 65)
            gui.MainFrame.UIStroke.Color = Color3.fromRGB(65, 255, 65)
            
            -- Conectar o loop de voo
            flyConnection = RunService.Heartbeat:Connect(flyLoop)
            
            -- Desabilitar gravidade
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.PlatformStand = true
            end
        else
            flyEnabled = false
        end
    else
        -- Desativar fly
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
        toggleButton.Text = "DESATIVADO"
        gui.MainFrame.Status.Text = "Status: Inativo | Vel: " .. flySpeed
        gui.MainFrame.Status.TextColor3 = Color3.fromRGB(255, 65, 65)
        gui.MainFrame.UIStroke.Color = Color3.fromRGB(0, 255, 127)
        
        -- Desconectar o loop de voo
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        -- Limpar objetos de voo
        cleanupFlyObjects()
        
        -- Reabilitar gravidade
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end
end

-- Função chamada quando o personagem spawna
local function onCharacterAdded(character)
    character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid")
    
    -- Se fly estava ativo, desativar e limpar
    if flyEnabled then
        flyEnabled = false
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        cleanupFlyObjects()
        
        -- Atualizar GUI
        if gui and toggleButton then
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
            toggleButton.Text = "DESATIVADO"
            gui.MainFrame.Status.Text = "Status: Inativo | Vel: " .. flySpeed
            gui.MainFrame.Status.TextColor3 = Color3.fromRGB(255, 65, 65)
        end
    end
end

-- Função para efeitos visuais do botão
local function setupButtonEffects()
    toggleButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 2})
        tween:Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 0})
        tween:Play()
    end)
end

-- Inicialização
createGUI()
setupButtonEffects()

-- Conectar eventos
toggleButton.MouseButton1Click:Connect(toggleFly)

-- Atalho de teclado (tecla F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- Reconectar quando o jogador spawna
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Limpar quando o script é removido
game:BindToClose(function()
    if flyConnection then
        flyConnection:Disconnect()
    end
    cleanupFlyObjects()
end)