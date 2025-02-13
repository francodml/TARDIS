-- Physical Lock

if SERVER then
    function ENT:SetPhyslock(on)
        local phys = self:GetPhysicsObject()
        phys:EnableMotion(not on)
        phys:Wake()
        return self:SetData("physlock", on, true)
    end

    function ENT:TogglePhyslock()
        local on = not self:GetData("physlock", false)
        return self:SetPhyslock(on)
    end

    hook.Add("PlayerUnfrozeObject", "tardis-physlock", function(ply,ent,phys)
        if ent:GetClass()=="gmod_tardis" and ent:GetData("physlock",false)==true then 
            phys:EnableMotion(false) 
        end
    end)

    hook.Add("PhysgunDrop", "tardis-physlock", function(ply,ent)
        if ent:GetClass()=="gmod_tardis" and ent:GetData("physlock",false)==true then
            ent:GetPhysicsObject():EnableMotion(false)
        end
    end)

    ENT:AddHook("MatStart", "physlock", function(self)
        if not self:GetData("physlock",false) then
            self.phys:EnableMotion(true)
            self.phys:Wake()
        end
    end)
end
