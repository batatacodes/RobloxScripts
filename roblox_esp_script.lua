-- LocalScript - Colocar em StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variáveis de controle
local espEnabled = false
local gui = nil
local toggleButton = nil
local espLabels = {} -- Tabela para armazenar as labels dos jogadores
local espConnections = {} -- Conexões do RunService

-- Função para criar a GUI
local function createGUI()
    -- ScreenGui principal
    gui = Instance.new("ScreenGui")
    gui.Name = "ESPSystemGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Frame principal (mais acima que o SpeedBoost)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 75)
    mainFrame.Position = UDim2.new(0.5, -150, 0, -70)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- Gradiente de fundo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    gradient.Rotation = 90
    gradient.Parent = mainFrame
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = mainFrame
    
    -- Borda brilhante
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 191, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = mainFrame
    
    -- Sombra
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 18)
    shadowCorner.Parent = shadow
    
    -- Ícone de ESP
    local espIcon = Instance.new("TextLabel")
    espIcon.Name = "ESPIcon"
    espIcon.Size = UDim2.new(0, 45, 0, 45)
    espIcon.Position = UDim2.new(0, 15, 0.5, -22.5)
    espIcon.BackgroundTransparency = 1
    espIcon.Text = "👁"
    espIcon.TextColor3 = Color3.fromRGB(0, 191, 255)
    espIcon.TextScaled = true
    espIcon.Font = Enum.Font.SourceSansBold
    espIcon.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 130, 0, 28)
    titleLabel.Position = UDim2.new(0, 65, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ESP SYSTEM"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 130, 0, 20)
    statusLabel.Position = UDim2.new(0, 65, 0, 35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Wallhack: Desativado"
    statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Contador de jogadores
    local playerCount = Instance.new("TextLabel")
    playerCount.Name = "PlayerCount"
    playerCount.Size = UDim2.new(0, 130, 0, 15)
    playerCount.Position = UDim2.new(0, 65, 0, 52)
    playerCount.BackgroundTransparency = 1
    playerCount.Text = "Jogadores: 0"
    playerCount.TextColor3 = Color3.fromRGB(120, 120, 120)
    playerCount.TextScaled = true
    playerCount.Font = Enum.Font.SourceSans
    playerCount.TextXAlignment = Enum.TextXAlignment.Left
    playerCount.Parent = mainFrame
    
    -- Botão Toggle
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 85, 0, 55)
    toggleButton.Position = UDim2.new(1, -95, 0.5, -27.5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Parent = mainFrame
    
    -- Cantos arredondados do botão
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 15)
    buttonCorner.Parent = toggleButton
    
    -- Efeito de brilho no botão
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Thickness = 0
    buttonStroke.Transparency = 0.4
    buttonStroke.Parent = toggleButton
    
    -- Indicador de atividade (pulsante)
    local activityBar = Instance.new("Frame")
    activityBar.Name = "ActivityBar"
    activityBar.Size = UDim2.new(0, 4, 0.7, 0)
    activityBar.Position = UDim2.new(0, 3, 0.15, 0)
    activityBar.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    activityBar.BorderSizePixel = 0
    activityBar.Parent = mainFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = activityBar
    
    -- Instruções
    local instructLabel = Instance.new("TextLabel")
    instructLabel.Name = "Instructions"
    instructLabel.Size = UDim2.new(1, 0, 0, 18)
    instructLabel.Position = UDim2.new(0, 0, 1, 8)
    instructLabel.BackgroundTransparency = 1
    instructLabel.Text = "Tecla E para toggle | Vê nomes através de paredes"
    instructLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    instructLabel.TextScaled = true
    instructLabel.Font = Enum.Font.SourceSans
    instructLabel.TextTransparency = 1
    instructLabel.Parent = mainFrame
end

-- Função para criar label ESP para um jogador
local function createESPLabel(targetPlayer)
    if targetPlayer == player then return end -- Não criar para si mesmo
    if not targetPlayer.Character then return end
    if not targetPlayer.Character:FindFirstChild("Head") then return end
    
    -- Remover label existente se houver
    if espLabels[targetPlayer] then
        espLabels[targetPlayer]:Destroy()
        espLabels[targetPlayer] = nil
    end
    
    -- Criar nova label
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESPLabel_" .. targetPlayer.Name
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.Adornee = targetPlayer.Character.Head
    billboardGui.AlwaysOnTop = true -- Sempre na frente (através de paredes)
    billboardGui.LightInfluence = 0
    billboardGui.Parent = targetPlayer.Character.Head
    
    -- Frame de fundo da label
    local labelFrame = Instance.new("Frame")
    labelFrame.Size = UDim2.new(1, 0, 1, 0)
    labelFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    labelFrame.BackgroundTransparency = 0.3
    labelFrame.BorderSizePixel = 0
    labelFrame.Parent = billboardGui
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = labelFrame
    
    -- Borda colorida
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(0, 191, 255)
    frameStroke.Thickness = 2
    frameStroke.Parent = labelFrame
    
    -- Label do nome
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0.7, 0)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = targetPlayer.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = labelFrame
    
    -- Label de distância
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, -10, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 5, 0.7, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Parent = labelFrame
    
    -- Armazenar a label
    espLabels[targetPlayer] = billboardGui
    
    -- Efeito de aparição
    labelFrame.Size = UDim2.new(0, 0, 0, 0)
    local appearTween = TweenService:Create(labelFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0)
    })
    appearTween:Play()
end

-- Função para atualizar distâncias
local function updateDistances()
    if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPosition = player.Character.HumanoidRootPart.Position
    
    for targetPlayer, label in pairs(espLabels) do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and label then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
            local distance = math.floor((playerPosition - targetPosition).Magnitude)
            
            local distanceLabel = label.Frame:FindFirstChild("Distance")
            if distanceLabel then
                distanceLabel.Text = distance .. "m"
                
                -- Mudar cor baseado na distância
                if distance < 50 then
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Vermelho (perto)
                elseif distance < 100 then
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 100) -- Amarelo (médio)
                else
                    distanceLabel.TextColor3 = Color3.fromRGB(0, 191, 255) -- Azul (longe)
                end
            end
        end
    end
end

-- Função para criar labels de todos os jogadores
local function createAllESPLabels()
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            createESPLabel(targetPlayer)
        end
    end
    
    -- Atualizar contador
    local playerCount = #Players:GetPlayers() - 1 -- -1 para excluir o próprio jogador
    gui.MainFrame.PlayerCount.Text = "Jogadores: " .. playerCount
end

-- Função para remover todas as labels ESP
local function removeAllESPLabels()
    for targetPlayer, label in pairs(espLabels) do
        if label then
            label:Destroy()
        end
    end
    espLabels = {}
end

-- Função para toggle do ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        -- Ativar ESP
        toggleButton.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        toggleButton.Text = "ON"
        gui.MainFrame.Status.Text = "Wallhack: Ativo"
        gui.MainFrame.Status.TextColor3 = Color3.fromRGB(39, 174, 96)
        gui.MainFrame.UIStroke.Color = Color3.fromRGB(39, 174, 96)
        gui.MainFrame.ESPIcon.TextColor3 = Color3.fromRGB(39, 174, 96)
        gui.MainFrame.ActivityBar.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        
        -- Criar labels para todos os jogadores
        createAllESPLabels()
        
        -- Conectar atualização de distâncias
        espConnections.distanceUpdate = RunService.Heartbeat:Connect(updateDistances)
        
        -- Efeito de pulso na barra de atividade
        local function pulseActivity()
            if espEnabled then
                local pulseTween = TweenService:Create(gui.MainFrame.ActivityBar, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0.7
                })
                pulseTween:Play()
                
                pulseTween.Completed:Connect(function()
                    if espEnabled then
                        local returnTween = TweenService:Create(gui.MainFrame.ActivityBar, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            BackgroundTransparency = 0
                        })
                        returnTween:Play()
                        returnTween.Completed:Connect(pulseActivity)
                    end
                end)
            end
        end
        pulseActivity()
        
    else
        -- Desativar ESP
        toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        toggleButton.Text = "OFF"
        gui.MainFrame.Status.Text = "Wallhack: Desativado"
        gui.MainFrame.Status.TextColor3 = Color3.fromRGB(160, 160, 160)
        gui.MainFrame.UIStroke.Color = Color3.fromRGB(0, 191, 255)
        gui.MainFrame.ESPIcon.TextColor3 = Color3.fromRGB(0, 191, 255)
        gui.MainFrame.ActivityBar.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
        gui.MainFrame.ActivityBar.BackgroundTransparency = 0
        
        -- Remover todas as labels
        removeAllESPLabels()
        
        -- Desconectar atualizações
        if espConnections.distanceUpdate then
            espConnections.distanceUpdate:Disconnect()
            espConnections.distanceUpdate = nil
        end
    end
    
    -- Efeito de pulso no ícone
    local pulseTween = TweenService:Create(gui.MainFrame.ESPIcon, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
        Size = UDim2.new(0, 50, 0, 50)
    })
    pulseTween:Play()
    
    pulseTween.Completed:Connect(function()
        local returnTween = TweenService:Create(gui.MainFrame.ESPIcon, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 45, 0, 45)
        })
        returnTween:Play()
    end)
end

-- Função para quando um jogador entra no jogo
local function onPlayerAdded(newPlayer)
    if espEnabled then
        -- Esperar o personagem carregar
        newPlayer.CharacterAdded:Connect(function(character)
            character:WaitForChild("Head")
            wait(0.5) -- Pequeno delay para garantir que tudo carregou
            if espEnabled then
                createESPLabel(newPlayer)
                -- Atualizar contador
                local playerCount = #Players:GetPlayers() - 1
                gui.MainFrame.PlayerCount.Text = "Jogadores: " .. playerCount
            end
        end)
    end
end

-- Função para quando um jogador sai do jogo
local function onPlayerRemoving(leavingPlayer)
    if espLabels[leavingPlayer] then
        espLabels[leavingPlayer]:Destroy()
        espLabels[leavingPlayer] = nil
    end
    
    -- Atualizar contador
    if gui then
        local playerCount = #Players:GetPlayers() - 2 -- -2 porque o jogador ainda está na lista
        gui.MainFrame.PlayerCount.Text = "Jogadores: " .. playerCount
    end
end

-- Função para quando um personagem respawna
local function onCharacterAdded(targetPlayer, character)
    if espEnabled and targetPlayer ~= player then
        character:WaitForChild("Head")
        wait(0.5)
        if espEnabled then
            createESPLabel(targetPlayer)
        end
    end
end

-- Função para efeitos visuais
local function setupEffects()
    -- Efeito hover no botão
    toggleButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 2})
        hoverTween:Play()
        
        local scaleTween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 90, 0, 58)})
        scaleTween:Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        local hoverTween = TweenService:Create(toggleButton.UIStroke, TweenInfo.new(0.2), {Thickness = 0})
        hoverTween:Play()
        
        local scaleTween = TweenService:Create(toggleButton, TweenInfo.new(0, 2), {Size = UDim2.new(0, 85, 0, 55)})
        scaleTween:Play()
    end)
    
    -- Mostrar instruções ao hover
    gui.MainFrame.MouseEnter:Connect(function()
        local instructTween = TweenService:Create(gui.MainFrame.Instructions, TweenInfo.new(0.3), {TextTransparency = 0})
        instructTween:Play()
    end)
    
    gui.MainFrame.MouseLeave:Connect(function()
        local instructTween = TweenService:Create(gui.MainFrame.Instructions, TweenInfo.new(0.3), {TextTransparency = 1})
        instructTween:Play()
    end)
    
    -- Animação de entrada da GUI (vem de cima)
    gui.MainFrame.Position = UDim2.new(0.5, -150, 0, -200)
    local entranceTween = TweenService:Create(gui.MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0, -70)
    })
    entranceTween:Play()
end

-- Inicialização
createGUI()
setupEffects()

-- Conectar eventos dos jogadores
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Conectar respawn de jogadores existentes
for _, existingPlayer in pairs(Players:GetPlayers()) do
    if existingPlayer ~= player then
        existingPlayer.CharacterAdded:Connect(function(character)
            onCharacterAdded(existingPlayer, character)
        end)
    end
end

-- Conectar eventos da GUI
toggleButton.MouseButton1Click:Connect(toggleESP)

-- Atalho de teclado (tecla E)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        toggleESP()
    end
end)

-- Atualizar contador inicial
local initialCount = #Players:GetPlayers() - 1
gui.MainFrame.PlayerCount.Text = "Jogadores: " .. initialCount

-- Limpeza quando script é removido
game:BindToClose(function()
    removeAllESPLabels()
    for _, connection in pairs(espConnections) do
        if connection then
            connection:Disconnect()
        end
    end
end)