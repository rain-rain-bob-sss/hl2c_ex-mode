local PANEL = {}
function PANEL:SetLabelText(text,speed)
    self:SetText(text)
    self.txt = text
    self.pos = 1
    self.maxpos = utf8.len(text)
    if isbool(speed) then 
        if speed then
            self.speed = maxpos * 2
        else
            self.speed = 7
        end
    else
        self.speed = speed or 7
    end
    self:SizeToContents()
    self:SetText(utf8.sub(text,1,1))
end

function PANEL:Think()
    if ( self:GetAutoStretchVertical() ) then
		self:SizeToContentsY()
	end


    if self.txt then 
        self.pos = math.min(self.maxpos,self.pos + RealFrameTime() * self.speed)
        local pos = math.ceil(self.pos)
        local txt = utf8.sub(self.txt,1,pos)
        if txt ~= self:GetText() then
            if self.OnText then self:OnText(pos,self.txt,txt) end
            self:SetText(txt)
        end
    end
end

vgui.Register("DLabelText",PANEL,"DLabel")