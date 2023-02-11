MAX_PET_LEVEL = 25

SLASH_FIND_PETS1 = '/findpets'
SLASH_FIND_PETS2 = '/fp'
SlashCmdList.FIND_PETS = function(msg, editBox)
    local arguments = { strsplit(" ", msg) }

    local opponentPetTypes = {}
    for index, opponentPetType in ipairs(arguments) do
        local opponentPetType = parsePetType(opponentPetType)
        if not opponentPetType then
            return
        end
        opponentPetTypes[index] = opponentPetType
    end

    local petsAgainstOponentPetType = {}
    for _, opponentPetType in ipairs(opponentPetTypes) do
        local petsIDs = findOwnedPetsAgainstPetType(opponentPetType)
        petsAgainstOponentPetType[opponentPetType] = petsIDs
    end

    for petLevel = 1,MAX_PET_LEVEL do
        local resultPets = {}
        local hasPetsForThisLevel = true
        for _, opponentPetType in ipairs(opponentPetTypes) do
            local petsOnThisLevel = filterPetsOnLevel(petsAgainstOponentPetType[opponentPetType], petLevel)
            resultPets[opponentPetType] = petsOnThisLevel
            if table.getn(petsOnThisLevel) == 0 then
                hasPetsForThisLevel = false
            end
        end

        if hasPetsForThisLevel then
            print("= Pets for lebel", petLevel)
            for opponentPetType, petsIDs in pairs(resultPets) do
                print("pets against", getPetTypeName(opponentPetType))
                for _, petID in ipairs(petsIDs) do
                    print(" - ", C_PetJournal.GetBattlePetLink(petID))
                end
            end
        end
    end
end

function findOwnedPetsAgainstPetType(opponentPetType)
    local _, ownNumPetsOwned = C_PetJournal.GetNumPets()

    local resultPets = {}
    for index = 1,ownNumPetsOwned do
        local petID = C_PetJournal.GetPetInfoByIndex(index)
        if (isOwnedPetStrongAgainst(petID, opponentPetType)) then
            table.insert(resultPets, petID)
        end
    end
    return resultPets
end

function isOwnedPetStrongAgainst(ownedPetID, opponentPetType)
    local petInfo = C_PetJournal.GetPetInfoTableByPetID(ownedPetID)

    -- Eg. Alliance/Horde balloon cannot battle, so can be skipped
    if (not petInfo.canBattle) then
        return false
    end

    local ability = C_PetJournal.GetPetAbilityListTable(petInfo.speciesID)
    for index, abilityLevelInfo in ipairs(ability) do
        local _, name, _, _, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityLevelInfo.abilityID)
        -- Check if the pet has the required level and the ability is offensive
        if (petInfo.petLevel >= abilityLevelInfo.level and not noStrongWeakHints) then
            if (hasBonusAttack(petType, opponentPetType)) then
                return true
            end
        end
    end
    return false
end

function filterPetsOnLevel(petsIDs, level)
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
function hasBonusAttack(petType, opponentPetType)
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