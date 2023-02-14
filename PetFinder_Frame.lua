PetFinder_FrameMixin = {};

function PetFinder_FrameMixin:OnLoad()
	self:SetTitle("Pet Finder");
    self:RegisterForDrag("LeftButton");
    self.withoutCooldown.Text:SetText("Ignore abilities\nwith cooldown")

    UIDropDownMenu_Initialize(self.petType1, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType2, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType3, AddPetTypesToDropdown)

    self.withoutCooldown:SetChecked(true)

    local view = CreateScrollBoxListLinearView();
    view:SetPadding(16, 16, 0, 4, 4);
    view:SetElementFactory(function(factory, elementData)
        if elementData.petLevel then
            factory("PetFinder_PetListLevelHeaderTemplate", PetListLevelHeaderTemplate_Init);
        elseif elementData.petType then
            factory("PetFinder_PetListPetTypeHeaderTemplate", PetListPetTypeHeaderTemplate_Init);
        else
            factory("PetFinder_PetListButtonTemplate", function(button, elementData)
                button:Init(button, elementData)
            end);
        end
    end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.results.scrollBox, self.results.scrollBar, view);
end

function PetFinder_FrameMixin:ShowWithPetTypes(opponentPetTypes)
    self:SetSelectedPetType(1, opponentPetTypes[1])
    self:SetSelectedPetType(2, opponentPetTypes[2])
    self:SetSelectedPetType(3, opponentPetTypes[3])
    self:Show()
    self:FindOnClick()
end

function PetFinder_FrameMixin:SetSelectedPetType(index, petType)
    local dropdown = self["petType" .. index]
    UIDropDownMenu_SetSelectedValue(dropdown, petType)
    if petType then
        -- Workaround for https://www.mmo-champion.com/threads/2043081-LUA-UIDropDownMenu-set-selected-value-at-initialization
        UIDropDownMenu_SetText(dropdown, getPetTypeName(petType))
    else
        UIDropDownMenu_SetText(dropdown, "")
    end
end

function PetFinder_FrameMixin:FindOnClick()
    local petType1 = UIDropDownMenu_GetSelectedValue(self.petType1)
    local petType2 = UIDropDownMenu_GetSelectedValue(self.petType2)
    local petType3 = UIDropDownMenu_GetSelectedValue(self.petType3)
    local ignoreAibilitesWithCooldown = self.withoutCooldown:GetChecked()

    local opponentPetTypes = {}
    if petType1 then
        table.insert(opponentPetTypes, petType1)
    end
    if petType2 then
        table.insert(opponentPetTypes, petType2)
    end
    if petType3 then
        table.insert(opponentPetTypes, petType3)
    end
    if table.getn(opponentPetTypes) == 0 then
        return
    end

    local result = findOwnedPetsAgainstOponentPetTypes(opponentPetTypes, ignoreAibilitesWithCooldown)
    local dataProvider = CreateDataProvider();
    for _, levelResult in ipairs(result) do
        dataProvider:Insert({petLevel = levelResult.petLevel});

        for _, petTypeResult in ipairs(levelResult.opponentPetTypes) do
            dataProvider:Insert({petType = petTypeResult.opponentPetType});

            for _, petID in pairs(petTypeResult.petsIDs) do
		        dataProvider:Insert(petID);
            end
        end
    end
	self.results.scrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end


function AddPetTypesToDropdown(dropdownMenu)
    local petTypesNames = GetPetTypesNames()
    for petType, petTypeName in ipairs(petTypesNames) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = petTypeName
        info.value = petType
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(dropdownMenu, self.value)
        end
        UIDropDownMenu_AddButton(info)
    end
end

PetListButtonMixin = {};

function PetListButtonMixin:Init(pet, petID)
    pet.petID = petID
    
    local _, customName, level, _, _, _, _, name, icon, petType = C_PetJournal.GetPetInfoByPetID(petID);

	if customName then
		pet.name:SetText(customName);
		pet.name:SetHeight(12);
		pet.subName:Show();
		pet.subName:SetText(name);
	else
		pet.name:SetText(name);
		pet.name:SetHeight(30);
		pet.subName:Hide();
	end

    pet.icon:SetTexture(icon);
	pet.petTypeIcon:SetTexture(GetPetTypeTexture(petType));

    local health, _, _, _, rarity = C_PetJournal.GetPetStats(petID);

    pet.dragButton.level:SetText(level);

    pet.icon:SetDesaturated(false);
    pet.name:SetFontObject("GameFontNormal");
    pet.dragButton:Enable();
    pet.iconBorder:Show();
    
    local qualityColor = ITEM_QUALITY_COLORS[rarity-1]
    pet.iconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b);

    if (health and health <= 0) then
        pet.isDead:Show();
    else
        pet.isDead:Hide();
    end
end

function PetListButtonMixin:OnClick()
    OpenPetJournalWithPetID(self.petID)
end

function PetListLevelHeaderTemplate_Init(button, elementData)
    button.title:SetText("Level " .. elementData.petLevel)
end

function PetListPetTypeHeaderTemplate_Init(button, elementData)
    button.title:SetText("Pets against " .. getPetTypeName(elementData.petType))
end
