--[[ 
    SCRIPT V6 - SAFE MODE (CORREÇÃO DE BOTÕES INVISÍVEIS)
    Link Raw: https://raw.githubusercontent.com/Willian12700/hub_test.lua/refs/heads/main/hub_test.lua
]]

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

-- LIMPEZA
for _, gui in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
	if gui.Name == "HubV6_Safe" then gui:Destroy() end
end

-- GUI PRINCIPAL
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubV6_Safe"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- Garante que não fique cortado
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global -- Força ordem global
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FRAME (O Fundo)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 250)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Borda Vermelha
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.ZIndex = 1 -- Fica atrás de tudo
frame.Visible = true
frame.Parent = screenGui

-- TÍTULO
local titulo = Instance.new("TextLabel")
titulo.Text = "MM2 V6 (FIX)"
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundTransparency = 0
titulo.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
titulo.TextColor3 = Color3.white
titulo.Font = Enum.Font.SourceSansBold -- Fonte Simples
titulo.TextSize = 18
titulo.ZIndex = 2 -- Fica na frente do frame
titulo.Parent = frame

-- FUNÇÃO PARA CRIAR BOTÕES (MANUAL E SEGURA)
local function criarBotao(texto, yPos)
	local btn = Instance.new("TextButton")
	btn.Parent = frame
	btn.Name = texto
	btn.Text = texto
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.Position = UDim2.new(0.05, 0, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.white
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.ZIndex = 2 -- GARANTE QUE APARECE NA FRENTE
	
	-- Arredondar (Safe)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = btn
	
	return btn
end

-- CRIANDO OS BOTÕES (Espaçamento manual)
local btnESP = criarBotao("ESP: [OFF]", 40)
local btnGun = criarBotao("Magnet Gun: [OFF]", 85)
local btnAim = criarBotao("Aim (Q/Ctrl): [OFF]", 130)
local btnClose = criarBotao("Fechar Menu", 185)
btnClose.BackgroundColor3 = Color3.fromRGB(120, 0, 0)

-- ============================================================================
-- LÓGICA DO SCRIPT
-- ============================================================================

-- A. ABRIR/FECHAR (TECLA E)
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.E then
		frame.Visible = not frame.Visible
	end
end)

-- B. ESP
RunService.RenderStepped:Connect(function()
	if espAtivado then
		local found = nil
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				if not v.Character:FindFirstChild("ESP_V6") then
					local hl = Instance.new("Highlight", v.Character)
					hl.Name = "ESP_V6"; hl.FillTransparency = 0.5
				end
				local hl = v.Character.ESP_V6
				local cor = Color3.fromRGB(0, 255, 0) -- Inocente
				
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

-- C. MAGNET GUN (PUXA VOCÊ PARA A ARMA)
RunService.Heartbeat:Connect(function()
	if autoGunAtivado then
		local gun = Workspace:FindFirstChild(NomeDaArma)
		if gun and gun:IsA("Tool") and gun:FindFirstChild("Handle") then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
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
			local predictedPosition = alvoPos + (
