-- Handles portals for rendering, thanks to bliptec (http://facepunch.com/member.php?u=238641) for being a babe

if SERVER then
	hook.Add("wp-shouldtp", "tardisint-portals", function(self,ent)
		local e=self:GetParent()
		if IsValid(e) then
			local class=e:GetClass()
			if class=="gmod_tardis" then
				if not e:DoorOpen() then
					return false
				end
			elseif class=="gmod_tardis_interior" then
				if not e.exterior:DoorOpen() and self==e.portals.interior then
					return false
				end
			end
		end
		if ent.TardisPart then return false end
	end)
else
	TARDIS:AddSetting({
		id="portals-enabled",
		name="Enabled",
		section="Portals",
		desc="Whether portals will render or not, turn this off if they impact framerate significantly",
		value=true,
		type="bool",
		option=true
	})
	TARDIS:AddSetting({
		id="portals-closedist",
		name="Close Distance",
		section="Portals",
		desc="The distance at which the door automatically closes",
		value=1000,
		type="number",
		min=350,
		max=5000,
		option=true
	})
	
	hook.Add("wp-shouldrender", "tardisint-portals", function(portal,exit,origin)
		local p=portal:GetParent()
		if IsValid(p) and (p.TardisExterior or p.TardisInterior) and p._init then
			local dont,black = p:CallHook("ShouldNotRenderPortal",p,portal,exit,origin)
			if dont==nil then
				local other = p.TardisExterior and p.interior or p.exterior
				if IsValid(other) then
					dont,black = other:CallHook("ShouldNotRenderPortal",p,portal,exit,origin)
				end
			end
			if dont then
				return false, black
			elseif (not (p.DoorOpen and p:DoorOpen(true))) and (p.TardisExterior or (p.TardisInterior and portal==p.portals.interior)) then
				return false
			elseif (not TARDIS:GetSetting("portals-enabled")) then
				return false, p.TardisInterior and (p.portals.interior==portal or portal.black)
			end
		end
	end)
	
	-- Smoothly closes door (if open) as player reaches render limit
	ENT:AddHook("Think", "portals", function(self)
		local ext=self.exterior
		if IsValid(ext) then
			if ext:GetData("doorstate",false) then
				local dist=GetViewEntity():GetPos():Distance(ext:GetPos())
				local closedist=TARDIS:GetSetting("portals-closedist")
				local length=250
				local startdist=closedist-length
				if dist>=startdist and dist<=closedist then
					ext.DoorOverride=1-(dist-startdist)/length
				elseif dist>closedist and ext.DoorOverride~=0 and (not IsValid(LocalPlayer():GetTardisData("exterior"))) then
					ext.DoorOverride=0
				elseif dist<startdist and ext.DoorOverride~=nil then
					ext.DoorOverride=nil
				end
			elseif ext.DoorOverride then
				ext.DoorOverride = nil
			end
		end
	end)
end

hook.Add("wp-bullet", "tardisint-portals", function(ent)
	local e=ent:GetParent()
	if IsValid(e) then
		local class=e:GetClass()
		if class=="gmod_tardis" then
			if not e:DoorOpen() then
				return false
			end
		elseif class=="gmod_tardis_interior" then
			if not e.exterior:DoorOpen() and ent==e.portals.interior then
				return false
			end
		end
	end
end)