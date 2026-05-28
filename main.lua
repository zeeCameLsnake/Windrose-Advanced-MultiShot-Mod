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

-- Keep track of already modified weapons to prevent double-buffing due to ClientRestart in the lobby AND when map is loaded 
local PROCESSED_WEAPONS = {}

-- Initialize the modification for the chosen weapons to support MultiShot
local function ModifyWeaponAbilities()
    -- Pre-load the multi-shot class once
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
        return
    end

    -- Iterate over all defined advanced weapons
    for _, WeaponLogicPath in ipairs(ADVANCED_WEAPON_PATHS) do
        -- Only process each weapon once per session
        if not PROCESSED_WEAPONS[WeaponLogicPath] then
            local WeaponLogicParams = FindObject("R5RangeWeaponItemLogicParams", WeaponLogicPath)
            
            -- If the object is not loaded in memory yet, force the engine to load it
            if not WeaponLogicParams or not WeaponLogicParams:IsValid() then
                local ok, loaded = pcall(function()
                    return LoadAsset(WeaponLogicPath)
                end)
                if ok then WeaponLogicParams = loaded end
            end

            if WeaponLogicParams and WeaponLogicParams:IsValid() then
                -- 1. Increase clip size based on current value for a proper upgrade path
                local currentClipSize = WeaponLogicParams.CommonData.MaxClipSize
                
                if currentClipSize == 1 then
                    WeaponLogicParams.CommonData.MaxClipSize = 2
                elseif currentClipSize == 2 then
                    WeaponLogicParams.CommonData.MaxClipSize = 3
                elseif currentClipSize >= 3 then
                    WeaponLogicParams.CommonData.MaxClipSize = 5
                end
                
                -- 2. Swap the standard shot ability with the multi-shot ability
                local AbilitiesArray = WeaponLogicParams.R5EquipmentItemLogicData.GrantedAbilities
                
                if AbilitiesArray then
                    for i = 1, #AbilitiesArray do
                        local Ability = AbilitiesArray[i]
                        
                        -- Safely check the ability name to avoid TSet value errors
                        if Ability then
                            local ok, abilityName = pcall(function() return Ability:GetFName():ToString() end)
                            if ok and abilityName and string.find(abilityName, "GA_RangeWeapon_Shot") then
                                -- Replace the single shot with the multi-shot class
                                AbilitiesArray[i] = MultiShotClass
                            end
                        end
                    end
                end
                
                print(string.format("[Mod] Multi-shot configuration applied to: %s", WeaponLogicParams:GetFName():ToString()))
                PROCESSED_WEAPONS[WeaponLogicPath] = true
            else
                print(string.format("[Mod] Error: Could not locate logic params at %s", WeaponLogicPath))
            end
        end
    end
end

-- Hook into an early game event (like player restart) to ensure data assets are loaded
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context)
    ModifyWeaponAbilities()
end)
