PetFinder_FrameMixin = {};

function PetFinder_FrameMixin:OnLoad()
	self:SetTitle("Pet Finder");
    self:RegisterForDrag("LeftButton");

    UIDropDownMenu_Initialize(self.petType1, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType2, AddPetTypesToDropdown)
    UIDropDownMenu_Initialize(self.petType3, AddPetTypesToDropdown)
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
