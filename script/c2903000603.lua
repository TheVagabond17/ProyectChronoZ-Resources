--Queen's Nest
local s,id=GetID()
function s.initial_effect(c)
	-- Activación
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Cambiar el tipo de los monstruos del oponente a Insecto
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_FZONE+LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.racecon)
	e2:SetValue(RACE_INSECT)
	c:RegisterEffect(e2)

	-- Invocar un Insecto de Nivel 5 o mayor desde la mano
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

-- Activación: Añadir 1 Insecto nivel 5+ y 1 "Power Insect Barrier"
function s.thfilter1(c)
	return c:IsRace(RACE_INSECT) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsCode(2903000604) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
	if #g1>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc1=g1:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc2=g2:Select(tp,1,1,nil):GetFirst()
		local tg=Group.FromCards(tc1,tc2)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end

-- Condición: controlas Insecto Nivel 7+ o desde el Extra Deck
function s.racecon(e)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsRace(RACE_INSECT) and (c:IsLevelAbove(7) or c:IsSummonLocation(LOCATION_EXTRA))
	end, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

-- Invocar Insecto de Nivel 5 o mayor desde la mano
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsLevelAbove(5)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

