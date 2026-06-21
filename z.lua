local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Limpieza si ya existe una instancia previa
local old = player.PlayerGui:FindFirstChild("SkinVisualMenu")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SkinVisualMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player.PlayerGui

--==============================
-- HELPERS
--==============================
local function create(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	if parent then obj.Parent = parent end
	return obj
end

local function corner(parent, radius)
	create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function stroke(parent, color, thickness)
	create("UIStroke", {
		Color = color or Color3.fromRGB(60, 60, 60),
		Thickness = thickness or 1,
	}, parent)
end

local function tweenColor(obj, color, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.15), { BackgroundColor3 = color }):Play()
end

--==============================
-- ESTADO
--==============================
local state = {
	selectedType = "Knives",
	selectedItem = nil,
	visual = {}, -- [nombreItem] = cantidad
}

--==============================
-- VENTANA PRINCIPAL
--==============================
local frame = create("Frame", {
	Size = UDim2.fromScale(0.5, 0.7),
	Position = UDim2.fromScale(0.25, 0.15),
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BorderSizePixel = 0,
}, gui)
corner(frame, 12)
stroke(frame, Color3.fromRGB(50, 50, 50), 1)

--==============================
-- TOPBAR (arrastrable + título + cerrar)
--==============================
local topbar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundColor3 = Color3.fromRGB(18, 18, 18),
	BorderSizePixel = 0,
}, frame)
corner(topbar, 12)

-- Tapa el borde redondeado inferior de la topbar para que no se vea "flotando"
create("Frame", {
	Size = UDim2.new(1, 0, 0, 12),
	Position = UDim2.new(0, 0, 1, -12),
	BackgroundColor3 = Color3.fromRGB(18, 18, 18),
	BorderSizePixel = 0,
	ZIndex = 0,
}, topbar)

local title = create("TextLabel", {
	Text = "SKIN VISUAL MENU",
	Size = UDim2.new(1, -45, 1, 0),
	Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1,
	TextColor3 = Color3.fromRGB(230, 230, 230),
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
}, topbar)

local closeBtn = create("TextButton", {
	Text = "✕",
	Size = UDim2.new(0, 32, 0, 32),
	Position = UDim2.new(1, -36, 0.5, -16),
	BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	AutoButtonColor = false,
}, topbar)
corner(closeBtn, 8)

closeBtn.MouseEnter:Connect(function() tweenColor(closeBtn, Color3.fromRGB(200, 60, 60)) end)
closeBtn.MouseLeave:Connect(function() tweenColor(closeBtn, Color3.fromRGB(40, 40, 40)) end)
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--==============================
-- DRAG (mueve toda la ventana)
--==============================
do
	local dragging = false
	local dragInput, mousePos, framePos

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			mousePos = input.Position
			framePos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			frame.Position = UDim2.new(
				framePos.X.Scale, framePos.X.Offset + delta.X,
				framePos.Y.Scale, framePos.Y.Offset + delta.Y
			)
		end
	end)
end

--==============================
-- TABS (Knives / Guns)
--==============================
local tabs = create("Frame", {
	Size = UDim2.new(1, -20, 0, 40),
	Position = UDim2.new(0, 10, 0, 50),
	BackgroundTransparency = 1,
}, frame)

local tabLayout = create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabs)

local function makeTab(text, layoutOrder)
	local btn = create("TextButton", {
		Text = text,
		Size = UDim2.new(0.5, -4, 1, 0),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		TextColor3 = Color3.fromRGB(220, 220, 220),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		AutoButtonColor = false,
		LayoutOrder = layoutOrder,
	}, tabs)
	corner(btn, 8)
	return btn
end

local knifeTab = makeTab("KNIVES", 1)
local gunTab = makeTab("GUNS", 2)

local function refreshTabVisuals()
	local active = Color3.fromRGB(70, 130, 230)
	local inactive = Color3.fromRGB(40, 40, 40)
	tweenColor(knifeTab, state.selectedType == "Knives" and active or inactive)
	tweenColor(gunTab, state.selectedType == "Guns" and active or inactive)
end

--==============================
-- BUSCADOR
--==============================
local search = create("TextBox", {
	Position = UDim2.new(0, 10, 0, 100),
	Size = UDim2.new(1, -20, 0, 35),
	PlaceholderText = "Buscar...",
	BackgroundColor3 = Color3.fromRGB(35, 35, 35),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	ClearTextOnFocus = false,
}, frame)
corner(search, 8)
create("UIPadding", { PaddingLeft = UDim.new(0, 10) }, search)

--==============================
-- LISTA DE ITEMS
--==============================
local list = create("ScrollingFrame", {
	Position = UDim2.new(0, 10, 0, 145),
	Size = UDim2.new(1, -20, 0, 220),
	BackgroundColor3 = Color3.fromRGB(20, 20, 20),
	BorderSizePixel = 0,
	ScrollBarThickness = 5,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, frame)
corner(list, 8)

local listLayout = create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, list)

create("UIPadding", {
	PaddingTop = UDim.new(0, 4),
	PaddingLeft = UDim.new(0, 4),
	PaddingRight = UDim.new(0, 4),
	PaddingBottom = UDim.new(0, 4),
}, list)

--==============================
-- CANTIDAD + AGREGAR
--==============================
local bottomRow = create("Frame", {
	Position = UDim2.new(0, 10, 0, 375),
	Size = UDim2.new(1, -20, 0, 40),
	BackgroundTransparency = 1,
}, frame)

local amount = create("TextBox", {
	Size = UDim2.new(0.3, -5, 1, 0),
	Text = "1",
	BackgroundColor3 = Color3.fromRGB(35, 35, 35),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	ClearTextOnFocus = false,
}, bottomRow)
corner(amount, 8)

local addBtn = create("TextButton", {
	Position = UDim2.new(0.3, 5, 0, 0),
	Size = UDim2.new(0.7, -5, 1, 0),
	Text = "Agregar visual",
	BackgroundColor3 = Color3.fromRGB(60, 160, 90),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = false,
}, bottomRow)
corner(addBtn, 8)

addBtn.MouseEnter:Connect(function() tweenColor(addBtn, Color3.fromRGB(70, 185, 105)) end)
addBtn.MouseLeave:Connect(function() tweenColor(addBtn, Color3.fromRGB(60, 160, 90)) end)

--==============================
-- OUTPUT
--==============================
local output = create("TextLabel", {
	Position = UDim2.new(0, 10, 0, 425),
	Size = UDim2.new(1, -20, 1, -435),
	BackgroundColor3 = Color3.fromRGB(35, 35, 35),
	TextColor3 = Color3.fromRGB(220, 220, 220),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextWrapped = true,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "Sin selección.",
}, frame)
corner(output, 8)
create("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8),
}, output)

--==============================
-- LÓGICA
--==============================
local itemButtons = {} -- referencia para poder resaltar selección

local function clearListButtons()
	for _, v in ipairs(list:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
	table.clear(itemButtons)
end

local function highlightSelected()
	for name, btn in pairs(itemButtons) do
		tweenColor(btn, name == state.selectedItem
			and Color3.fromRGB(70, 130, 230)
			or Color3.fromRGB(45, 45, 45), 0.1)
	end
end

local function selectItem(name)
	state.selectedItem = name
	output.Text = "Seleccionado:\n" .. name
	highlightSelected()
end

local function render()
	clearListButtons()

	local skinsRoot = RS:FindFirstChild("Skins")
	local folder = skinsRoot and skinsRoot:FindFirstChild(state.selectedType)

	if not folder then
		output.Text = ("No se encontró RS.Skins.%s"):format(state.selectedType)
		return
	end

	local query = search.Text:lower()
	local order = 0

	for _, obj in ipairs(folder:GetChildren()) do
		if query == "" or obj.Name:lower():find(query, 1, true) then
			order += 1

			local btn = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				TextColor3 = Color3.fromRGB(230, 230, 230),
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Text = obj.Name,
				AutoButtonColor = false,
				LayoutOrder = order,
			}, list)
			corner(btn, 6)

			btn.MouseEnter:Connect(function()
				if state.selectedItem ~= obj.Name then
					tweenColor(btn, Color3.fromRGB(55, 55, 55), 0.1)
				end
			end)
			btn.MouseLeave:Connect(function()
				if state.selectedItem ~= obj.Name then
					tweenColor(btn, Color3.fromRGB(45, 45, 45), 0.1)
				end
			end)
			btn.MouseButton1Click:Connect(function()
				selectItem(obj.Name)
			end)

			itemButtons[obj.Name] = btn
		end
	end

	if order == 0 then
		output.Text = "No hay resultados."
	end

	highlightSelected()
end

--==============================
-- EVENTOS
--==============================
knifeTab.MouseButton1Click:Connect(function()
	state.selectedType = "Knives"
	state.selectedItem = nil
	refreshTabVisuals()
	render()
end)

gunTab.MouseButton1Click:Connect(function()
	state.selectedType = "Guns"
	state.selectedItem = nil
	refreshTabVisuals()
	render()
end)

search:GetPropertyChangedSignal("Text"):Connect(render)

addBtn.MouseButton1Click:Connect(function()
	if not state.selectedItem then
		output.Text = "Elegí un item antes de agregar."
		return
	end

	local n = tonumber(amount.Text)
	if not n or n <= 0 then
		n = 1
		amount.Text = "1"
	end

	state.visual[state.selectedItem] = (state.visual[state.selectedItem] or 0) + n
	output.Text = ("VISUAL:\n%s × %d"):format(state.selectedItem, state.visual[state.selectedItem])
end)

--==============================
-- INIT
--==============================
refreshTabVisuals()
render()
