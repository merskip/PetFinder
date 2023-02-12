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
        table.insert(opponentPetTypes, opponentPetType)
    end

    local result = findOwnedPetsAgainstOponentPetTypes(opponentPetTypes)
    local resultsPanel = CreatePetsRetuls(result)
    resultsPanel:Show();
end

function findOwnedPetsAgainstOponentPetTypes(opponentPetTypes)
    local result = {}
    for petLevel = 1,MAX_PET_LEVEL do
        local petLevelResult = {
            petLevel = petLevel,
            opponentPetTypes = {}
        }

        for _, opponentPetType in ipairs(opponentPetTypes) do
            local petsIDs = findOwnedPetsAgainstPetTypeOnPetLevel(opponentPetType, petLevel)

            if table.getn(petsIDs) > 0 then
                table.insert(petLevelResult.opponentPetTypes, {
                    opponentPetType = opponentPetType,
                    petsIDs = petsIDs
                })
            end
        end

        if table.getn(petLevelResult.opponentPetTypes) == table.getn(opponentPetTypes) then
            table.insert(result, petLevelResult)
        end
    end

    return result
end

function findOwnedPetsAgainstPetTypeOnPetLevel(opponentPetType, petLevel)
    local petsIDs = findOwnedPetsAgainstPetType(opponentPetType)
    return filterPetsOnLevel(petsIDs, petLevel)
end

function findOwnedPetsAgainstPetType(opponentPetType)
    local _, ownNumPetsOwned = C_PetJournal.GetNumPets()

    local resultPets = {}
    for index = 1,ownNumPetsOwned do
        local petID = C_PetJournal.GetPetInfoByIndex(index)
        if isOwnedPetStrongAgainst(petID, opponentPetType) then
            table.insert(resultPets, petID)
        end
    end
    return resultPets
end

function isOwnedPetStrongAgainst(ownedPetID, opponentPetType)
    local petInfo = C_PetJournal.GetPetInfoTableByPetID(ownedPetID)

    -- Eg. Alliance/Horde balloon cannot battle, so can be skipped
    if not petInfo.canBattle then
        return false
    end

    local ability = C_PetJournal.GetPetAbilityListTable(petInfo.speciesID)
    for index, abilityLevelInfo in ipairs(ability) do
        local _, name, _, maxCooldown, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(abilityLevelInfo.abilityID)
        -- Check if the pet has the required level and the ability is offensive
        if (petInfo.petLevel >= abilityLevelInfo.level and not noStrongWeakHints) then
            -- Ability is strong when it hasn't cooldown and has bonus attack for opponent pet type
            if maxCooldown == 0 and hasBonusAttack(petType, opponentPetType) then
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