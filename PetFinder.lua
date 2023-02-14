MAX_PET_LEVEL = 25

SLASH_FIND_PETS1 = '/findpets'
SLASH_FIND_PETS2 = '/fp'
SlashCmdList.FIND_PETS = function(msg, editBox)
    local opponentPetTypes = GetOpponentPetTypesFromMSG(msg)
    PetFinder_Frame:ShowWithPetTypes(opponentPetTypes or {})
end

function GetOpponentPetTypesFromMSG(msg) 
    if msg == "" then
        return GetOpponentPetTypesFromPetBattle()
    else
        local arguments = { strsplit(" ", msg) }
        return ParsePetTypesFromArguments(arguments)
    end
end

function ParsePetTypesFromArguments(arguments)
    local petTypes = {}
    for _, petType in ipairs(arguments) do
        local petType = parsePetType(petType)
        if not petType then
            return
        end
        table.insert(petTypes, petType)
    end
    return petTypes
end

function GetOpponentPetTypesFromPetBattle()
    if not C_PetBattles.IsInBattle() then
        return nil
    end
    local numerOfPets = C_PetBattles.GetNumPets(Enum.BattlePetOwner.Enemy)

    local petTypes = {}
    for petIndex = 1,numerOfPets do
        local petType = C_PetBattles.GetPetType(Enum.BattlePetOwner.Enemy, petIndex)
        table.insert(petTypes, petType)
    end
    return petTypes
end

function OpenPetJournalWithPetID(petID)
    SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)    
    PetJournal_SelectPet(PetJournal, petID)
end

function findOwnedPetsAgainstOponentPetTypes(opponentPetTypes, ignoreAibilitesWithCooldown)
    local result = {}
    for petLevel = 1,MAX_PET_LEVEL do
        local petLevelResult = {
            petLevel = petLevel,
            opponentPetTypes = {}
        }

        for _, opponentPetType in ipairs(opponentPetTypes) do
            local petsIDs = findOwnedPetsAgainstPetTypeOnPetLevel(opponentPetType, petLevel, ignoreAibilitesWithCooldown)

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

function findOwnedPetsAgainstPetTypeOnPetLevel(opponentPetType, petLevel, ignoreAibilitesWithCooldown)
    local petsIDs = findOwnedPetsAgainstPetType(opponentPetType, ignoreAibilitesWithCooldown)
    return filterPetsOnLevel(petsIDs, petLevel)
end

function findOwnedPetsAgainstPetType(opponentPetType, ignoreAibilitesWithCooldown)
    local _, ownNumPetsOwned = C_PetJournal.GetNumPets()

    local resultPets = {}
    for index = 1,ownNumPetsOwned do
        local petID = C_PetJournal.GetPetInfoByIndex(index)
        if isOwnedPetStrongAgainst(petID, opponentPetType, ignoreAibilitesWithCooldown) then
            table.insert(resultPets, petID)
        end
    end
    return resultPets
end

function isOwnedPetStrongAgainst(ownedPetID, opponentPetType, ignoreAibilitesWithCooldown)
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

    return hasBonusAttack(petType, opponentPetType)
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