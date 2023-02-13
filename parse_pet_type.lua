--- Parses petType and returns the valid index of pet type
--- Examples:
--- full type name:     "beast" -> 8
--- only prefix:        "b"     -> 8
--- explicit as string: "8"     -> 8
--- explicit as number:  8      -> 8
--- uknown type:                -> nil
function parsePetType(petType)
    local petType = strlower(petType)
    local numberOfPetTypes = C_PetJournal.GetNumPetTypes()

    -- Check explicit pet type as number (eg. 8 or "8")
    local explicitPetType = tonumber(petType)
    if explicitPetType then
        if explicitPetType >= 1 and explicitPetType <= numberOfPetTypes then
            return explicitPetType
        else
            return nil
        end
    end

    -- Check for each exists pet type...
    local matchedPetTypes = {}
    for petTypeIndex = 1,numberOfPetTypes do
        -- Pet type suffix and name can be different, eg. Water and Aquatic
        local petTypePrefix = getPetTypePrefix(petTypeIndex)
        local petTypeName = getPetTypeName(petTypeIndex)

        -- ...check if passed `petType` is prefix of the pet type
        if strlower(petTypeName):sub(1, #petType) == petType then
            table.insert(matchedPetTypes, {
                index = petTypeIndex,
                text = petTypeName
            })
        elseif strlower(petTypePrefix):sub(1, #petType) == petType then
            table.insert(matchedPetTypes, {
                index = petTypeIndex,
                text = petTypePrefix
            })
        end
    end

    local numerOfMatchedPetTypes = table.getn(matchedPetTypes)
    if numerOfMatchedPetTypes == 0 then
        print("Not found pet type", petType)
        return nil
    elseif numerOfMatchedPetTypes >= 2 then
        print("Pet type \"" .. petType .. "\" is ambiguous, it matches to:")
        for _, petType in ipairs(matchedPetTypes) do
            print("-", petType.text)
        end
        return nil
    else
        -- numerOfMatchedPetTypes == 1
        return matchedPetTypes[1].index
    end
end

function getPetTypePrefix(petType)
    return PET_TYPE_SUFFIX[petType]
end

function getPetTypeName(petType)
    return loadstring("return BATTLE_PET_NAME_" .. petType)()
end

function GetPetTypeTexture(petType)
	if PET_TYPE_SUFFIX[petType] then
		return "Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType];
	else
		return "Interface\\PetBattles\\PetIcon-NO_TYPE";
	end
end