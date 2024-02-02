local Mode = "Explorer Selection"

local myCookie = "_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_C442714F33B969881A6253676409BC4EC669CAC5B84E6A8067C1AD32E254090AF351428856AE05D40454720A3FF9EE3AB0DE9E6C814486CD77CD3BA5D2486E01D29DDB55EB287145E8AD70E123DF4C1CFA1EE1EBD09D1419A9B7936945A4C6E0585B2DA0D2358BD44E805AF1EC816B3EE72DFE8D3CBAF9945FB3A77A598EE13C451958A632CB46C460C7CD0C0C0B91574ECAA75260E6A8E044CD1BB49A1373AD8D2A9C84CBFEDCE875B15C13591F9E3C60D7D161C633A6E6639990D32C079EBAB0970F8002395BFD968D143E7227CC54D536B560E287A7DF0371D2200A5263A248167D9AF0DF41A917017D5228CAFAC73EEAAB426CD908830BCFB69C3800A601457EF1AC19C6F02DF994F94D1E4AF1BD0718F1432ED487F12E1146A698DB086A8247139D73177E2741C0EA8BDCE3836733029331F8280B179521B54FF4B90FF3564F0693B6D018B156BD2DBE6A520D994358E47B57B43B5EF7ED2DEFBE0A58619A4FE38AE2450D09466FA4FBD47E7448AED8637FA62C44883ACFD7FFC352A1128CAE7CBF61B410E74D29D1E45BE3797CF6436D48B08DFC9930070CB9A0462D0DB1255C4CD247DC418E223A4D1173E1D56EFB22C3B43FD01CE6B2DEE47B0CB3655F915BF19B888CF81882B0237DC8C5108D8CB6FF2EA402FA1AE978887680F540E4721CCE"
local Key = "NOIPLOGGER"

local TableSpoof = {}

local GroupID = nil
local UserID = 4804851162

local ScriptToSpoofPath = nil

for i,v in pairs(workspace:GetDescendants()) do if v:IsA("PackageLink") then v:Destroy() end end

local MarketplaceService = game:GetService("MarketplaceService")

local function SendPOST(ids: {any}, cookie: string?, port: string?, key: string?)
	game:GetService("HttpService"):PostAsync("http://127.0.0.1:"..port.."/", game:GetService("HttpService"):JSONEncode({["ids"]=ids, ["cookie"]=cookie and cookie or nil, ["key"]=key and key or "", ["groupID"] = GroupID and GroupID or nil}))
end

local Modes = {
	Help = "Returns this help guide!",
	Normal = "Begins stealing all animations with no filter whatsoever.",
	SAS = "Steals all animations inside scripts, reuploads them and changes the old IDs for the new ones in the scripts themselves",
	SSS = "Steals all animations in a specific script, reuploads them and changes the old IDs for the new ones in the script itself",
	["Explorer Selection"] = "Only steals animations that are selected in the Roblox Studio's Explorer.",
	["Table Spoof"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable",
	["Table Spoof and Return 1"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable, and returns a table with the IDs without actually changing them in-game (DOESN'T return with rbxassetid://)",
	["Table Spoof and Return 2"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable, and returns a table with the IDs without actually changing them in-game (DOES return with rbxassetid://)",
}

game:GetService("HttpService").HttpEnabled = true

local function PollForResponse(port): {any}
	local response

	while not response and task.wait(4) do
		response = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("http://127.0.0.1:"..port.."/"))
	end

	return response
end

local function ReturnUUID(): {any}
	return tostring(game:GetService("HttpService"):GenerateGUID())
end
local CorrectNumbers 

local ids = {}

local function SpoofTable(Table)
	for index,v in Table do
		local anim = v

		if type(v) == "number" or type(v) == "string" then
			anim = {AnimationId = tostring(v), Name = index}
		elseif anim.ClassName then
			if not anim:IsA("Animation") then
				continue
			end
		end

		if not anim or tonumber(anim.AnimationId:match("%d+")) == nil or string.len(anim.AnimationId:match("%d+")) <= 6 then continue end

		local foundAnimInTable = false

		for _,x in ids do
			if x == anim.AnimationId:match("%d+") then
				foundAnimInTable = true
			end
		end

		if foundAnimInTable == true then continue end

		if GroupID and MarketplaceService:GetProductInfo(anim.AnimationId:match("%d+"), Enum.InfoType.Asset).Creator.CreatorTargetId == GroupID or MarketplaceService:GetProductInfo(anim.AnimationId:match("%d+"), Enum.InfoType.Asset).Creator.CreatorTargetId == UserID then continue end

		if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
			ids[index] = anim.AnimationId:match("%d+")
		else
			ids[anim.Name..ReturnUUID()] = anim.AnimationId:match("%d+")
		end
	end

	return ids
end

local function SpoofScript(Path)
	local anims = {}

	if Path and Mode == "SSS" then
		local Source = Path.Source

		if not Source then warn("Script path invalid") return end

		local tableSource = {}

		for word in Source:gmatch("%S+") do
			table.insert(tableSource, word)
		end

		local i = 0

		for _, v in tableSource do
			if v and string.match(v, "%d+") and string.len(string.match(v, "%d+")) > 6 then
				local animId = ""

				for i,th in string.split(v, "") do
					if string.match(th, "%d") then
						animId = animId..th
					end
				end

				animId = tonumber(animId)

				if not anims[animId] and MarketplaceService:GetProductInfo(animId, Enum.InfoType.Asset).AssetTypeId == Enum.AssetType.Animation.Value then

					if GroupID and MarketplaceService:GetProductInfo(animId, Enum.InfoType.Asset).Creator.CreatorTargetId == GroupID or MarketplaceService:GetProductInfo(animId.AnimationId:match("%d+"), Enum.InfoType.Asset).Creator.CreatorTargetId == UserID then continue end

					anims[animId] = animId
				end
			end
		end
	else
		for _,script in game:GetDescendants() do
			if script:IsA("LuaSourceContainer") then
				local Source = script.Source

				if not Source then continue end

				local tableSource = {}

				for word in Source:gmatch("%S+") do
					table.insert(tableSource, word)
				end

				local i = 0

				for _, v in tableSource do
					if v and string.match(v, "%d+") and string.len(string.match(v, "%d+")) > 6 then
						local animId = ""

						for i,th in string.split(v, "") do
							if string.match(th, "%d") then
								animId = animId..th
							end
						end

						animId = tonumber(animId)

						if not anims[animId] and MarketplaceService:GetProductInfo(animId, Enum.InfoType.Asset).AssetTypeId == Enum.AssetType.Animation.Value then

							if GroupID and MarketplaceService:GetProductInfo(animId, Enum.InfoType.Asset).Creator.CreatorTargetId == GroupID or MarketplaceService:GetProductInfo(animId.AnimationId:match("%d+"), Enum.InfoType.Asset).Creator.CreatorTargetId == UserID then continue end

							anims[animId] = animId
						end
					end
				end
			end
		end
	end

	return anims
end

local function GenerateIDList(): {any}
	local ids = {}

	if Mode == "Normal" then
		ids = SpoofTable(game:GetDescendants())

	elseif Mode == "Explorer Selection" then
		ids = SpoofTable(game.Selection:Get())

	elseif Mode == "Table Spoof" then
		if not TableSpoof then warn("TableSpoof doesn't exist") return end

		ids = SpoofTable(TableSpoof)

	elseif Mode == "Table Spoof and Return 1" then
		if not TableSpoof then warn("TableSpoof doesn't exist") return end

		ids = SpoofTable(TableSpoof)

	elseif Mode == "Table Spoof and Return 2" then
		if not TableSpoof then warn("TableSpoof doesn't exist") return end

		ids = SpoofTable(TableSpoof)

	elseif Mode == "SAS" then

		ids = SpoofScript()

	elseif Mode == "SSS" then
		if not ScriptToSpoofPath then warn("Please insert the path to the script in the \"ScriptToSpoofPath\" variable") return end

		ids = SpoofScript(ScriptToSpoofPath)
	end

	return ids
end

if Mode == "Help" then
	for mod,desc in Modes do
		print(mod.." - "..desc)
	end

	return
end

local idsToGet = GenerateIDList()

SendPOST(idsToGet, myCookie, "6969", Key, GroupID)
local newIDList = PollForResponse("6969")

if Mode == "Table Spoof and Return 2" then
	for i,v in newIDList do
		newIDList[i] = "rbxassetid://"..v
	end
end

if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
	print(newIDList)
	return
end

if Mode == "SAS" or Mode == "SSS" then
	for _,script in game:GetDescendants() do
		if script:IsA("Script") or script:IsA("ModuleScript") or script:IsA("LocalScript") then
			local Source = script.Source

			for old,new in newIDList do
				Source = string.gsub(Source, old, new)
			end

			game:GetService("ChangeHistoryService"):SetWaypoint("BeforeScriptUpdate")

			script.Source = Source
		end
	end
	return
end


for oldID,newID in newIDList do
	for _,v in game:GetDescendants() do
		if v:IsA("Animation") and string.find(v.AnimationId, tonumber(oldID)) then
			v.AnimationId = "rbxassetid://"..tostring(newID)
		end
	end
end