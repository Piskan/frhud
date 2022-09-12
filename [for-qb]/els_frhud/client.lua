

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = nil
local kemertakilimi = false
local aracsabitmi =  false
local aracicinde = false
local gecekpedimiz = nil
local hiz = nil
local arac = nil
local sabitlenmishiz = 0
local currSpeed = 0.0
local seatbeltEjectSpeed = 45.0 
local seatbeltEjectAccel = 100.0
local gecerlideger = {}
local needhudaktif = true
local weaponhudaktif = true
local keyinfohudaktif = true
local bankcashhudaktif = true
local jobhudaktif = true
gecerlideger.hunger = 0
gecerlideger.thirst = 0
gecerlideger.stamina = 100

local directions = { [0] = 'NB', [45] = 'North-West', [90] = 'West Bound', [135] = 'South-West', [180] = 'South Bound', [225] = 'South-East', [270] = 'East Bound', [315] = 'North-East', [360] = 'North Bound', }



RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    PlayerData = QBCore.Functions.GetPlayerData()
end)

-- PlayerData = QBCore.Functions.GetPlayerData() --- open if you need restart for test :)
Citizen.CreateThread(function()

	while true do
		Citizen.Wait(200)					
		 gecekpedimiz = PlayerPedId()
		
		if IsPedInAnyVehicle(gecekpedimiz, false) and not IsPauseMenuActive() then
             arac = GetVehiclePedIsUsing(PlayerPedId())
             hiz = math.ceil(GetEntitySpeed(arac) * 3.605936)
           
            local vites = GetVehicleCurrentGear(arac)
            local aracbenzin = GetVehicleFuelLevel(arac)
            local rpm = GetVehicleCurrentRpm(arac)
            local vname = GetDisplayNameFromVehicleModel(GetEntityModel(arac))
            local doorlock = GetVehicleDoorLockStatus(arac)
            local burst = false
            local hepbir ,kisalar, uzunlar =GetVehicleLightsState(arac)
            local araccan = GetVehicleBodyHealth(arac)
            dataevent()
             for i=0,4 do
               if IsVehicleTyreBurst(arac, i, 0) then
                  burst = true
               end
             end
            
            local aracfardurum = {
                farkisa = kisalar,
                faruzunlar = uzunlar
            }

            aracicinde = true
       
            if PlayerData ~= nil then	
                SendNUIMessage({
                    message = 'arachud',
                    durum = "aktif",
                    arachiz = hiz,
                    vites = vites,
                    aracbenzin = aracbenzin,
                    araccan = araccan,
                    aracfar = aracfardurum,
                    sabitlenmishiz = sabitlenmishiz,
                    aracsabitmi = aracsabitmi,
                    rpm = rpm,
                    vehiclename = vname,
                    doorlock = doorlock,
                    vehicletyre = burst
        

                    
            
            
                })
            end

            DisplayRadar(true)
           
		else
            aracicinde = false
            kemertakilimi = false
            aracsabitmi= false
            SendNUIMessage({
                message = 'arackemer',
                kemerdurum = "off"

            })
            Citizen.Wait(1000)	
            if PlayerData ~= nil then	
                SendNUIMessage({
                    message = 'arachud',
                    durum = "kapali",
                    mapacikmi = IsPauseMenuActive()
                    
            
            
                })
            end
            DisplayRadar(false)
		end
	end
end)


Citizen.CreateThread(function()

	while true do
		Citizen.Wait(5)	
        if aracicinde then
      

            if IsControlJustReleased(0, 29) then 
            
                if kemertakilimi == false then
                    kemertakilimi = true
                    SendNUIMessage({
                        message = 'arackemer',
                        kemerdurum = "aktif"

                    })
                    TriggerEvent("InteractSound_CL:PlayOnOne","carbuckle",0.8)
                
                else
                    kemertakilimi = false
                    SendNUIMessage({
                        message = 'arackemer',
                        kemerdurum = "off"

                    })
                    TriggerEvent("InteractSound_CL:PlayOnOne","carunbuckle",0.8)
                
                end
            
            
            end

            if IsControlJustReleased(0, 137) then 
                if GetPedInVehicleSeat(arac, -1) then
            
                    if aracsabitmi == false then
                        aracsabitmi = true
                    
                        SetVehicleMaxSpeed( arac,GetEntitySpeed(arac) )
                        sabitlenmishiz = hiz
                        
                    
                    
                
                    else
                        aracsabitmi = false
                        SetVehicleMaxSpeed( arac,0 )
                
                    end
               end
           end
        else
        Citizen.Wait(1000)	
        end
    end

end)

Citizen.CreateThread(function()

	while true do
		Citizen.Wait(2000)	
          if IsPedInAnyVehicle(gecekpedimiz) == 1 then
            updatePosition()
            updateClock()
                if not kemertakilimi then
                    if hiz ~= nil then
                        if hiz > 30 then
                
                        TriggerEvent("InteractSound_CL:PlayOnOne","beltalarm",0.8)
                        end
                    -- break
                    end
                end
            end
     end

end)


function dataevent()
    -- AddEventHandler('gameEventTriggered', function (name, args)
     
      if IsPedInAnyVehicle(gecekpedimiz) == 1 then
      
        -- updatePosition()
        -- updateClock()
        local prevSpeed = currSpeed
         currSpeed = GetEntitySpeed(arac)
         local vehIsMovingFwd = GetEntitySpeedVector(arac, true).y > 1.0
         local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
      
        if kemertakilimi == false then
            if ( hiz > (seatbeltEjectSpeed/2.237) and vehIsMovingFwd and (vehAcc > (seatbeltEjectAccel*9.81))) then
                local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
                local position = GetEntityCoords(gecekpedimiz)
                SetEntityCoords(gecekpedimiz, position.x, position.y, position.z - 0.47, true, true, true)
                SetEntityVelocity(gecekpedimiz, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                Citizen.Wait(1)
                SetPedToRagdoll(gecekpedimiz, 1000, 1000, 0, 0, 0, 0)
            end
        end
     end
    -- end)
end


function updatePosition()
 
    local playerCoords = GetEntityCoords(gecekpedimiz)
    local street, cross = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local streetName = GetStreetNameFromHashKey(street)
    local crossName
    if cross ~= nil then
        crossName =  ', '..GetStreetNameFromHashKey(cross)
    else
        crossName = ''
    end

    -- for k,v in pairs(directions)do
    --     direction = GetEntityHeading(gecekpedimiz)
    --     if(math.abs(direction - k) < 22.5)then
    --         direction = v
    --         break
    --     end
    -- end
  
    SendNUIMessage({
        status = "updateStreet",
        street = streetName..crossName
        -- direction = direction
    })
end


function updateClock()
    local hour, minute
    if GetClockHours() < 10 then
        hour = '0'..GetClockHours()
    else
        hour = GetClockHours()
    end
    if GetClockMinutes() < 10 then
        minute = '0'..GetClockMinutes()
    else
        minute = GetClockMinutes()
    end
    local time = hour..':'..minute
    SendNUIMessage({
        status = "updateClock",
        time = time
    })
end
----------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('els_frhud:progress')
AddEventHandler('els_frhud:progress', function(progtext,progtime)
    SendNUIMessage({
        status = "progresson",
        progtext = progtext,
        progtime = progtime
    })
end)


RegisterCommand("progresstry", function()
    
  TriggerEvent('els_frhud:progress', 'Mrblar tatlı şiii', 3000)
end)

RegisterCommand("notifykullan", function()
    
    TriggerEvent('els_frhud:client:notifyon', 'error', 'Denemeler', 5000)
    TriggerEvent('els_frhud:client:notifyon', 'inform', 'Denemeler', 5000)
    TriggerEvent('els_frhud:client:notifyon', 'success', 'Denemeler', 5000)

  end)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst) 
    gecerlideger.hunger = newHunger
    gecerlideger.thirst = newThirst
end)


RegisterNetEvent('hud:client:UpdateStress', function(newStress) -- Add this event with adding stress elsewhere
    gecerlideger.stress = newStress
end)

Citizen.CreateThread(function()
    while true do
    if PlayerData ~= nil then
    gecerlideger.hunger = QBCore.Functions.GetPlayerData().metadata.hunger
    gecerlideger.thirst = QBCore.Functions.GetPlayerData().metadata.thirst
    gecerlideger.stress = QBCore.Functions.GetPlayerData().metadata.stress	
    break
    end
    Citizen.Wait(1000)
    end


end)




Citizen.CreateThread(function()
	
	while true do
		Citizen.Wait(1000)
       if PlayerData ~= nil then

          

            if (Config.OpenSettings.needhud and needhudaktif == true and not IsPauseMenuActive()) then
                
           
                if IsPedRunning(gecekpedimiz) then
                    if gecerlideger["stamina"] > 0 then
                    gecerlideger["stamina"] = gecerlideger["stamina"] - 10
                    end
                else
                    if gecerlideger["stamina"] < 100 then
                    gecerlideger["stamina"] = gecerlideger["stamina"] + 5
                    end
                end
              

                SendNUIMessage({
                    message = 'oyuncuyemekhud',
                    durm = "on",
                    can = (GetEntityHealth(gecekpedimiz) - 100),
                    yelek = GetPedArmour(gecekpedimiz),
                    aclik = gecerlideger["hunger"],
                    susuzluk = gecerlideger["thirst"],
                    playeridisi = GetPlayerServerId(PlayerId()),
                    playerstamina = gecerlideger["stamina"]

            

                })
            else
                SendNUIMessage({
                    message = 'oyuncuyemekhud',
                    durm = "off"
                

            

                })
            end
            if Config.OpenSettings.weapon == true and weaponhudaktif == true and not IsPauseMenuActive() then
                if GetSelectedPedWeapon(gecekpedimiz) == -1569615261 then
                
                    SendNUIMessage({
                        message = 'weaponmod',
                        stateweapon = "off"
                    })
                else
                    if Config.WeaponList[tostring(GetSelectedPedWeapon(gecekpedimiz))] ~= nil then
                        if Config.WeaponList[tostring(GetSelectedPedWeapon(gecekpedimiz))].bullet == true then
                        
                            SendNUIMessage({
                                message = 'weaponmod',
                                stateweapon = "on",
                                statebullet= true,
                                weaponame = Config.WeaponList[tostring(GetSelectedPedWeapon(gecekpedimiz))].label,
                                weaponimg = Config.WeaponList[tostring(GetSelectedPedWeapon(gecekpedimiz))].value,
                                weaponbullet = GetAmmoInPedWeapon(gecekpedimiz, GetSelectedPedWeapon(gecekpedimiz)),
                                maxweapon = GetMaxAmmoInClip(gecekpedimiz, GetSelectedPedWeapon(gecekpedimiz), 1)
                                  

                            })
                    else
                            SendNUIMessage({
                                message = 'weaponmod',
                                stateweapon = "on",
                                statebullet= false,
                                weaponimg = Config.WeaponList[tostring(GetSelectedPedWeapon(gecekpedimiz))].value,
                                weaponame = Config.WeaponList[tostring(GetSelectedPedWeapon(gecekpedimiz))].label,
                                maxweapon = GetMaxAmmoInClip(gecekpedimiz, GetSelectedPedWeapon(gecekpedimiz), 1)
                            })
                    end
                    end

                end
            else
                SendNUIMessage({
                    message = 'weaponmod',
                    stateweapon = "off"
                })
            end

          
            
           
        end
      
    end
end)






RegisterNetEvent('els_frhud:client:notifyon')
AddEventHandler('els_frhud:client:notifyon', function(style,text,time)
	ontofiy(style,text,time)
end)

function ontofiy(style,text,time)
	SendNUIMessage({
        message = "notify",
		type = style,
		text = text,
		length = time or 1000
	
	})
end