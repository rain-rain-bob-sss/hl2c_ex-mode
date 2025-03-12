local meta = FindMetaTable("Player")
if not meta then return end


function meta:GiveMoneys(moneys)
	self.Moneys = self.Moneys + moneys
end

function meta:GiveMoneysGain(moneys)
	self.MoneysGain = self.MoneysGain + moneys
end


