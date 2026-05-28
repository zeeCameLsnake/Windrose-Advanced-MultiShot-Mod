-- List of weapon logic parameter paths that should receive the MultiShot ability
local ADVANCED_WEAPON_PATHS = {
    -- Pistols:
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_OffHand/Pistol_Corrupted_Advanced/RangeWpn/DA_RangeWpn_Pistol_Corrupted_Advanced_LogicParams.DA_RangeWpn_Pistol_Corrupted_Advanced_LogicParams",
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_OffHand/Pistol_DrakesDoom_Advanced/RangeWpn/DA_RangeWpn_Pistol_DrakesDoom_Advanced_LogicParams.DA_RangeWpn_Pistol_DrakesDoom_Advanced_LogicParams",
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_OffHand/Pistol_Reliable_Advanced/RangeWpn/DA_RangeWpn_Pistol_Reliable_Advanced_LogicParams.DA_RangeWpn_Pistol_Reliable_Advanced_LogicParams",
	-- Blunderbuss:
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_TwoHand/Blunderbuss_Dragonbreath_Advanced/RangeWpn/DA_RangeWpn_Blunderbuss_Dragonbreath_Advanced_LogicParams.DA_RangeWpn_Blunderbuss_Dragonbreath_Advanced_LogicParams",
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_TwoHand/Blunderbuss_Reliable_Advanced/RangeWpn/DA_RangeWpn_Blunderbuss_Reliable_Advanced_LogicParams.DA_RangeWpn_Blunderbuss_Reliable_Advanced_LogicParams",
	-- Muskets:
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_TwoHand/Musket_Infantry_Advanced/RangeWpn/DA_RangeWpn_Musket_Infantry_Advanced_LogicParams.DA_RangeWpn_Musket_Infantry_Advanced_LogicParams",
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_TwoHand/Musket_Reliable_Advanced/RangeWpn/DA_RangeWpn_Musket_Reliable_Advanced_LogicParams.DA_RangeWpn_Musket_Reliable_Advanced_LogicParams",
		"/Game/Gameplay/ItemsLogic/Weapon/Wpn_TwoHand/Musket_Sniper_Advanced/RangeWpn/DA_RangeWpn_Musket_Sniper_Advanced_LogicParams.DA_RangeWpn_Musket_Sniper_Advanced_LogicParams",
}

-- Cache vanilla clip sizes to safely scale weapons regardless of how often the script runs
local VANILLA_CLIP_SIZES = {}

local function GetMultiShotClass()
    local MultiShotPath = "/Game/Gameplay/Character/Common/GameplayAbilities/RangeWeapon/MultiShotAbility/GA_RangeWeapon_MultiShot.GA_RangeWeapon_MultiShot_C"
    local MultiShotClass = StaticFindObject(MultiShotPath)
    if not MultiShotClass or not MultiShotClass:IsValid() then
        local ok, loaded = pcall(function()
            return LoadAsset(MultiShotPath)
        end)
        if ok then MultiShotClass = loaded end
    end
    
    if not MultiShotClass then
        print("[Mod] Error: Could not load MultiShotClass.")
        return nil
    end
    return MultiShotClass
end

local function ApplyMultiShotToWeapon(WeaponLogicParams, WeaponLogicPath, MultiShotClass)
    local currentClipSize = WeaponLogicParams.CommonData.MaxClipSize
    
    -- Memorize the vanilla clip size the very first time we see this weapon
    if not VANILLA_CLIP_SIZES[WeaponLogicPath] then
        VANILLA_CLIP_SIZES[WeaponLogicPath] = currentClipSize
    end
    
    local vanillaSize = VANILLA_CLIP_SIZES[WeaponLogicPath]
    local targetSize = 2

    if vanillaSize == 1 then
        targetSize = 2
    elseif vanillaSize == 2 then
        targetSize = 3
    elseif vanillaSize >= 3 then
        targetSize = 5
    end
    
    -- 1. Idempotent assignment
    WeaponLogicParams.CommonData.MaxClipSize = targetSize
    
    local AbilitiesArray = WeaponLogicParams.R5EquipmentItemLogicData.GrantedAbilities
    local swappedAbility = false
    
    -- 2. Swap the standard shot ability with the multi-shot ability
    if AbilitiesArray then
        for i = 1, #AbilitiesArray do
            local Ability = AbilitiesArray[i]
            
            if Ability then
                local ok, abilityName = pcall(function() return Ability:GetFName():ToString() end)
                if ok and abilityName and string.find(abilityName, "GA_RangeWeapon_Shot") and not string.find(abilityName, "MultiShot") then
                    AbilitiesArray[i] = MultiShotClass
                    swappedAbility = true
                end
            end
        end
    end
    
    if swappedAbility then
        print(string.format("[Mod] Multi-shot config applied to: %s (Clip: %d -> %d)", WeaponLogicParams:GetFName():ToString(), vanillaSize, targetSize))
    end
end

-- Initialize the modification for the chosen weapons to support MultiShot
local function ModifyWeaponAbilities()
    local MultiShotClass = GetMultiShotClass()
    if not MultiShotClass then return end

    -- Iterate over all defined advanced weapons
    for _, WeaponLogicPath in ipairs(ADVANCED_WEAPON_PATHS) do
        local WeaponLogicParams = StaticFindObject(WeaponLogicPath)
        
        -- If the object is not loaded in memory yet, force the engine to load it
        if not WeaponLogicParams or not WeaponLogicParams:IsValid() then
            local ok, loaded = pcall(function()
                return LoadAsset(WeaponLogicPath)
            end)
            if ok then WeaponLogicParams = loaded end
        end
        
        -- Bulletproof fallback: Grab directly from memory if UE4SS failed to link the path natively
        if not WeaponLogicParams or not WeaponLogicParams:IsValid() then
            local allParams = FindAllOf("R5RangeWeaponItemLogicParams")
            if allParams then
                for i = 1, #allParams do
                    local paramObj = allParams[i]
                    if paramObj and paramObj:IsValid() then
                        local ok, paramName = pcall(function() return paramObj:GetFullName() end)
                        if ok and paramName and string.find(paramName, WeaponLogicPath, 1, true) then
                            WeaponLogicParams = paramObj
                            break    
                        end
                    end
                end
            end
        end
        
        if WeaponLogicParams and WeaponLogicParams:IsValid() then
            ApplyMultiShotToWeapon(WeaponLogicParams, WeaponLogicPath, MultiShotClass)
        else
            print(string.format("[Mod] Error: Could not locate logic params at %s", WeaponLogicPath))
        end
    end
end

-- Keep references to hooks so Lua's Garbage Collector doesn't unregister them during map loads
local PersistentHooks = {}

-- Hook 1: Early game event (Base check for singleplayer / clients)
PersistentHooks.ClientRestartPre, PersistentHooks.ClientRestartPost = RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context)
    -- Multiplayer timing fix: Delay execution to give the server time to load the assets
    if type(ExecuteWithDelay) == "function" and type(ExecuteInGameThread) == "function" then
        ExecuteWithDelay(2500, function()
            ExecuteInGameThread(function() ModifyWeaponAbilities() end)
        end)
    end
end)

-- Hook 2: The ultimate Multiplayer Sentinel. Wakes up the exact millisecond the server streams a weapon into RAM.
NotifyOnNewObject("/Script/R5.R5RangeWeaponItemLogicParams", function(CreatedObject)
    if CreatedObject and CreatedObject:IsValid() then
        local ok, objName = pcall(function() return CreatedObject:GetFullName() end)
        if ok and objName then
            for _, path in ipairs(ADVANCED_WEAPON_PATHS) do
                if string.find(objName, path, 1, true) then
                    if type(ExecuteInGameThread) == "function" then
                        ExecuteInGameThread(function()
                            local MultiShotClass = GetMultiShotClass()
                            if MultiShotClass then
                                ApplyMultiShotToWeapon(CreatedObject, path, MultiShotClass)
                            end
                        end)
                    end
                    break
                end
            end
        end
    end
end)
