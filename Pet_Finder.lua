SLASH_FIND_PETS1 = '/findpets'
SLASH_FIND_PETS2 = '/fp'
SlashCmdList.FIND_PETS = function(msg, editBox)
    local opponentPetTypes = { strsplit(" ", msg) }

    for index, opponentPetType in ipairs(opponentPetTypes) do
        local opponentPetType = parsePetType(opponentPetType)
        if not opponentPetType then
            return
        end

        print(format("Strong pets against %s:", getPetTypeName(opponentPetType)))

        local pets = findOwnedPetsAgainstPetType(opponentPetType)
        for index, ownedPetID in ipairs(pets) do
            local petLink = C_PetJournal.GetBattlePetLink(ownedPetID)
            print(format(" - %s", petLink))
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