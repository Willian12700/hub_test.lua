--[[ 
    SCRIPT V5 - UI FIX + MAGNET GUN + PREDICTION
    Link Raw: https://raw.githubusercontent.com/Willian12700/hub_test.lua/refs/heads/main/hub_test.lua
]]

-- 1. AGUARDA O JOGO CARREGAR (EVITA ERROS DE INICIALIZAÇÃO)
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- --- CONFIGURAÇÃO ---
local NomeDaFaca = "Knife"
local NomeDaArma = "Gun" 
local AimbotPrediction = 0.145
-- --------------------

local espAtivado = false
local autoGunAtivado = false
local aimbotAtivado = false
local targetMurder = nil 

-- 2. LIMPEZA TOTAL DE GUI ANTIGA
for _, gui in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
	if gui.Name == "HubV5_Fixed" then gui:Destroy() end
end

-- 3. CRIAÇÃO DA GUI SIMPLIFICADA
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubV5_Fixed"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 200, 0, 240) -- Tamanho fixo e seguro
frame.Position = UDim2.new(0.05, 0, 0.2, 0) -- Canto esquerdo
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true -- Arrastável
frame.Visible = true
frame.Parent = screenGui

-- Título
local titulo = Instance.new("TextLabel")
titulo.Text = "MM2 HUB V5 (FIX)"
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
titulo.TextColor3 = Color3.white
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 14
titulo.Parent = frame

-- Layout Manual (Garante que os botões apareçam)
local function criarBotao(texto, yPos, cor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.Position = UDim2.new(0.05, 0, 0, yPos) -- Posição manual (Y)
	btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
	btn.Text = texto
	btn.TextColor3 = Color3.white
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.Parent = frame
	
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = btn
	return btn
end

-- Posicionando botões manualmente (Sem UIListLayout para não bugar)
local btnESP = criarBotao("ESP: [OFF]", 40)
local btnGun = criarBotao("Magnet Gun: [OFF]", 85)
local btnAim = criarBotao("Aim (Q/Ctrl): [OFF]", 130)
local btnClose = criarBotao("Fechar Menu", 185, Color3.fromRGB(150, 0, 0))

-- ============================================================================
-- LÓGICA (PROTEGIDA COM PCALL)
-- ============================================================================

-- A. TOGGLE MENU (TECLA E)
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.E then
		frame.Visible = not frame.Visible
	end
end)

-- B. ESP + FIND MURDER
RunService.RenderStepped:Connect(function()
	if espAtivado then
		local found = nil
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				if not v.Character:FindFirstChild("ESP_V5") then
					local hl = Instance.new("Highlight", v.Character)
					hl.Name = "ESP_V5"; hl.FillTransparency = 0.5
				end
				local hl = v.Character.ESP_V5
				local cor = Color3.fromRGB(0, 255, 0) -- Inocente
				
				-- Verifica itens
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

-- C. MAGNET GUN (CORRIGIDO)
RunService.Heartbeat:Connect(function()
	if autoGunAtivado then
		local gun = Workspace:FindFirstChild(NomeDaArma)
		if gun and gun:IsA("Tool") and gun:FindFirstChild("Handle") then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				-- Força o teleporte constante
				char.HumanoidRootPart.CFrame = gun.Handle.CFrame
			end
		end
	end
end)

-- D. AIMBOT (PREDICTION)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if aimbotAtivado and (input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftControl) then
		local char = LocalPlayer.Character
		local myGun = char and char:FindFirstChild(NomeDaArma)
		
		if myGun and targetMurder and targetMurder:FindFirstChild("Head") and targetMurder:FindFirstChild("HumanoidRootPart") then
			local alvoPos = targetMurder.Head.Position
			local alvoVelocidade = targetMurder.HumanoidRootPart.AssemblyLinearVelocity
			
			-- Predição matemática simples
			local predictedPosition = alvoPos + (alvoVelocidade * AimbotPrediction)
			
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
			myGun:Activate()
		end
	end
end)

-- ============================================================================
-- BOTÕES (EVENTOS)
-- ============================================================================

btnESP.MouseButton1Click:Connect(function()
	espAtivado = not espAtivado
	btnESP.Text = espAtivado and "ESP: [ON]" or "ESP: [OFF]"
	btnESP.TextColor3 = espAtivado and Color3.green or Color3.white
	if not espAtivado then
		for _, v in pairs(Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChild("ESP_V5") then v.Character.ESP_V5:Destroy() end
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

btnClose.MouseButton1Click:Connect(function()
	screenGui:Destroy()
	espAtivado = false; autoGunAtivado = false; aimbotAtivado = false
end)

print("HUB V5 CARREGADO COM SUCESSO!")
