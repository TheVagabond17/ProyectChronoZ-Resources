-- Koa'ki Meiru Perfect War Machine
local s,id=GetID()
function s.initial_effect(c)
	
	-- Special Summon from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	-- Add Koa'ki Meiru Spell/Trap from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	
	-- Equip "Iron Core of Koa'ki Meiru" from hand and negate its effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)

	-- 1+: Cannot be targeted by opponent's card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.tgcon)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)

	-- Avoid destruction by banishing 2 "Koa'ki Meiru" monster from GY
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.indcon)
	e5:SetTarget(s.desreptg)
	c:RegisterEffect(e5)

	-- 3+: Quick Effect to destroy a card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,4})
	e6:SetCondition(s.descon)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)

	-- 4+: Gains 300 ATK for each "Koa'ki Meiru" in the GY
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.atkcon)
	e7:SetValue(s.atkval)
	c:RegisterEffect(e7)
end

-- Special Summon Condition 
-- Filtro para "Koa'ki Meiru" que pueden ser destruidos
function s.desfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x1d) and c:IsDestructable(e)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- Verifica que haya al menos 3 "Koa'ki Meiru" que puedan ser destruidos y permite LocationCount >= -3
	return Duel.GetLocationCount(tp,LOCATION_MZONE) > -3 and
		Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,3,nil,e)
end

-- Special Summon Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,3,3,nil,e)
	if #g > 0 then
		Duel.Destroy(g,REASON_COST)
	end
end
-- Add Koa'ki Meiru Spell/Trap
function s.thfilter(c)
	return c:IsSetCard(0x1d) and c:IsSpellTrap() and c:IsAbleToHand()
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

-- Equip "Iron Core of Koa'ki Meiru"
function s.eqfilter(c)
	return c:IsCode(36623431) and c:IsType(TYPE_SPELL) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		Duel.Equip(tp,tc,c)
		-- Ensure it stays equipped
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(c)
		tc:RegisterEffect(e1)
		-- Prevent activation of the equipped card's effects while equipped (only while face-up)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_SZONE) end)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)

	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

-- Count Iron Core equips
function s.ironcorecount(c)
	return c:IsCode(36623431) and c:IsType(TYPE_SPELL)
end
function s.getcorecount(c)
	return c:GetEquipGroup():FilterCount(s.ironcorecount,nil)
end

-- 1+: Cannot be targeted
function s.tgcon(e)
	return s.getcorecount(e:GetHandler())>=1
end

-- 2+: Protection from destruction
function s.indcon(e)
	return s.getcorecount(e:GetHandler())>=2
end
function s.banfilter(c)
	return c:IsSetCard(0x1d) and c:IsType(TYPE_MONSTER)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) 
			and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and re and re:GetOwnerPlayer()~=tp))
			and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_GRAVE,0,2,nil)
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_GRAVE,0,2,2,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return true
	else
		return false
	end
end

-- 3+: Destroy 1 card (Quick Effect)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return s.getcorecount(e:GetHandler())>=3
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-- 4+: Gains 300 ATK for each "Koa'ki Meiru" in the GY
function s.atkcon(e)
	return s.getcorecount(e:GetHandler())>=4
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x1d),c:GetControler(),LOCATION_GRAVE,0,nil)*300
end