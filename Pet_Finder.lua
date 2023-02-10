SLASH_FIND_PETS1 = '/findpets'
SLASH_FIND_PETS2 = '/fp'
SlashCmdList.FIND_PETS = function(msg, editBox)
    local opponentPetFamilies = { strsplit(" ", msg) }

    for index, opponentPetFamily in ipairs(opponentPetFamilies) do
        print(format("Finding pets for against %s", opponentPetFamily))
        local pets = findOwnedPetsAgainstPetFamily(opponentPetFamily)
        print(format("Result: %s", pets))
    end
end

function findOwnedPetsAgainstPetFamily(petFamily)
    local _, ownNumPetsOwned = C_PetJournal.GetNumPets()
    -- ownNumPetsOwned = 10

    for index = 1,ownNumPetsOwned do
        print(index)
        local petID, _, _, customName, level, _, _, speciesName, _, _, _, _, _, _, canBattle, _, _, _= C_PetJournal.GetPetInfoByIndex(index)
        if (canBattle) then
            local displayName = customName or speciesName
            print(petID, displayName, level, canBattle)
        end
    end
    return "vvvv"
end