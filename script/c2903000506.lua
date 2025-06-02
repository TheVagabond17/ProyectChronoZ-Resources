--Harpie Phantom Gryphon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_HARPIE_LADY,aux.FilterBoolFunction(Card.IsSetCard,0x64))

	-- Indestructible por efectos del oponente si "Harpie Lady" está en el GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	-- Reducción de ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkdefval)
	c:RegisterEffect(e2)

	-- Reducción de DEF
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)

	-- Quick Effect: destruir Spell/Trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.descon)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_HARPIE_LADY}
s.listed_series={0x64} -- "Harpie"

-- Condición de protección: si hay Harpie Lady en tu GY
function s.imcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,CARD_HARPIE_LADY)
end
function s.efilter(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end

-- Reducción de ATK/DEF por cada Harpie Lady
function s.harpiecount(tp)
	return Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,CARD_HARPIE_LADY)
end
function s.atkdefval(e,c)
	return -100*s.harpiecount(e:GetHandlerPlayer())
end

-- Quick Effect - Condición
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re~=nil
end

-- Costo: desterrar 2 Harpie Lady del campo o GY
function s.cfilter(c)
	return c:IsCode(CARD_HARPIE_LADY) and c:IsAbleToRemoveAsCost()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,2,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Objetivo: 1 Spell/Trap en el campo
function s.spelltrapfilter(c)
	return c:IsSpellTrap()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spelltrapfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.spelltrapfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Destruir el objetivo
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

