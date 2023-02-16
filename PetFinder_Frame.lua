PetFinder_FrameMixin = {};

function PetFinder_FrameMixin:OnLoad()
	self:SetTitle("Pet Finder");
    self:RegisterForDrag("LeftButton");
    tinsert(UISpecialFrames, self:GetName());
    self.withoutCooldown.Text:SetText("Ignore abilities\nwith cooldown")

    UIDropDownMenu_Initialize(self.petType1, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType2, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType3, AddPetTypesToDropdown)

    self.withoutCooldown:SetChecked(true)

    local view = CreateScrollBoxListLinearView();
    view:SetPadding(16, 16, 0, 4 + 6 * 32 + (5 * 3) + 4, 4); -- top, bottom, left, right, spacing
    view:SetElementFactory(function(factory, elementData)
        if elementData.petLevel then
            factory("PetFinder_PetListLevelHeaderTemplate", PetListLevelHeaderTemplate_Init);
        elseif elementData.petType then
            factory("PetFinder_PetListPetTypeHeaderTemplate", PetListPetTypeHeaderTemplate_Init);
        else
            factory("PetFinder_PetListButtonTemplate", function(button, elementData)
                button:Init(elementData)
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
        UIDropDownMenu_SetText(dropdown, GetPetTypeName(petType))
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
    if #opponentPetTypes == 0 then
        return
    end

    local result = FindOwnedPetsAgainstOponentPetTypes(opponentPetTypes, ignoreAibilitesWithCooldown)
    local dataProvider = CreateDataProvider();
    for _, levelResult in ipairs(result) do
        dataProvider:Insert({petLevel = levelResult.petLevel});

        for _, petTypeResult in ipairs(levelResult.opponentPetTypes) do
            dataProvider:Insert({petType = petTypeResult.petType});

            for _, pets in pairs(petTypeResult.pets) do
		        dataProvider:Insert(pets);
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

function PetListLevelHeaderTemplate_Init(button, elementData)
    button.title:SetText("Level " .. elementData.petLevel)
end

function PetListPetTypeHeaderTemplate_Init(button, elementData)
    button.title:SetText("Pets against " .. GetPetTypeName(elementData.petType))
end

PetListButtonMixin = {};

function PetListButtonMixin:Init(pet)
    self.petID = pet.petID
    self.strongAbilities = pet.strongAbilities
    
    local speciesID, customName, level, _, _, _, _, name, icon, petType = C_PetJournal.GetPetInfoByPetID(pet.petID);

	if customName then
		self.name:SetText(customName);
		self.name:SetHeight(12);
		self.subName:Show();
		self.subName:SetText(name);
	else
		self.name:SetText(name);
		self.name:SetHeight(30);
		self.subName:Hide();
	end

    self.icon:SetTexture(icon);
	self.petTypeIcon:SetTexture(GetPetTypeTexture(petType));

    local health, _, _, _, rarity = C_PetJournal.GetPetStats(pet.petID);

    self.dragButton.level:SetText(level);

    self.icon:SetDesaturated(false);
    self.name:SetFontObject("GameFontNormal");
    self.dragButton:Enable();
    self.iconBorder:Show();
    
    local qualityColor = ITEM_QUALITY_COLORS[rarity-1]
    self.iconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b);

    if (health and health <= 0) then
        self.isDead:Show();
    else
        self.isDead:Hide();
    end

    self.ability1:Init(pet.petID, pet.strongAbilities[1])
    self.ability2:Init(pet.petID, pet.strongAbilities[2])
    self.ability3:Init(pet.petID, pet.strongAbilities[3])
    self.ability4:Init(pet.petID, pet.strongAbilities[4])
    self.ability5:Init(pet.petID, pet.strongAbilities[5])
    self.ability6:Init(pet.petID, pet.strongAbilities[6])
end

function PetListButtonMixin:OnClick()
    OpenPetJournalWithPetID(self.petID)
end

PetListAbilityButtonMixin = {}

function PetListAbilityButtonMixin:Init(petID, abilityID)
    if abilityID then
        self:SetShown(true)
        local _, name, icon = C_PetBattles.GetAbilityInfoByID(abilityID)
        self.icon:SetTexture(icon)
    else
        self:SetShown(false)
    end
end

function PetListAbilityButtonMixin:OnEnter()
    print("PetListAbilityButtonMixin:OnEnter")
end

function PetListAbilityButtonMixin:OnLeave()
    print("PetListAbilityButtonMixin:OnLeave")
end