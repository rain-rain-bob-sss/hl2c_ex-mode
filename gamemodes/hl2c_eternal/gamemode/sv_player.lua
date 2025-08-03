local meta = FindMetaTable("Player")
if not meta then return end


function meta:GiveMoneys(moneys,nomul)
	self.Moneys = self.Moneys + moneys * self:GetMoneyMul(nomul)
end

function meta:GiveMoneysGain(moneys,nomul)
	self.MoneysGain = self.MoneysGain + moneys
end


