-- LocalScript - Colocar em StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variáveis de controle
local speedBoostEnabled = false
local gui = nil
local toggleButton = nil
local originalWalkSpeed = 16 -- Velocidade padrão do Roblox
local boostedWalkSpeed = originalWalkSpeed * 1.75 -- 75% de aumento

-- Função para criar a GUI
local function createGUI()
    -- ScreenGui principal
    gui = Instance.new("ScreenGui")
    gui.Name = "SpeedBoostGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Frame principal (topo da tela, centro)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 70)
    mainFrame.Position = UDim2.new(0.5, -140, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- Gradiente de fundo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
    }
    gradient.Rotation = 90
    gradient.Parent = mainFrame
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Borda brilhante
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 140, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame
    
    -- Sombra
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, -4)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow
    
    -- Ícone de velocidade
    local speedIcon = Instance.new("TextLabel")
    speedIcon.Name = "SpeedIcon"
    speedIcon.Size = UDim2.new(0, 40, 0, 40)
    speedIcon.Position = UDim2.new(0, 15, 0.5, -20)
    speedIcon.BackgroundTransparency = 1
    speedIcon.Text = "⚡"
    speedIcon.TextColor3 = Color3.fromRGB(255, 140, 0)
    speedIcon.TextScaled = true
    speedIcon.Font = Enum.Font.SourceSansBold
    speedIcon.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 120, 0, 25)
    titleLabel.Position = UDim2.new(0, 60, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SPEED BOOST"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 120, 0, 18)
    statusLabel.Position = UDim2.new(0, 60, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Velocidade: Normal"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Botão Toggle
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 80, 0, 50)
    toggleButton.Position = UDim2.new(1, -90, 0.5, -25)
    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 38, 127)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Parent = mainFrame
    
    -- Cantos arredondados do botão
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = toggleButton
    
    -- Efeito de brilho no botão
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Thickness = 0
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = toggleButton
    
    -- Indicador de velocidade (barra)
    local speedBar = Instance.new("Frame")
    speedBar.Name = "SpeedBar"
    speedBar.Size = UDim2.new(0, 3, 0.6, 0)
    speedBar.Position = UDim2.new(0, 5, 0.2, 0)
    speedBar.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    speedBar.BorderSizePixel = 0
    speedBar.Parent = mainFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = speedBar
    
    -- Instruções (aparece ao hover)
    local instructLabel = Instance.new("TextLabel")
    instructLabel.Name = "Instructions"
    instructLabel.Size = UDim2.new(1, 0, 0, 15)
    instructLabel.Position = UDim2.new(0, 0, 1, 5)
    instructLabel.BackgroundTransparency = 1
    instructLabel.Text = "Tecla V para toggle rápido"
    instructLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    instructLabel.TextScaled = true
    instructLabel.Font = Enum.Font.SourceSans
    instructLabel.TextTransparency = 1
    instructLabel.Parent = mainFrame
end

-- Função para aplicar velocidade
local function applySpeed()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if speedBoostEnabled then
        humanoid.WalkSpeed = boostedWalkSpeed
    else
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Função para toggle do speed boost
local function toggleSpeedBoost()
    speedBoostEnabled = not speedBoostEnabled
    
    if speedBoostEnabled then
        -- Ativar speed boost
        toggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        toggleButton.Text = "ON"
        gui.MainFrame.Status.Text = "Velocidade: +75% ⚡"
        gui.MainFrame.Status.TextColor3 = Color3.fromRGB(46, 204, 113)
        gui.MainFrame.UIStroke.Color = Color3.fromRGB(46, 204, 113)
        gui.MainFrame.SpeedIcon.TextColor3 = Color3.fromRGB(46, 204, 113)
        gui.MainFrame.SpeedBar.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        
        -- Efeito visual da barra de velocidade
        local barTween = TweenService:Create(gui.MainFrame.SpeedBar, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
            Size = UDim2.new(0, 3, 1, 0)
        })
        barTween:Play()
        
    else
        -- Desativar speed boost
        toggleButton.BackgroundColor3 = Color3.fromRGB(220, 38, 127)
        toggleButton.Text = "OFF"
        gui.MainFrame.Status.Text = "Velocidade: Normal"
        gui.MainFrame.Status.TextColor3 = Color3.fromRGB(180, 180, 180)
        gui.MainFrame.UIStroke.Color = Color3.fromRGB(255, 140, 0)
        gui.MainFrame.SpeedIcon.TextColor3 = Color3.fromRGB(255, 140, 0)
        gui.MainFrame.SpeedBar.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        
        -- Efeito visual da barra de velocidade
        local barTween = TweenService:Create(gui.MainFrame.SpeedBar, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 3, 0.6, 0)
        })
        barTween:Play()
    end
    
    -- Aplicar a velocidade
    applySpeed()
    
    -- Efeito de pulso no ícone
    local pulseTween = TweenService:Create(gui.MainFrame.SpeedIcon, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
        Size = UDim2.new(0, 45, 0, 45)
    })
    pulseTween:Play()
    
    pulseTween.Completed:Connect(function()
        local returnTween = TweenService:Create(gui.MainFrame.SpeedIcon, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 40, 0, 40)
        })
        returnTween:Play()
    end)
end

-- Função chamada quando personagem spawna
local function onCharacterAdded(character)
    character:WaitForChild("Humanoid")
    
    -- Aguardar um pouco para garantir que tudo carregou
    wait(0.5)
    
    -- Detectar velocidade original do jogo (pode variar)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and not speedBoostEnabled then
        originalWalkSpeed = humanoid.WalkSpeed
        boostedWalkSpeed = originalWalkSpeed * 1.75
    end
    
    -- Aplicar velocidade atual
    applySpeed()
end

-- Função para efeitos visuais
local function setupEffects()
    -- Efeito hover no botão
    toggleButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 2})
        hoverTween:Play()
        
        local scaleTween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 85, 0, 52)})
        scaleTween:Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        local hoverTween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 0})
        hoverTween:Play()
        
        local scaleTween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 80, 0, 50)})
        scaleTween:Play()
    end)
    
    -- Mostrar instruções ao hover na interface
    gui.MainFrame.MouseEnter:Connect(function()
        local instructTween = TweenService:Create(gui.MainFrame.Instructions, TweenInfo.new(0.3), {TextTransparency = 0})
        instructTween:Play()
    end)
    
    gui.MainFrame.MouseLeave:Connect(function()
        local instructTween = TweenService:Create(gui.MainFrame.Instructions, TweenInfo.new(0.3), {TextTransparency = 1})
        instructTween:Play()
    end)
    
    -- Animação de entrada da GUI
    gui.MainFrame.Position = UDim2.new(0.5, -140, 0, -100)
    local entranceTween = TweenService:Create(gui.MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 0, 20)
    })
    entranceTween:Play()
end

-- Função para animação do ícone (loop contínuo quando ativo)
local function animateIcon()
    if speedBoostEnabled then
        local rotateTween = TweenService:Create(gui.MainFrame.SpeedIcon, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
            Rotation = gui.MainFrame.SpeedIcon.Rotation + 360
        })
        rotateTween:Play()
        
        rotateTween.Completed:Connect(function()
            if speedBoostEnabled then
                animateIcon()
            else
                gui.MainFrame.SpeedIcon.Rotation = 0
            end
        end)
    end
end

-- Inicialização
createGUI()
setupEffects()

-- Conectar eventos
toggleButton.MouseButton1Click:Connect(function()
    toggleSpeedBoost()
    if speedBoostEnabled then
        animateIcon()
    end
end)

-- Atalho de teclado (tecla V)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        toggleSpeedBoost()
        if speedBoostEnabled then
            animateIcon()
        end
    end
end)

-- Conectar eventos de personagem
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Monitorar mudanças na velocidade (anti-reset)
spawn(function()
    while true do
        wait(1)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local expectedSpeed = speedBoostEnabled and boostedWalkSpeed or originalWalkSpeed
            
            if math.abs(humanoid.WalkSpeed - expectedSpeed) > 0.1 then
                applySpeed()
            end
        end
    end
end)