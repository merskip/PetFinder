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
        local petType = ParsePetType(petType)
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
