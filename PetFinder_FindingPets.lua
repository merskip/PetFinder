-- Returns structure:
-- [
--  {
--    opponentPetType: {number} - pet type
--    petsIDs: [GUID]
--  }
-- ]
function FindOwnedPetsAgainstOponentPetTypes(opponentPetTypes, ignoreAibilitesWithCooldown)
    local result = {}

    local petsIDsAgainstPetType = {}
    for _, opponentPetType in ipairs(opponentPetTypes) do
        petsIDsAgainstPetType[opponentPetType] = FindOwnedPetsAgainstPetType(opponentPetType, ignoreAibilitesWithCooldown)
    end

    for petLevel = 1,MAX_PET_LEVEL do
        local petLevelResult = {
            petLevel = petLevel,
            opponentPetTypes = {}
        }

        for _, opponentPetType in ipairs(opponentPetTypes) do
            local petsIDs = FilterPetsOnLevel(petsIDsAgainstPetType[opponentPetType], petLevel)

            if #petsIDs > 0 then
                table.insert(petLevelResult.opponentPetTypes, {
                    opponentPetType = opponentPetType,
                    petsIDs = petsIDs
                })
            end
        end

        if #petLevelResult.opponentPetTypes == #opponentPetTypes then
            table.insert(result, petLevelResult)
        end
    end

    return result
end

-- Retuns: [GUID]
function FindOwnedPetsAgainstPetType(opponentPetType, ignoreAibilitesWithCooldown)
    local _, ownNumPetsOwned = C_PetJournal.GetNumPets()

    local resultPets = {}
    for index = 1,ownNumPetsOwned do
        local petID = C_PetJournal.GetPetInfoByIndex(index)
        if IsOwnedPetStrongAgainst(petID, opponentPetType, ignoreAibilitesWithCooldown) then
            table.insert(resultPets, petID)
        end
    end
    return resultPets
end

function IsOwnedPetStrongAgainst(ownedPetID, opponentPetType, ignoreAibilitesWithCooldown)
    local petInfo = C_PetJournal.GetPetInfoTableByPetID(ownedPetID)

    -- Eg. Alliance/Horde balloon cannot battle, so can be skipped
    if not petInfo.canBattle then
        return false
    end

    local ability = C_PetJournal.GetPetAbilityListTable(petInfo.speciesID)
    for _, abilityInfo in ipairs(ability) do
        if IsAbilityStrong(petInfo.petLevel, opponentPetType, abilityInfo, ignoreAibilitesWithCooldown) then
            return true
        end
    end
    return false
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

function FilterPetsOnLevel(petsIDs, level)
    local resultPets = {}
    for _, petID in ipairs(petsIDs) do
        local petInfo = C_PetJournal.GetPetInfoTableByPetID(petID)
        if petInfo.petLevel == level then
            table.insert(resultPets, petID) 
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
