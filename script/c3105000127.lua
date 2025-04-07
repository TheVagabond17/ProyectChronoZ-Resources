-- D.D. Tower
local s,id=GetID()
function s.initial_effect(c)
	-- Solo puedes activar 1 "D.D. Tower" por turno
	c:SetUniqueOnField(1,0,id)

	-- Al activarse: puedes añadir a tu mano 1 monstruo "D.D." de Nivel 4 o menor desde tu Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Si controlas un monstruo que no es "D.D.", destruye esta carta
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.checkop)
	c:RegisterEffect(e2)

	-- Si controlas 3+ monstruos en Posición de Ataque, tu oponente no puede declarar ataques
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atklimcon)
	c:RegisterEffect(e3)

	-- (Efecto Rápido) Si un monstruo es desterrado: puedes desterrar 1 carta en el Campo
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end

-- Lista de cartas "D.D." (añade aquí más si es necesario)
s.listed_cards={
	3773196,7572887,16638212,24508238,33243043,37043180,44792253,48092532,
	48148828,57101885,52702748,56790702,70074904,75991479,80201858,86498013,
	89015998,95291684,3105000126,3105000127,3105000128,3105000129
}

function s.isDDBased(c)
	for _,code in ipairs(s.listed_cards) do
		if c:IsCode(code) then return true end
	end
	return false
end

-- Efecto al activarse: añadir 1 monstruo D.D. de Nivel 4 o menor a la mano
function s.thfilter(c)
	return s.isDDBased(c) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end


-- Efecto de autodestrucción si controlas monstruo que no sea D.D.
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if g:IsExists(function(c) return not s.isDDBased(c) end,1,nil) then
		Duel.Destroy(c,REASON_EFFECT)
	end
end

-- Condición: controlas 3+ monstruos en Posición de Ataque
function s.atklimcon(e)
	return Duel.GetMatchingGroupCount(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil,POS_FACEUP_ATTACK)>=3
end

-- Efecto Rápido: si un monstruo es desterrado, puedes desterrar 1 carta en el Campo
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

