PetFinder_FrameMixin = {};

function PetFinder_FrameMixin:OnLoad()
	self:SetTitle("Pet Finder");
    self:RegisterForDrag("LeftButton");
    self.withoutCooldown.Text:SetText("Ignore abilities\nwith cooldown")

    UIDropDownMenu_Initialize(self.petType1, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType2, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType3, AddPetTypesToDropdown)


    local view = CreateScrollBoxListLinearView();
    view:SetElementInitializer("PetFinder_PetListButtonTemplate", function(button, elementData)
        button:Init(elementData)
    end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.results.scrollBox, self.results.scrollBar, view);
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

    local result = findOwnedPetsAgainstOponentPetTypes(opponentPetTypes)

    local dataProvider = CreateDataProvider();

    for _, levelResult in ipairs(result) do
        print("Level ".. levelResult.petLevel)

        for _, levelResult in ipairs(levelResult.opponentPetTypes) do
            print("Pets against " .. getPetTypeName(levelResult.opponentPetType))

            for _, petID in pairs(levelResult.petsIDs) do
                local petLink = C_PetJournal.GetBattlePetLink(petID)
                print(" - ", petLink)

		        dataProvider:Insert(petID);
            end
        end
    end

	self.results.scrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end


function AddPetTypesToDropdown(dropdownMenu)
    local petTypes = GetPetTypesNames()
    for i, petType in ipairs(petTypes) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = petType
        info.value = i
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(dropdownMenu, self.value)
        end
        UIDropDownMenu_AddButton(info)
    end
end

PetListButtonMixin = {};

function PetListButtonMixin:Init(petID)
    self.petID = petID
    local petLink = C_PetJournal.GetBattlePetLink(petID)
    self:SetText(petLink)
end

function PetListButtonMixin:OnClick()
    OpenPetJournalWithPetID(self.petID)
end
