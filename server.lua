local zones = {
    {
        name = "Solo Strefa - #Miasto",
        coords = vector3(1202.4245605469, -1328.1773681641, 35.226963043213),
        blipColor = 2,
        reward = 1000,
        isCaptured = false,
        capturingPlayer = nil,
		playerName = nil
    },
    {
        name = "Solo Strefa - #Mleczarnia",
        coords = vector3(2877.208984375, 4461.0795898438, 48.516387939453),
        blipColor = 2,
        reward = 1000,
        isCaptured = false,
        capturingPlayer = nil,
		playerName = nil
    },
	{
        name = "Solo Strefa - #Zlomowisko",
        coords = vector3(2351.5490722656, 3132.6945800781, 48.208679199219),
        blipColor = 2,
        reward = 1000,
        isCaptured = false,
        capturingPlayer = nil,
		playerName = nil
    },
	{
        name = "Solo Strefa - #S1",
        coords = vector3(1552.232910, 2197.608886, 77.835206),
        blipColor = 2,
        reward = 1000,
        isCaptured = false,
        capturingPlayer = nil,
		playerName = nil
    },
}
local captureTime = 130

local function getZoneByName(zoneName)
    for _, zone in pairs(zones) do 
        if zone.name == zoneName then 
            return zone 
        end 
    end 
    return nil 
end 

RegisterNetEvent("michalxdl-solozone/attemptCapture", function(zoneName) 
	local playerId = source 
	local xPlayer = ESX.GetPlayerFromId(playerId) 
	local playerName = GetPlayerName(playerId) 
	local zone = getZoneByName(zoneName) 

	if not zone then 
		xPlayer.showNotification("Strefa nie istnieje.") 
		return 
	end 

	if zone.isCaptured and zone.capturingPlayer ~= playerId then
		xPlayer.showNotification("Inny gracz już przejmuje tę strefę.") 
		return 
	end 

	zone.isCaptured = false 
	zone.capturingPlayer = playerId 
	zone.playerName = playerName
    TriggerClientEvent('chat:addMessage1', -1, source, "Strefy", playerName, "przejmuje strefę [" .. zoneName .. "]", "#F8122E", "#F8122E")
	TriggerClientEvent('chat:addMessage1',-1, "Solo Strefa", {20,20,20},"GRACZ: " .. playerName .. " przejmuje strefę [" .. zoneName .. "]","fa-solid fa-person", {255, 255, 255}, "#dc9314")
	 TriggerClientEvent('michalxdl:chatMessage', -1 ,'#99ccff' ,'fa-solid fa-message' ,'Strefa Solo' ,"GRACZ: " .. playerName .. " przejmuje strefę [" .. zoneName .. "]") 
	TriggerClientEvent("michalxdl-solozone/updateZoneStatus", -1 ,zoneName ,false ,playerId ,captureTime ,playerName) 

	Player(playerId).state.isCapturing = true 

	Citizen.CreateThread(function() 
		Citizen.Wait(captureTime *1000) 
		local src = source
    	local xPlayer = ESX.GetPlayerFromId(src)
		if zone.capturingPlayer == playerId then 
			zone.isCaptured = true 
            TriggerClientEvent('chat:addMessage1', -1, source, "Strefy", playerName, "przejął strefę [" .. zoneName .. "]!", "#F8122E", "#F8122E")

			 TriggerClientEvent('chat:addMessage1',-1, "Solo Strefa", {0,255,0}, "GRACZ: " .. playerName .. " przejął strefę [" .. zoneName .. "]!", "fa-solid fa-person", {255, 255, 255}, "#dc9314")
			 TriggerClientEvent('michalxdl:chatMessage', -1 ,'#99ccff' ,'fa-solid fa-message' ,'Strefa Solo' ,"GRACZ: " .. playerName .. " przejął strefę [" .. zoneName .. "]!") 
			TriggerClientEvent("michalxdl-solozone/updateZoneStatus", -1 ,zoneName ,true ,playerId ,nil ,playerName) 
			TriggerEvent("michalxdl-solozone/rewardPlayer" ,playerId ,zoneName) 
		else 
			zone.isCaptured = false 
			zone.capturingPlayer = nil 
			 Player(source).state.isCapturing = false 
			TriggerClientEvent("michalxdl-solozone/updateZoneStatus", -1 ,zone.name ,false ,nil) 
		end 
		
		Player(playerId).state.isCapturing=false 
	end) 
end)

RegisterNetEvent("michalxdl-solozone/initializeZones", function() 
	local playerId=source 
	for _, zone in pairs(zones) do 
		TriggerClientEvent("michalxdl-solozone/createZone" ,playerId ,zone) 
	end 
end)

RegisterNetEvent("michalxdl-solozone/rewardPlayer", function(playerId ,zoneName) 
	local xPlayer=ESX.GetPlayerFromId(playerId) 
	local zone=getZoneByName(zoneName) 

	if zone and zone.isCaptured and zone.capturingPlayer==playerId then 
		if not zone.rewardGiven then 
			zone.rewardGiven=true 
			xPlayer.addMoney(zone.reward)

			xPlayer.addInventoryItem("clip", 10)
            xPlayer.addInventoryItem("handcuffs", 5)
            xPlayer.addInventoryItem("energydrink", 50)
            xPlayer.addInventoryItem('z_michalxdlkeys', math.random(1,3))
			
			xPlayer.showNotification("Otrzymujesz itemy za przejęcie " .. zoneName)
		else 
			xPlayer.showNotification("Już otrzymałeś nagrodę za tę strefę.") 
		end 
	end 
end)

RegisterNetEvent("michalxdl-solozone/cancelCapture", function(zoneName)


    local zone = getZoneByName(zoneName)
    if zone then
        zone.isCaptured = false
        zone.capturingPlayer = nil
        Player(source).state.isCapturing = false
        zone.playerName = playerName
        TriggerClientEvent('chat:addMessage1', -1, source, "Strefy", playerName, "Przejmowanie strefy [" .. zoneName .. "] zostało anulowane!", "#F8122E", "#F8122E")
         TriggerClientEvent('chat:addMessage1', -1, "Solo Strefa", {255, 0, 0}, "Przejmowanie strefy [" .. zoneName .. "] zostało anulowane!", "fa-solid fa-person", {255, 255, 255}, "#dc9314")
        TriggerClientEvent("michalxdl-solozone/updateZoneStatus", -1, zone.name, false, nil, nil)     
    end
end)


AddEventHandler('esx:playerDropped',function(playerId)  
	for _, zone in pairs(zones) do  
	    if zone.capturingPlayer==playerId then  
	        zone.isCaptured=false  
	        zone.capturingPlayer=nil  
	        TriggerClientEvent("michalxdl-solozone/updateZoneStatus",-1 ,zone.name,false,nil,nil)  
	    end  
	end  
end)
