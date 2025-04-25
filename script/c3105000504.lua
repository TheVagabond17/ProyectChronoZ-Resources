--Machina Prime Directive
local s,id=GetID()
function s.initial_effect(c)
	-- Activar
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e0)

	--Protección contra destrucción para Spells/Traps "Machina" boca arriba (excepto esta)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.prottg)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)

	-- Redirección opcional de objetivo de efecto (Quick Effect)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.chcon)
	e2:SetOperation(s.chop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end

-- Solo protege Spells/Traps "Machina" boca arriba (excepto esta)
function s.prottg(e,c)
	return c:IsSetCard(0x36) and c:IsFaceup() and c~=e:GetHandler()
end
function s.indval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

-- Verifica si hay efecto de monstruo con objetivos
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)~=nil
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x36),tp,LOCATION_MZONE,0,1,nil)
end

-- Cambiar objetivo, opcionalmente
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g<=0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local tg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,#g,nil)
		if #tg>0 then
			Duel.ChangeTargetCard(ev,tg)
		end
	end
end

