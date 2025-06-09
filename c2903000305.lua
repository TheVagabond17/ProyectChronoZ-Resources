--Ferocious Zanki
local s,id=GetID()
function s.initial_effect(c)
	-- This card is treated as "Masaki the Legendary Swordsman" anywhere
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(44287299) -- Código de Masaki the Legendary Swordsman
	c:RegisterEffect(e0)

	-- Special Summon from hand by banishing a FIRE monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Gains effect if used as Fusion Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end

s.listed_names={45231177,34460851,2903000301} -- Flame Swordsman, Flame Manipulator, Red-Eyes Flame Fusion

-- Filter for FIRE monster to banish
function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end

-- Can be Special Summoned from hand
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_COST)>0 then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- After Special Summon, add Flame Manipulator from GY to hand
			local g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,34460851) -- Flame Manipulator
			if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g2:Select(tp,1,1,nil)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end

-- Condition: Fusion Summon of Flame Swordsman or monster that mentions it
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return r==REASON_FUSION and rc and (rc:IsCode(45231177) or rc:ListsCode(45231177))
end

function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if not rc then return end

	-- Gain 1000 ATK during Battle Phase only
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(function(e)
		local ph=Duel.GetCurrentPhase()
		return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
	end)
	e1:SetValue(1000)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)

	-- When destroys monster by battle, add 1 FIRE Lv5- or "Red-Eyes" monster from GY to hand
	local e2=Effect.CreateEffect(rc)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e2)
end

-- Filter: FIRE Lv5- or "Red-Eyes"
function s.thfilter(c)
	return (c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(5)) or (c:IsSetCard(0x3b) and c:IsMonster())
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

