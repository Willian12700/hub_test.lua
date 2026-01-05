--[[ 
    SCRIPT FINAL - AUTO GUN (TP METHOD)
    Use via: loadstring(game:HttpGet("..."))()
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- --- CONFIGURAÇÃO ---
local NomeDaFaca = "Knife"
local NomeDaArma = "Gun" -- Troque por "Revolver" se precisar
-- --------------------

local espAtivado = false
local autoGunAtivado = false
local aimbotAtivado = false
local targetAimbot = nil

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubFinal"
screenGui.ResetOnSpawn = false
if LocalPlayer.PlayerGui:FindFirstChild("HubFinal") then LocalPlayer.PlayerGui.HubFinal:Destroy() end
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true; frame.Draggable = true
frame.Parent = screenGui

local titulo = Instance.new("TextLabel")
titulo.Text = "MM2 LOADSTRING HUB"
titulo.Size = UDim2.new(1,0,0,30)
titulo.TextColor3 = Color3.fromRGB(255,0,0)
titulo.BackgroundTransparency = 1
titulo.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = frame; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0,5); layout.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding"); pad.Parent = frame; pad.PaddingTop = UDim.new(0,35)

local function criarBotao(txt)
	local b = Instance.new("TextButton"); b.Size = UDim2.new(0.9,0,0,30); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.white; b.Text = txt; b.Parent = frame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
	return b
end

local btnESP = criarBotao("ESP: [OFF]")
local btnGun = criarBotao("Auto Gun: [OFF]")
local btnAim = criarBotao("Aimbot: [OFF]")
local btnClose = criarBotao("Fechar GUI")

-- --- LÓGICA DO AUTO GUN (TP RAPIDO) ---
local function TPFastGetGun(gun)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") and gun:FindFirstChild("Handle") then
		local root = char.HumanoidRootPart
		local currentPos = root.CFrame -- Salva onde você está
		
		-- 1. Vai até a arma
		root.CFrame = gun.Handle.CFrame
		
		-- 2. Espera um frame (o mínimo possível para o servidor registrar o toque)
		RunService.Heartbeat:Wait()
		RunService.Heartbeat:Wait()
		
		-- 3. Volta para onde estava
		root.CFrame = currentPos
	end
end

-- --- LOOP PRINCIPAL ---
RunService.RenderStepped:Connect(function()
	-- ESP E AIMBOT TARGET
	if espAtivado then
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character then
				local hl = v.Character:FindFirstChild("ESP")
				if not hl then hl = Instance.new("Highlight", v.Character); hl.Name = "ESP" end
				
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

	-- AUTO GUN LOGIC
	if autoGunAtivado then
		-- Procura a arma no Workspace
		local droppedGun = Workspace:FindFirstChild(NomeDaArma)
		if droppedGun and droppedGun:IsA("Tool") then
			TPFastGetGun(droppedGun)
		end
	end

	-- AIMBOT CAMLOCK
	if aimbotAtivado and targetAimbot and targetAimbot:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetAimbot.Head.Position)
	end
end)

-- --- BOTÕES ---
btnESP.MouseButton1Click:Connect(function() espAtivado = not espAtivado; btnESP.Text = espAtivado and "ESP: [ON]" or "ESP: [OFF]"; btnESP.TextColor3 = espAtivado and Color3.green or Color3.white end)
btnGun.MouseButton1Click:Connect(function() autoGunAtivado = not autoGunAtivado; btnGun.Text = autoGunAtivado and "Auto Gun: [ON]" or "Auto Gun: [OFF]"; btnGun.TextColor3 = autoGunAtivado and Color3.green or Color3.white end)
btnAim.MouseButton1Click:Connect(function() aimbotAtivado = not aimbotAtivado; btnAim.Text = aimbotAtivado and "Aimbot: [ON]" or "Aimbot: [OFF]"; btnAim.TextColor3 = aimbotAtivado and Color3.green or Color3.white; if not aimbotAtivado then targetAimbot = nil end end)
btnClose.MouseButton1Click:Connect(function() screenGui:Destroy(); espAtivado = false; autoGunAtivado = false; aimbotAtivado = false end)
