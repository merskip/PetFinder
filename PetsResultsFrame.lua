function CreatePetsRetuls(petResults)
    local panel = CreateFrame("Frame", nil, UIPanel, "BasicFrameTemplate")
    panel:SetPoint("CENTER")
    panel:SetSize(240, 360)
    panel:EnableMouse(true)

    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self, button)
        self:StartMoving()
    end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    local panelLabel = panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
    panelLabel:SetPoint("TOP", 0, -5)
    panelLabel:SetText("Pet Finder")

    -- Create the scrolling parent frame and size it to fit inside the texture
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

    -- Create the scrolling child frame, set its width to fit, and give it an arbitrary minimum height (such as 1)
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(480 - 18)
    scrollChild:SetHeight(1)
    scrollChild:SetHyperlinksEnabled(true)
    scrollChild:SetScript("OnHyperlinkClick", function(self, link, text)
        local linksParts = { strsplit(":", link) }
        if linksParts[1] == "battlepet" then
            local petID = linksParts[8]
            OpenPetJournalWithPetID(petID)
        else
            ChatFrame_OnHyperlinkShow(self, link, text)
        end
    end)

    local lastElement = nil
    for _, levelResult in ipairs(petResults) do

        local levelLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        if lastElement == nil then
            levelLabel:SetPoint("TOPLEFT")
        else
            levelLabel:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -10)
        end
        levelLabel:SetText("Level " .. levelResult.petLevel)
        lastElement = levelLabel

        for _, levelResult in ipairs(levelResult.opponentPetTypes) do
            local petTypeLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalTiny")
            petTypeLabel:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
            petTypeLabel:SetText("Pets against " .. getPetTypeName(levelResult.opponentPetType))
            lastElement = petTypeLabel

            for _, petID in pairs(levelResult.petsIDs) do
                local petLink = C_PetJournal.GetBattlePetLink(petID)

                local petLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontWhiteTiny")
                petLabel:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT")
                petLabel:SetText(petLink)
                lastElement = petLabel
            end
        end
    end

    return panel
end

function OpenPetJournalWithPetID(petID)
    SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)    
    PetJournal_SelectPet(PetJournal, petID)
end
