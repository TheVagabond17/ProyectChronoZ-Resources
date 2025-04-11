--Across the Kozmos
local s,id=GetID()
function s.initial_effect(c)
	-- Solo puedes activar 1 copia por turno
	c:SetUniqueOnField(1,0,id)
	--Pay 1500 LP to search Psychic Kozmo, optional Normal Summon, then restriction
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--LP Cost replacement   
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_LPCOST_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.lrcon)
	e2:SetOperation(s.lrop)
	e2:SetDescription(aux.Stringid(id,1))
	c:RegisterEffect(e2)

end
s.listed_series={0xd2}

-- (1) Main Effect
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	Duel.PayLPCost(tp,1500)
end
function s.filter(c)
	return c:IsSetCard(0xd2) and c:IsRace(RACE_PSYCHIC) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Restricción desde ahora
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- Buscar 1 "Kozmo" Psíquico
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,tc)

	-- Si es el turno del oponente y el monstruo puede ser Invocado Normal
	if Duel.GetTurnPlayer()~=tp and tc:IsSummonable(true,nil) then
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			Duel.Summon(tp,tc,true,nil)
		end
	end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_MACHINE))
end

-- (2) LP cost replacement from GY
function s.lrcon(e,tp,eg,ep,ev,re,r,rp)
	if tp~=ep then return false end
	if Duel.GetLP(tp)<ev then return false end
	if not (re and re:IsActivated()) then return false end
	local rc=re:GetHandler()
	return rc:IsSetCard(0xd2) and rc:IsLocation(LOCATION_MZONE) and rc:IsType(TYPE_MONSTER)
		and e:GetHandler():IsAbleToRemove()
end
function s.lrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
end
