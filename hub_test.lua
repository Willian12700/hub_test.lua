--[[ 
    SCRIPT ATUALIZADO V2 - GUI FIX
    Link Raw: https://raw.githubusercontent.com/Willian12700/hub_test.lua/refs/heads/main/hub_test.lua
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- --- CONFIGURAÇÃO ---
local NomeDaFaca = "Knife"
local NomeDaArma = "Gun" 
-- --------------------

local espAtivado = false
local autoGunAtivado = false
local aimbotAtivado = false
local targetAimbot = nil

-- 1. DELETAR GUI ANTIGA SE EXISTIR
if LocalPlayer.PlayerGui:FindFirstChild("HubFinal") then
	LocalPlayer.PlayerGui.HubFinal:Destroy()
end

-- 2. CRIAR A NOVA GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubFinal"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Fundo Principal
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 200) -- Altura levemente maior
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

-- Título (Fica solto no topo)
local titulo = Instance.new("TextLabel")
titulo.Text = "MM2 HUB V2"
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.Position = UDim2.new(0, 0, 0, 5) -- 5px do topo
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.fromRGB(255, 0, 0)
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 16
titulo.Parent = frame

-- Container dos Botões (Para organizar só os botões)
local container = Instance.new("Frame")
container.Name = "ButtonContainer"
container.Size = UDim2.new(1, -20, 1, -40) -- Largura total menos margem, Altura menos título
container.Position = UDim2.new(0, 10, 0, 40) -- Abaixo do título
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = container
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 8) -- Espaço entre botões
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Função de criar botão
local function criarBotao(texto, ordem)
	local btn = Instance.new("TextButton")
	btn.Name = texto
	btn.LayoutOrder = ordem
	btn.Size = UDim2.new(1, 0, 0, 35) -- Preenche a largura do container
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = texto
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = container
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn
	return btn
end

-- Criando os Botões
local btnESP = criarBotao("ESP: [OFF]", 1)
local btnGun = criarBotao("Auto Gun: [OFF]", 2)
local btnAim = criarBotao("Aimbot: [OFF]", 3)
local btnClose = criarBotao("Fechar Menu", 4)
btnClose.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Botão fechar vermelho escuro

-- --- LÓGICA (TP TAKE + ESP) ---

local function TPFastGetGun(gun)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") and gun:FindFirstChild("Handle") then
		local root = char.HumanoidRootPart
		local currentPos = root.CFrame
		
		-- Vai
		root.CFrame = gun.Handle.CFrame
		RunService.Heartbeat:Wait() -- Espera physics frame
		
		-- Volta
		root.CFrame = currentPos
	end
end

RunService.RenderStepped:Connect(function()
	-- ESP
	if espAtivado then
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character then
				local hl = v.Character:FindFirstChild("ESP_MM2")
				if not hl then 
					hl = Instance.new("Highlight")
					hl.Name = "ESP_MM2"
					hl.Adornee = v.Character
					hl.FillTransparency = 0.5
					hl.Parent = v.Character 
				end
				
				local cor = Color3.fromRGB(0, 255, 0) -- Inocente
				if v.Backpack:FindFirstChild(NomeDaFaca) or v.Character:FindFirstChild(NomeDaFaca) then
					cor = Color3.fromRGB(255, 0, 0) -- Murder
					targetAimbot = v.Character
				elseif v.Backpack:FindFirstChild(NomeDaArma) or v.Character:FindFirstChild(NomeDaArma) then
					cor = Color3.fromRGB(0, 0, 255) -- Xerife
				end
				hl.FillColor = cor; hl.OutlineColor = cor
			end
		end
	end

	-- AUTO GUN
	if autoGunAtivado then
		local droppedGun = Workspace:FindFirstChild(NomeDaArma)
		if droppedGun and droppedGun:IsA("Tool") then
			TPFastGetGun(droppedGun)
		end
	end

	-- AIMBOT
	if aimbotAtivado and targetAimbot and targetAimbot:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetAimbot.Head.Position)
	end
end)

-- --- EVENTOS DOS BOTÕES ---
btnESP.MouseButton1Click:Connect(function() 
	espAtivado = not espAtivado
	btnESP.Text = espAtivado and "ESP: [ON]" or "ESP: [OFF]"
	btnESP.TextColor3 = espAtivado and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
	if not espAtivado then
		for _, v in pairs(Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChild("ESP_MM2") then v.Character.ESP_MM2:Destroy() end
		end
	end
end)

btnGun.MouseButton1Click:Connect(function() 
	autoGunAtivado = not autoGunAtivado
	btnGun.Text = autoGunAtivado and "Auto Gun: [ON]" or "Auto Gun: [OFF]"
	btnGun.TextColor3 = autoGunAtivado and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
end)

btnAim.MouseButton1Click:Connect(function() 
	aimbotAtivado = not aimbotAtivado
	btnAim.Text = aimbotAtivado and "Aimbot: [ON]" or "Aimbot: [OFF]"
	btnAim.TextColor3 = aimbotAtivado and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
	if not aimbotAtivado then targetAimbot = nil end
end)

btnClose.MouseButton1Click:Connect(function() 
	screenGui:Destroy()
	espAtivado = false
	autoGunAtivado = false
	aimbotAtivado = false
end)
