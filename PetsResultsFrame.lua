function CreatePetsRetuls(petResults)
    local panel = CreateFrame("Frame", nil, UIPanel, "BasicFrameTemplate")
    panel:SetPoint("CENTER")
    panel:SetSize(480, 360)

    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
    title:SetPoint("TOP", 0, -5)
    title:SetText("Pet Finder")

    -- Create the scrolling parent frame and size it to fit inside the texture
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

    -- Create the scrolling child frame, set its width to fit, and give it an arbitrary minimum height (such as 1)
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(480 - 18)
    scrollChild:SetHeight(1) 

    -- Add widgets to the scrolling child frame as desired
    local title = scrollChild:CreateFontString("ARTWORK", nil, "GameFontWhiteTiny")
    title:SetPoint("TOPLEFT")
    title:SetJustifyH("LEFT")

    local text = ""
    for _, levelResult in ipairs(petResults) do
        text = text .. "Level" .. levelResult.petLevel .. "\n"
        for _, levelResult in ipairs(levelResult.opponentPetTypes) do
            local opponentPetType = levelResult.opponentPetType
            local petsIDs = levelResult.petsIDs
            text = text .. "   Pets against " .. getPetTypeName(opponentPetType) .. "\n"

            for _, petID in pairs(petsIDs) do
                local petLink = C_PetJournal.GetBattlePetLink(petID)
                text = text .. "      " .. petLink .. "\n"
            end
        end
        text = text .. "\n"
    end
    title:SetText(text)

    return panel
end
