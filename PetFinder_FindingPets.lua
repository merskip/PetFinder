-- Returns:
-- [{
--     petLevel: number
--     opponentPetTypes: [{
--         petType: number(petType)
--         pets: [{
--             petID: number(GUID)
--             strongAbilities: [number(abbilityID)]
--         }]
--     }]
-- }]
function FindOwnedPetsAgainstOponentPetTypes(opponentPetTypes, ignoreAibilitesWithCooldown)

    local petsAgainstPetType = {}
    for _, opponentPetType in ipairs(opponentPetTypes) do
        petsAgainstPetType[opponentPetType] = FindOwnedPetsAgainstPetType(opponentPetType, ignoreAibilitesWithCooldown)
    end

    local result = {}
    for petLevel = 1,MAX_PET_LEVEL do
        local petLevelResult = {
            petLevel = petLevel,
            opponentPetTypes = {}
        }

        for _, opponentPetType in ipairs(opponentPetTypes) do
            local pets = FilterPetsOnLevel(petsAgainstPetType[opponentPetType], petLevel)
            if #pets > 0 then
                table.insert(petLevelResult.opponentPetTypes, {
                    petType = opponentPetType,
                    pets = pets
                })
            end
        end

        if #petLevelResult.opponentPetTypes == #opponentPetTypes then
            table.insert(result, petLevelResult)
        end
    end
    return result
end

-- Retuns:
-- [{
--     petID: number(GUID)
--     strongAbilities: [number(abbilityID)]
-- }]
function FindOwnedPetsAgainstPetType(opponentPetType, ignoreAibilitesWithCooldown)
    local _, ownNumPetsOwned = C_PetJournal.GetNumPets()

    local resultPets = {}
    for index = 1,ownNumPetsOwned do
        local petID = C_PetJournal.GetPetInfoByIndex(index)
        local strongAbilities = GetStrongAbilitiesAgainst(petID, opponentPetType, ignoreAibilitesWithCooldown)
        if #strongAbilities ~= 0 then
            table.insert(resultPets, {
                petID = petID,
                strongAbilities = strongAbilities
            })
        end
    end
    return resultPets
end

-- returns:
-- [number(abbilityID)]
function GetStrongAbilitiesAgainst(ownedPetID, opponentPetType, ignoreAibilitesWithCooldown)
    local petInfo = C_PetJournal.GetPetInfoTableByPetID(ownedPetID)

    -- Eg. Alliance/Horde balloon cannot battle, so can be skipped
    if not petInfo.canBattle then
        return {}
    end

    local strongAbilities = {}
    local ability = C_PetJournal.GetPetAbilityListTable(petInfo.speciesID)
    for _, abilityInfo in ipairs(ability) do
        if IsAbilityStrong(petInfo.petLevel, opponentPetType, abilityInfo, ignoreAibilitesWithCooldown) then
            table.insert(strongAbilities, abilityInfo.abilityID)
        end
    end
    return strongAbilities
end

function IsAbilityStrong(petLevel, opponentPetType, abilityInfo, ignoreAibilitesWithCooldown)
    local _, name, _, maxCooldown, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityInfo.abilityID)

    -- Check if the pet has the required level and the ability is offensive
    if petLevel < abilityInfo.level or noStrongWeakHints then
        return false
    end

    -- Skip abilities with cooldown when the flag is set
    if ignoreAibilitesWithCooldown and maxCooldown ~= 0 then
        return false
    end

    return HasBonusAttack(petType, opponentPetType)
end

function FilterPetsOnLevel(pets, level)
    local resultPets = {}
    for _, pet in ipairs(pets) do
        local petInfo = C_PetJournal.GetPetInfoTableByPetID(pet.petID)

        if petInfo.petLevel == level then
            table.insert(resultPets, pet) 
        end
    end
    return resultPets
end

--- Returns true when provided `petType` has attack bonus against `opponentPetType`
function HasBonusAttack(petType, opponentPetType)
    local bonusAttackTable = {
        [1] = 2, -- Humanoid, Dragonkin
        [2] = 6, -- Dragonkin, Magic
        [3] = 9, -- Flying, Aquatic
        [4] = 1, -- Undead, Humanoid
        [5] = 4, -- Critter, Undead
        [6] = 3, -- Magic, Flying
        [7] = 10, -- Elemental, Mechanical
        [8] = 5, -- Beast, Critter
        [9] = 7, -- Aquatic, Elemental
        [10] = 8 -- Mechanical, Beast
    }
    return bonusAttackTable[petType] == opponentPetType
end
