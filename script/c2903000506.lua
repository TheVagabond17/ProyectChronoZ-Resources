--Harpie Lady Chimera
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_HARPIE_LADY,aux.FilterBoolFunction(Card.IsSetCard,0x64))

	-- Protección si hay Harpie Lady en el GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.imcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)

	-- Reducción ATK/DEF oponente
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.atkdefval)
	c:RegisterEffect(e3)

	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)

	-- Quick Effect: destruir Spell/Trap
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.descon)
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end

s.listed_names={CARD_HARPIE_LADY}
s.listed_series={0x64} -- "Harpie"

-- Protección si "Harpie Lady" está en el GY
function s.imcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,CARD_HARPIE_LADY)
end
function s.efilter(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end

-- Reducción de ATK/DEF
function s.harpiecount(tp)
	return Duel.GetMatchingGroupCount(s.harpiefilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
end
function s.harpiefilter(c)
	return c:IsCode(CARD_HARPIE_LADY)
end
function s.atkdefval(e,c)
	return -100*s.harpiecount(e:GetHandlerPlayer())
end

-- Quick Effect - destruir Spell/Trap
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re~=nil
end
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
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
