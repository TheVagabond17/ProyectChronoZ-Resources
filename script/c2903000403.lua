--Heart Buster Destruction Sword
local s,id=GetID()
function s.initial_effect(c)
	-- Contact Fusion Summon
	c:EnableReviveLimit()
	
	-- Custom Fusion Summon procedure: 1 Dragon + 1 LIGHT monster from field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.fuscon)
	e0:SetOperation(s.fusop)
	c:RegisterEffect(e0)

	-- Effect on Special Summon: send 1 "Destruction Sword" to GY, then optionally Special Summon 1 "Buster Blader"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Equip to a "Buster Blader" you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end

-- Fusion condition: 1 Dragon + 1 LIGHT monster from your field
function s.fusfilter1(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.fusfilter2(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.fuscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g1=Duel.GetMatchingGroup(s.fusfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.fusfilter2,tp,LOCATION_MZONE,0,nil)
	return g1:IsExists(function(c1)
		return g2:IsExists(function(c2) return c1~=c2 end,1,c1)
	end,1,nil)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.GetMatchingGroup(s.fusfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.fusfilter2,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local m1=g1:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local m2=g2:FilterSelect(tp,function(c) return c~=m1 end,1,1,nil):GetFirst()
	local mat=Group.FromCards(m1,m2)
	c:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_COST+REASON_MATERIAL+REASON_FUSION)
end

-- Special Summon effect
function s.dsfilter(c)
	return c:IsSetCard(0xd6) and c:IsAbleToGrave()
end
function s.bbfilter(c,e,tp)
	return c:IsSetCard(0xd7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.dsfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.dsfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		local sg=Duel.SelectMatchingCard(tp,s.bbfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- Equip to Buster Blader
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd7)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or not c:IsControler(tp) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsControler(tp) then return end
	if not Duel.Equip(tp,c,tc) then return end

	-- Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(e,c) return c==tc end)
	c:RegisterEffect(e1)

	-- Only the equipped monster can be attacked
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget()~=nil end)
	e2:SetValue(function(e,c)
		return c~=e:GetHandler():GetEquipTarget()
	end)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end