-- Power Exterior

ENT:AddHook("Initialize","power-init", function(self)
    self:SetData("power-state",true,true)
end)

if SERVER then
    function ENT:TogglePower()
        local on = not self:GetData("power-state",false)
        self:SetPower(on)
    end
    function ENT:SetPower(on)
        if (self:CallHook("CanTogglePower")==false or self.interior:CallHook("CanTogglePower")==false) then return end
        self:SetData("power-state",on,true)
        self:CallHook("PowerToggled",on)
        if self.interior then
            self.interior:CallHook("PowerToggled",on)
        end
    end
end