--[[ 
    SCRIPT V3 - MENU FIX + AIMBOT KEYBIND
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

-- Variáveis de Estado
local espAtivado = false
local autoGunAtivado = false
local aimbotAtivado = false -- Agora serve para ativar a funcionalidade das teclas
local targetMurder = nil -- Guarda quem é o Murder

-- 1. LIMPEZA DE GUI ANTIGA
if LocalPlayer.PlayerGui:FindFirstChild("HubV3") then
	LocalPlayer.PlayerGui.HubV3:Destroy()
end

-- 2. CRIAÇÃO DA GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubV3"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 210)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true -- Começa visível
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0, 8); uiCorner.Parent = frame

-- Título
local titulo = Instance.new("TextLabel")
titulo.Text = "MM2 HUB V3"
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.fromRGB(255, 50, 50)
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 18
titulo.Parent = frame

-- Instrução
local subTitulo = Instance.new("TextLabel")
subTitulo.Text = "Toggle Menu: 'E' | Shoot: 'Q'/'Ctrl'"
subTitulo.Size = UDim2.new(1, 0, 0, 15)
subTitulo.Position = UDim2.new(0, 0, 0, 25)
subTitulo.BackgroundTransparency = 1
subTitulo.TextColor3 = Color3.fromRGB(150, 150, 150)
subTitulo.Font = Enum.Font.Code
subTitulo.TextSize = 11
subTitulo.Parent = frame

-- Container Botões
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = container; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder

local function criarBotao(texto, ordem)
	local btn = Instance.new("TextButton")
	btn.LayoutOrder = ordem
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = texto
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = container
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
	return btn
end

local btnESP = criarBotao("ESP: [OFF]", 1)
local btnGun = criarBotao("Auto Gun: [OFF]", 2)
local btnAim = criarBotao("Aim Key (Q/Ctrl): [OFF]", 3)
local btnClose = criarBotao("Fechar", 4)
btnClose.BackgroundColor3 = Color3.fromRGB(180, 40, 40)

-- ============================================================================
-- LÓGICA DE FUNCIONALIDADES
-- ============================================================================

-- A. TECLA "E" PARA ABRIR/FECHAR MENU
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
		frame.Visible = not frame.Visible
	end
end)

-- B. ESP + DETECTAR MURDER
RunService.RenderStepped:Connect(function()
	if espAtivado then
		local foundMurder = nil
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				-- Cria Highlight se não existir
				if not v.Character:FindFirstChild("ESP_V3") then
					local hl = Instance.new("Highlight")
					hl.Name = "ESP_V3"; hl.Adornee = v.Character; hl.FillTransparency = 0.5; hl.Parent = v.Character
				end
				
				local hl = v.Character.ESP_V3
				local cor = Color3.fromRGB(0, 255, 0) -- Inocente
				
				-- Checa Inventário
				local hasKnife = v.Backpack:FindFirstChild(NomeDaFaca) or v.Character:FindFirstChild(NomeDaFaca)
				local hasGun = v.Backpack:FindFirstChild(NomeDaArma) or v.Character:FindFirstChild(NomeDaArma)
				
				if hasKnife then
					cor = Color3.fromRGB(255, 0, 0)
					foundMurder = v.Character -- Salva quem é o Murder
				elseif hasGun then
					cor = Color3.fromRGB(0, 0, 255)
				end
				
				hl.FillColor = cor; hl.OutlineColor = cor
			end
		end
		targetMurder = foundMurder -- Atualiza a variável global
	end
end)

-- C. AUTO GUN (Teleporte Melhorado)
RunService.RenderStepped:Connect(function()
	if autoGunAtivado then
		local gun = Workspace:FindFirstChild(NomeDaArma)
		if gun and gun:IsA("Tool") and gun:FindFirstChild("Handle") then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart
				
				-- Salva posição e vai até a arma
				local oldPos = root.CFrame
				
				-- Tenta teleportar várias vezes rápido num frame
				for i = 1, 5 do
					root.CFrame = gun.Handle.CFrame
				end
				
				-- Volta
				root.CFrame = oldPos
			end
		end
	end
end)

-- D. AIMBOT (TECLAS Q ou CTRL)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Verifica se o Aimbot está ligado no menu e se apertou Q ou Ctrl
	if aimbotAtivado and (input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftControl) then
		
		-- Verifica se eu tenho a arma EQUIPADA
		local char = LocalPlayer.Character
		local myGun = char and char:FindFirstChild(NomeDaArma)
		
		if myGun and targetMurder and targetMurder:FindFirstChild("Head") then
			-- 1. Mira na cabeça do Murder
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetMurder.Head.Position)
			
			-- 2. Atira (Ativa a arma)
			myGun:Activate()
		end
	end
end)

-- ============================================================================
-- BOTÕES DO MENU
-- ============================================================================
btnESP.MouseButton1Click:Connect(function()
	espAtivado = not espAtivado
	btnESP.Text = espAtivado and "ESP: [ON]" or "ESP: [OFF]"
	btnESP.TextColor3 = espAtivado and Color3.fromRGB(0, 255, 0) or Color3.white
	if not espAtivado then
		-- Limpa o ESP visualmente
		for _, v in pairs(Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChild("ESP_V3") then v.Character.ESP_V3:Destroy() end
		end
		targetMurder = nil
	end
end)

btnGun.MouseButton1Click:Connect(function()
	autoGunAtivado = not autoGunAtivado
	btnGun.Text = autoGunAtivado and "Auto Gun: [ON]" or "Auto Gun: [OFF]"
	btnGun.TextColor3 = autoGunAtivado and Color3.fromRGB(0, 255, 0) or Color3.white
end)

btnAim.MouseButton1Click:Connect(function()
	aimbotAtivado = not aimbotAtivado
	btnAim.Text = aimbotAtivado and "Aim Key (Q/Ctrl): [ON]" or "Aim Key (Q/Ctrl): [OFF]"
	btnAim.TextColor3 = aimbotAtivado and Color3.fromRGB(0, 255, 0) or Color3.white
end)

btnClose.MouseButton1Click:Connect(function()
	screenGui:Destroy()
	espAtivado = false; autoGunAtivado = false; aimbotAtivado = false
end)
