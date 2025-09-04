-- LocalScript - Colocar em StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variáveis de controle
local noclipEnabled = false
local windowOpen = true
local gui = nil
local mainWindow = nil
local toggleButton = nil
local windowToggleButton = nil
local noclipConnection = nil

-- Função para criar a GUI
local function createGUI()
    -- ScreenGui principal
    gui = Instance.new("ScreenGui")
    gui.Name = "NoclipWindowGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Botão para abrir/fechar janela (lado direito da tela)
    windowToggleButton = Instance.new("TextButton")
    windowToggleButton.Name = "WindowToggle"
    windowToggleButton.Size = UDim2.new(0, 60, 0, 60)
    windowToggleButton.Position = UDim2.new(1, -80, 0.5, -30)
    windowToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    windowToggleButton.BorderSizePixel = 0
    windowToggleButton.Text = "👻"
    windowToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    windowToggleButton.TextScaled = true
    windowToggleButton.Font = Enum.Font.SourceSansBold
    windowToggleButton.Parent = gui
    
    -- Cantos arredondados do botão de janela
    local windowButtonCorner = Instance.new("UICorner")
    windowButtonCorner.CornerRadius = UDim.new(0.5, 0)
    windowButtonCorner.Parent = windowToggleButton
    
    -- Efeito de brilho no botão
    local windowButtonStroke = Instance.new("UIStroke")
    windowButtonStroke.Color = Color3.fromRGB(138, 43, 226)
    windowButtonStroke.Thickness = 2
    windowButtonStroke.Parent = windowToggleButton
    
    -- Janela principal (centro da tela)
    mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = UDim2.new(0, 350, 0, 200)
    mainWindow.Position = UDim2.new(0.5, -175, 0.5, -100)
    mainWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainWindow.BorderSizePixel = 0
    mainWindow.Parent = gui
    
    -- Sombra da janela
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.ZIndex = mainWindow.ZIndex - 1
    shadow.Parent = mainWindow
    
    -- Cantos arredondados da janela e sombra
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 15)
    windowCorner.Parent = mainWindow
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    
    -- Cantos arredondados da barra de título
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleBar
    
    -- Frame para corrigir cantos da barra de título
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 15)
    titleFix.Position = UDim2.new(0, 0, 1, -15)
    titleFix.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Título da janela
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "👻 NOCLIP SYSTEM"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Área de conteúdo
    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -20, 1, -60)
    contentArea.Position = UDim2.new(0, 10, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainWindow
    
    -- Descrição
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, 0, 0, 30)
    descLabel.Position = UDim2.new(0, 0, 0, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Ative para atravessar paredes e objetos"
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.SourceSans
    descLabel.Parent = contentArea
    
    -- Botão Toggle Noclip
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "NoclipToggle"
    toggleButton.Size = UDim2.new(0.8, 0, 0, 50)
    toggleButton.Position = UDim2.new(0.1, 0, 0, 40)
    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "🚫 DESATIVADO"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Parent = contentArea
    
    -- Cantos arredondados do botão toggle
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton
    
    -- Efeito de hover no botão toggle
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleStroke.Thickness = 0
    toggleStroke.Transparency = 0.7
    toggleStroke.Parent = toggleButton
    
    -- Status do noclip
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Noclip desativado"
    statusLabel.TextColor3 = Color3.fromRGB(220, 53, 69)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = contentArea
    
    -- Instruções
    local instructLabel = Instance.new("TextLabel")
    instructLabel.Name = "Instructions"
    instructLabel.Size = UDim2.new(1, 0, 0, 15)
    instructLabel.Position = UDim2.new(0, 0, 1, -18)
    instructLabel.BackgroundTransparency = 1
    instructLabel.Text = "Tecla N para toggle | Botão lateral para abrir/fechar"
    instructLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    instructLabel.TextScaled = true
    instructLabel.Font = Enum.Font.SourceSans
    instructLabel.Parent = contentArea
end

-- Função de noclip
local function noclipLoop()
    local character = player.Character
    if not character then return end
    
    -- Tornar todas as partes do personagem não colidíveis
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Função para restaurar colisões
local function restoreCollision()
    local character = player.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Restaurar colisão para partes que normalmente têm colisão
            if part.Name == "HumanoidRootPart" then
                part.CanCollide = false -- HumanoidRootPart sempre sem colisão
            elseif part.Parent:IsA("Accessory") then
                part.CanCollide = false -- Acessórios sem colisão
            else
                part.CanCollide = true -- Outras partes com colisão
            end
        end
    end
end

-- Função para toggle do noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        -- Ativar noclip
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
        toggleButton.Text = "✅ ATIVADO"
        mainWindow.Content.Status.Text = "Status: Noclip ativado - Atravessando paredes"
        mainWindow.Content.Status.TextColor3 = Color3.fromRGB(40, 167, 69)
        
        -- Conectar o loop de noclip
        noclipConnection = RunService.Heartbeat:Connect(noclipLoop)
        
    else
        -- Desativar noclip
        toggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
        toggleButton.Text = "🚫 DESATIVADO"
        mainWindow.Content.Status.Text = "Status: Noclip desativado"
        mainWindow.Content.Status.TextColor3 = Color3.fromRGB(220, 53, 69)
        
        -- Desconectar o loop de noclip
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        -- Restaurar colisões
        restoreCollision()
    end
end

-- Função para toggle da janela
local function toggleWindow()
    windowOpen = not windowOpen
    
    local targetPosition
    local targetTransparency
    
    if windowOpen then
        targetPosition = UDim2.new(0.5, -175, 0.5, -100)
        targetTransparency = 0
        windowToggleButton.Text = "👻"
        windowToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        targetPosition = UDim2.new(0.5, -175, 1.5, 0) -- Move para fora da tela
        targetTransparency = 1
        windowToggleButton.Text = "📋"
        windowToggleButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end
    
    -- Animação suave
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(mainWindow, tweenInfo, {
        Position = targetPosition
    })
    
    tween:Play()
end

-- Função chamada quando personagem spawna
local function onCharacterAdded(character)
    character:WaitForChild("HumanoidRootPart")
    
    -- Se noclip estava ativo, manter ativo
    if noclipEnabled then
        -- Reconectar
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        noclipConnection = RunService.Heartbeat:Connect(noclipLoop)
    end
end

-- Função para efeitos visuais
local function setupEffects()
    -- Efeito hover no botão toggle
    toggleButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 2})
        tween:Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 0})
        tween:Play()
    end)
    
    -- Efeito hover no botão da janela
    windowToggleButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(windowToggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 3})
        tween:Play()
        local scaleTween = TweenService:Create(windowToggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 65, 0, 65)})
        scaleTween:Play()
    end)
    
    windowToggleButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(windowToggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 2})
        tween:Play()
        local scaleTween = TweenService:Create(windowToggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})
        scaleTween:Play()
    end)
end

-- Função para tornar a janela arrastável
local function makeDraggable()
    local titleBar = mainWindow.TitleBar
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainWindow.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Inicialização
createGUI()
setupEffects()
makeDraggable()

-- Conectar eventos
toggleButton.MouseButton1Click:Connect(toggleNoclip)
windowToggleButton.MouseButton1Click:Connect(toggleWindow)

-- Atalhos de teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.O then
        toggleWindow()
    end
end)

-- Conectar eventos de personagem
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Limpeza quando script é removido
game:BindToClose(function()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    restoreCollision()
end)