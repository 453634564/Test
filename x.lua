local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name="SkinVisualMenu"
gui.Parent=player.PlayerGui
gui.ResetOnSpawn=false

--------------------------------

local selectedType="Knives"
local selected=nil

local function create(c,p)
	local o=Instance.new(c)
	o.Parent=p
	return o
end

--------------------------------

local frame=create("Frame",gui)

frame.Size=UDim2.fromScale(.5,.7)
frame.Position=UDim2.fromScale(.25,.15)
frame.BackgroundColor3=Color3.fromRGB(25,25,25)

create("UICorner",frame)

local tabs=create("Frame",frame)

tabs.Size=UDim2.new(1,0,0,45)

local knife=create("TextButton",tabs)
knife.Size=UDim2.new(.5,0,1,0)
knife.Text="KNIVES"

local gun=create("TextButton",tabs)
gun.Position=UDim2.new(.5,0,0,0)
gun.Size=UDim2.new(.5,0,1,0)
gun.Text="GUNS"

local search=create("TextBox",frame)

search.Position=UDim2.new(.05,0,.12,0)
search.Size=UDim2.new(.9,0,0,35)

search.PlaceholderText="Buscar..."

local list=create("ScrollingFrame",frame)

list.Position=UDim2.new(.05,0,.22,0)
list.Size=UDim2.new(.9,0,.45,0)

local layout=create("UIListLayout",list)

local amount=create("TextBox",frame)

amount.Position=UDim2.new(.05,0,.72,0)
amount.Size=UDim2.new(.3,0,0,40)

amount.Text="1"

local add=create("TextButton",frame)

add.Position=UDim2.new(.4,0,.72,0)
add.Size=UDim2.new(.55,0,0,40)

add.Text="Agregar visual"

local output=create("TextLabel",frame)

output.Position=UDim2.new(.05,0,.82,0)
output.Size=UDim2.new(.9,0,.13,0)

output.TextWrapped=true
output.TextScaled=true
output.BackgroundColor3=Color3.fromRGB(40,40,40)

--------------------------------

local visual={}

local function render()

	for _,v in list:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	local folder=
		RS.Skins[selectedType]

	for _,obj in ipairs(
		folder:GetChildren()
	) do

		if
			search.Text==""
			or
			obj.Name:lower():find(
				search.Text:lower(),
				1,
				true
			)
		then

			local b=create(
				"TextButton",
				list
			)

			b.Size=
			UDim2.new(
				1,
				-5,
				0,
				35
			)

			b.Text=obj.Name

			b.MouseButton1Click:Connect(
			function()

				selected=obj.Name

				output.Text=
				"Seleccionado:\n"
				..obj.Name

			end)

		end

	end

end

knife.MouseButton1Click:Connect(function()

	selectedType="Knives"

	render()

end)

gun.MouseButton1Click:Connect(function()

	selectedType="Guns"

	render()

end)

search:GetPropertyChangedSignal(
"Text"
):Connect(render)

add.MouseButton1Click:Connect(function()

	if not selected then
		return
	end

	local n=
	tonumber(
	amount.Text
	)
	or 1

	visual[selected]=
	(visual[selected] or 0)
	+n

	output.Text=
	"VISUAL:\n"
	..selected
	.." × "
	..visual[selected]

end)

render()
