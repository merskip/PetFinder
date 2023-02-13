PetFinder_FrameMixin = {};

function PetFinder_FrameMixin:OnLoad()
	self:SetTitle("Pet Finder");
    self:RegisterForDrag("LeftButton");

    self:SetPetType(1, 1);
    self:SetPetType(2, 2);
    self:SetPetType(3, 3);
end

function PetFinder_FrameMixin:SetPetType(index, petType)
    local petTypeFrame = self["petType"..index];
    petTypeFrame.name:SetText(getPetTypeName(petType));
    petTypeFrame.icon:SetTexture(GetPetTypeTexture(petType));
end
