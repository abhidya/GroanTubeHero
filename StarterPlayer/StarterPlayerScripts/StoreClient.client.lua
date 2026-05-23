local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MissionConfig = require(ReplicatedStorage.Shared.MissionConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local function ensureScreenGui(name)
    local existing = playerGui:FindFirstChild(name)
    if existing and not existing:IsA("ScreenGui") then existing:Destroy(); existing = nil end
    local gui = existing or Instance.new("ScreenGui")
    gui.Name = name
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    return gui
end
local function corner(parent, radius)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,radius or 12);c.Parent=parent end
local function stroke(parent,color)local s=Instance.new("UIStroke");s.Color=color or Color3.fromRGB(120,220,255);s.Thickness=2;s.Transparency=.15;s.Parent=parent end
local function label(parent,text,size,pos,color,font)
    local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Size=size;l.Position=pos;l.Text=text;l.TextColor3=color or Color3.new(1,1,1);l.Font=font or Enum.Font.GothamBold;l.TextScaled=true;l.TextWrapped=true;l.Parent=parent;return l
end
local function button(parent,text,size,pos,color)
    local b=Instance.new("TextButton");b.Size=size;b.Position=pos;b.Text=text;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBlack;b.TextScaled=true;b.BackgroundColor3=color or Color3.fromRGB(55,145,255);b.Parent=parent;corner(b,10);return b
end

local gui=ensureScreenGui("StoreGui")
gui.Enabled=true
gui:ClearAllChildren()

local openButton=button(gui,"Store",UDim2.new(0,120,0,42),UDim2.new(1,-138,1,-58),Color3.fromRGB(170,95,255))
local panel=Instance.new("Frame");panel.Name="StorePanel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.new(.5,0,.52,0);panel.Size=UDim2.new(0,800,0,520);panel.BackgroundColor3=Color3.fromRGB(12,14,28);panel.BackgroundTransparency=.10;panel.Visible=false;panel.Parent=gui;corner(panel,20);stroke(panel,Color3.fromRGB(80,225,255))
local title=label(panel,"Store & Progression",UDim2.new(1,-70,0,52),UDim2.new(0,20,0,12),Color3.new(1,1,1),Enum.Font.GothamBlack)
local close=button(panel,"X",UDim2.new(0,44,0,44),UDim2.new(1,-56,0,16),Color3.fromRGB(255,95,95))
local wallet=label(panel,"Coins 0 • Fans 0 • Tickets 0",UDim2.new(1,-40,0,30),UDim2.new(0,20,0,64),Color3.fromRGB(255,240,160),Enum.Font.GothamBold)
local tabsFrame=Instance.new("Frame");tabsFrame.BackgroundTransparency=1;tabsFrame.Size=UDim2.new(0,190,1,-110);tabsFrame.Position=UDim2.new(0,18,0,104);tabsFrame.Parent=panel
local list=Instance.new("ScrollingFrame");list.Name="Cards";list.BackgroundTransparency=1;list.Size=UDim2.new(1,-234,1,-116);list.Position=UDim2.new(0,214,0,104);list.CanvasSize=UDim2.new(0,0,0,900);list.ScrollBarThickness=8;list.Parent=panel

local currentTab="Upgrades"
local snapshot={Coins=0,Fans=0,Tickets=0,OwnedCosmetics={},Equipped={},Upgrades={},TourBus={},Missions={Daily={},Weekly={}}}
local tabs={"Upgrades","Tube Sounds","Stage Effects","Poses","Audience","Themes","Missions","Tour Bus"}
local items={
    ["Tube Sounds"]={{"ClassicTube","Default Groan","Your starter cursed tube.",0,"Coins","TubeSounds"},{"NeonGroan","Deep Sewer Tube","A glowing drainpipe wail.",120,"Fans","TubeSounds"},{"RustyWail","Squeaky Door Tube","Painfully heroic squeaks.",100,"Coins","TubeSounds"},{"RomanticTubeDisaster","Romantic Disaster Tube","Melodrama, but tube-shaped.",140,"Fans","TubeSounds"}},
    ["Stage Effects"]={{"DefaultGlow","Default Glow","Plain but dependable.",0,"Coins","StageEffects"},{"PurpleRift","Confetti Burst","A neon pop on big hits.",160,"Fans","StageEffects"},{"ChromeSpark","Smoke Machine Fail","Mostly smoke. Some regret.",180,"Coins","StageEffects"}},
    ["Poses"]={{"HeroPose","Mic Lean","Classic stage confidence.",0,"Coins","AvatarPoses"},{"CrookedBop","Knee Drop","Very committed. Maybe too much.",90,"Coins","AvatarPoses"},{"TubeLegend","Point at Crowd","Announce your cursed greatness.",150,"Fans","AvatarPoses"}},
    ["Audience"]={{"BasicCrowd","Confused Parents","Supportive but worried.",0,"Coins","AudiencePacks"},{"NeonFans","Hyper Kids","Maximum cheering chaos.",140,"Fans","AudiencePacks"},{"MallRegulars","Mall Food Court Crowd","They came for pretzels.",110,"Coins","AudiencePacks"}},
    ["Themes"]={{"SchoolBackdrop","School Stage","Beginner venue identity.",0,"Coins","StageThemes"},{"NeonArenaTheme","Neon Arena","Bright, loud, unforgettable.",150,"Fans","StageThemes"},{"WeddingGlow","Wedding Hall","Awkward romantic lighting.",130,"Coins","StageThemes"}},
}
local upgrades={{"Timing","Timing","Makes Good hits slightly easier.",120,"Recommended",6},{"HypeGain","Hype Gain","Build Hype faster from clean hits.",150,"Recommended",10},{"Recovery","Recovery","Miss streaks hurt less.",150,"",5},{"Stagecraft","Stagecraft","Better effects and more Fans.",170,"",10},{"Chaos","Chaos","Battle-only potency placeholder.",180,"Coming Soon",5},{"Focus","Focus","Resist battle distractions.",180,"",5},{"CoinBonus","Coin Bonus","Earn more Coins per song.",160,"Recommended",10},{"AudiencePower","Audience Power","Audience support gives more Hype.",160,"",8}}
local busUpgrades={{"BiggerSpeakers","Bigger Speakers","+Hype gain during performances.",120,"Coins",5},{"SnackStand","Snack Stand","Small bonus Fans after completed songs.",140,"Coins",5},{"PracticeSeat","Practice Seat","+XP from retries and replays.",130,"Coins",5},{"MerchBox","Merch Box","+Fans from audience participation.",150,"Fans",5},{"RoadCrew","Road Crew","Reduces venue fees.",180,"Coins",5},{"NeonWrap","Neon Wrap","Cosmetic Tour Bus flex.",100,"Fans",3}}

local function owned(category,id)return snapshot.OwnedCosmetics and snapshot.OwnedCosmetics[category] and snapshot.OwnedCosmetics[category][id] end
local function equipped(category,id)return snapshot.Equipped and snapshot.Equipped[category]==id end
local function canAfford(currency,cost)return cost<=0 or ((snapshot[currency] or 0) >= cost) end
local function clearList() for _,c in ipairs(list:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end end
local function card(y,titleText,desc,cost,currency,badge,onBuy,onEquip,buyText,equipText,affordable)
    local c=Instance.new("Frame");c.Size=UDim2.new(1,-12,0,124);c.Position=UDim2.new(0,0,0,y);c.BackgroundColor3=Color3.fromRGB(24,28,48);c.Parent=list;corner(c,14);stroke(c,Color3.fromRGB(80,225,255))
    label(c,titleText..(badge and badge~="" and ("  • "..badge) or ""),UDim2.new(.62,0,0,32),UDim2.new(0,14,0,10),Color3.new(1,1,1),Enum.Font.GothamBlack)
    label(c,desc,UDim2.new(.62,0,0,68),UDim2.new(0,14,0,46),Color3.fromRGB(215,225,255),Enum.Font.GothamBold)
    label(c,cost>0 and (cost.." "..currency) or "No cost",UDim2.new(.25,0,0,30),UDim2.new(.67,0,0,12),affordable~=false and Color3.fromRGB(255,240,160) or Color3.fromRGB(255,120,120),Enum.Font.GothamBlack)
    local buy=button(c,buyText or "Buy",UDim2.new(0,118,0,38),UDim2.new(1,-258,1,-50),affordable~=false and Color3.fromRGB(55,145,255) or Color3.fromRGB(95,95,110));buy.Activated:Connect(onBuy)
    if onEquip then local eq=button(c,equipText or "Equip",UDim2.new(0,118,0,38),UDim2.new(1,-130,1,-50),Color3.fromRGB(120,200,95));eq.Activated:Connect(onEquip) end
end

local function renderMissions()
    local y=0
    for listKey, defs in pairs(MissionConfig.GetAll()) do
        for _,def in ipairs(defs) do
            local state=snapshot.Missions and snapshot.Missions[listKey] and snapshot.Missions[listKey][def.id] or {progress=0,completed=false,claimed=false}
            local status=state.claimed and "Claimed" or (state.completed and "Complete — Claim" or "In Progress")
            local desc=string.format("%s / %s\nReward: Fans +%d  Coins +%d  XP +%d", tostring(state.progress or 0), tostring(def.target), def.rewardFans or 0, def.rewardCoins or 0, def.rewardXP or 0)
            card(y,def.title,desc,0,"",listKey.." • "..status,function()
                if state.completed and not state.claimed and remotes:FindFirstChild("ClaimMission") then remotes.ClaimMission:FireServer({missionId=def.id}) end
            end,nil,state.claimed and "Claimed" or (state.completed and "Claim" or "Tracked"),nil,true)
            y += 134
        end
    end
    list.CanvasSize=UDim2.new(0,0,0,y+20)
end

local function render()
    wallet.Text=string.format("Coins %d • Fans %d • Tickets %d",snapshot.Coins or 0,snapshot.Fans or 0,snapshot.Tickets or 0)
    title.Text="Store & Progression — "..currentTab
    clearList()
    if currentTab=="Upgrades" then
        for i,u in ipairs(upgrades) do
            local id,name,desc,cost,tag,max=table.unpack(u)
            local lvl=(snapshot.Upgrades and snapshot.Upgrades[id]) or 0
            local finalCost=math.floor(cost*(1.35^lvl))
            card((i-1)*134,name,"Level "..lvl.." / "..max.."\n"..desc.."\nNext effect improves future runs.",finalCost,"Coins",tag,function() remotes.PurchaseItem:FireServer({category="GameplayUpgrades",itemId=id}) end,nil,lvl>=max and "Maxed" or "Buy Upgrade",nil,canAfford("Coins",finalCost))
        end
        list.CanvasSize=UDim2.new(0,0,0,#upgrades*134+20)
    elseif currentTab=="Missions" then
        renderMissions()
    elseif currentTab=="Tour Bus" then
        for i,b in ipairs(busUpgrades) do
            local id,name,desc,cost,currency,max=table.unpack(b)
            local lvl=(snapshot.TourBus and snapshot.TourBus[id]) or 0
            local finalCost=math.floor(cost*(1.35^lvl))
            card((i-1)*134,name,"Level "..lvl.." / "..max.."\n"..desc.."\nUpgrade your career bonuses here.",finalCost,currency,"Tour Bus",function() remotes.PurchaseItem:FireServer({category="TourBus",itemId=id}) end,nil,lvl>=max and "Maxed" or "Buy",nil,canAfford(currency,finalCost))
        end
        list.CanvasSize=UDim2.new(0,0,0,#busUpgrades*134+20)
    else
        for i,it in ipairs(items[currentTab] or {}) do
            local id,name,desc,cost,currency,category=table.unpack(it)
            local isOwned=owned(category,id) or cost==0
            local isEquipped=equipped(category,id)
            card((i-1)*134,name,desc,cost,currency,isEquipped and "Equipped" or (isOwned and "Owned" or ""),function() remotes.PurchaseItem:FireServer({category=category,itemId=id}) end,function() remotes.EquipItem:FireServer({category=category,itemId=id}) end,isOwned and "Owned" or "Buy",isEquipped and "Equipped" or "Equip",canAfford(currency,cost))
        end
        list.CanvasSize=UDim2.new(0,0,0,math.max(1,#(items[currentTab] or {}))*134+20)
    end
end

for i,t in ipairs(tabs) do
    local b=button(tabsFrame,t,UDim2.new(1,0,0,38),UDim2.new(0,0,0,(i-1)*44),i==1 and Color3.fromRGB(255,175,70) or Color3.fromRGB(40,45,70))
    b.Activated:Connect(function() currentTab=t; render() end)
end
openButton.Activated:Connect(function() panel.Visible=not panel.Visible; render() end)
close.Activated:Connect(function() panel.Visible=false end)
gui:GetAttributeChangedSignal("Open"):Connect(function() if gui:GetAttribute("Open") then panel.Visible=true; currentTab=gui:GetAttribute("Tab") or currentTab; render(); gui:SetAttribute("Open",false) end end)
gui:GetAttributeChangedSignal("Tab"):Connect(function() currentTab=gui:GetAttribute("Tab") or currentTab; render() end)
remotes.DataSnapshot.OnClientEvent:Connect(function(s) if s then snapshot=s; render() end end)
render()
