--[[ 
    SCRIPT V4 - AIMBOT PREDICTION + MAGNET GUN
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
local AimbotPrediction = 0.145 -- (Ajuste fino: 0.13 a 0.16 costuma ser ideal no MM2)
-- --------------------

-- Variáveis
local espAtivado = false
local autoGunAtivado = false
local aimbotAtivado = false
local targetMurder = nil 

-- 1. LIMPEZA
if LocalPlayer.PlayerGui:FindFirstChild("HubV4") then
	LocalPlayer.PlayerGui.HubV4:Destroy()
end

-- 2. GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubV4"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 220)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0, 8); uiCorner.Parent = frame

local titulo = Instance.new("TextLabel")
titulo.Text = "MM2 ULTIMATE V4"
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.fromRGB(255, 0, 0)
titulo.Font = Enum.Font.GothamBlack
titulo.TextSize = 18
titulo.Parent = frame

local sub = Instance.new("TextLabel")
sub.Text = "Prediction Aimbot + Magnet Gun"
sub.Size = UDim2.new(1,0,0,15); sub.Position = UDim2.new(0,0,0,25)
sub.BackgroundTransparency = 1; sub.TextColor3 = Color3.fromRGB(150,150,150); sub.TextSize = 11; sub.Parent = frame

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = container; layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder

local function criarBotao(txt, ordem)
	local btn = Instance.new("TextButton")
	btn.LayoutOrder = ordem
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = txt
	btn.TextColor3 = Color3.white
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local btnESP = criarBotao("ESP: [OFF]", 1)
local btnGun = criarBotao("Magnet Gun: [OFF]", 2)
local btnAim = criarBotao("Aim (Q/Ctrl): [OFF]", 3)
local btnClose = criarBotao("Fechar", 4)
btnClose.BackgroundColor3 = Color3.fromRGB(180, 40, 40)

-- ============================================================================
-- LÓGICA V4
-- ============================================================================

-- A. TOGGLE MENU
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.E then frame.Visible = not frame.Visible end
end)

-- B. ESP + FIND MURDER
RunService.RenderStepped:Connect(function()
	if espAtivado then
		local found = nil
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				if not v.Character:FindFirstChild("ESP_V4") then
					local hl = Instance.new("Highlight", v.Character)
					hl.Name = "ESP_V4"; hl.FillTransparency = 0.5
				end
				local hl = v.Character.ESP_V4
				local cor = Color3.fromRGB(0, 255, 0)
				
				local hasKnife = v.Backpack:FindFirstChild(NomeDaFaca) or v.Character:FindFirstChild(NomeDaFaca)
				local hasGun = v.Backpack:FindFirstChild(NomeDaArma) or v.Character:FindFirstChild(NomeDaArma)
				
				if hasKnife then
					cor = Color3.fromRGB(255, 0, 0); found = v.Character
				elseif hasGun then
					cor = Color3.fromRGB(0, 0, 255)
				end
				hl.FillColor = cor; hl.OutlineColor = cor
			end
		end
		targetMurder = found
	end
end)

-- C. MAGNET GUN (MÉTODO IMÃ)
-- Se a arma estiver no chão, ele TRAVA seu personagem nela até pegar
RunService.Heartbeat:Connect(function()
	if autoGunAtivado then
		local gun = Workspace:FindFirstChild(NomeDaArma)
		-- Verifica se a arma está no chão
		if gun and gun:IsA("Tool") and gun:FindFirstChild("Handle") then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				-- Teleporta CONSTANTEMENTE para a arma (Imã)
				char.HumanoidRootPart.CFrame = gun.Handle.CFrame
				
				-- Se já pegou a arma (está no char), para de teleportar
				if char:FindFirstChild(NomeDaArma) then
					-- Opcional: Desliga o Auto Gun sozinho depois de pegar
					-- autoGunAtivado = false 
				end
			end
		end
	end
end)

-- D. AIMBOT COM PREDICTION (FÍSICA)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if aimbotAtivado and (input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftControl) then
		local char = LocalPlayer.Character
		local myGun = char and char:FindFirstChild(NomeDaArma)
		
		if myGun and targetMurder and targetMurder:FindFirstChild("Head") and targetMurder:FindFirstChild("HumanoidRootPart") then
			-- CÁLCULO DE PREDIÇÃO
			-- Pega a posição da cabeça + (Velocidade do alvo * Tempo que a bala leva)
			local alvoPos = targetMurder.Head.Position
			local alvoVelocidade = targetMurder.HumanoidRootPart.AssemblyLinearVelocity
			
			local predictedPosition = alvoPos + (alvoVelocidade * AimbotPrediction)
			
			-- Trava a câmera na posição futura
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
			
			-- Dispara
			myGun:Activate()
		end
	end
end)

-- ============================================================================
-- BOTÕES
-- ============================================================================
btnESP.MouseButton1Click:Connect(function()
	espAtivado = not espAtivado
	btnESP.Text = espAtivado and "ESP: [ON]" or "ESP: [OFF]"
	btnESP.TextColor3 = espAtivado and Color3.green or Color3.white
	if not espAtivado then
		for _, v in pairs(Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChild("ESP_V4") then v.Character.ESP_V4:Destroy() end
		end
	end
end)

btnGun.MouseButton1Click:Connect(function()
	autoGunAtivado = not autoGunAtivado
	btnGun.Text = autoGunAtivado and "Magnet Gun: [ON]" or "Magnet Gun: [OFF]"
	btnGun.TextColor3 = autoGunAtivado and Color3.green or Color3.white
end)

btnAim.MouseButton1Click:Connect(function()
	aimbotAtivado = not aimbotAtivado
	btnAim.Text = aimbotAtivado and "Aim (Prediction): [ON]" or "Aim (Prediction): [OFF]"
	btnAim.TextColor3 = aimbotAtivado and Color3.green or Color3.white
end)

btnClose.MouseButton1Click:Connect(function() screenGui:Destroy(); espAtivado = false; autoGunAtivado = false; aimbotAtivado = false end)
