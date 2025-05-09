--The Plain of the Dragon Rider Knights
local s,id=GetID()
function s.initial_effect(c)
	--Activar
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--Limitación de activación del oponente durante Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.actcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--Búsqueda 1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost1)
	e3:SetTarget(s.thtg1)
	e3:SetOperation(s.thop1)
	c:RegisterEffect(e3)

	--Búsqueda 2
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCost(s.thcost2)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)

	--Búsqueda 3
	local e5=e3:Clone()
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCost(s.thcost3)
	e5:SetTarget(s.thtg3)
	e5:SetOperation(s.thop3)
	c:RegisterEffect(e5)
end

s.listed_names={86240887,66889139}
s.listed_series={0xbd,0xd7}

function s.actfilter(c)
	return c:IsFaceup() and (c:IsCode(66889139) or c:IsCode(86240887))
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_MZONE,0,1,nil)
end


-------------------------------------------------------
-- Efecto 1: Revelar un monstruo 'Gaia' en mano, Buster Blader monster, busca un Dragón de Nivel 5, busca una Bestia de Nivel 5

function s.cfilter1(c)
	return c:IsSetCard(0xbd) and c:IsMonster() and not c:IsPublic()
end
function s.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.thfilter1(c)
	return (c:IsRace(RACE_DRAGON) and c:IsLevel(5)) or (c:IsRace(RACE_BEAST) and c:IsLevel(5)) or c:IsSetCard(0xd7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-------------------------------------------------------
-- Efecto 2: Revelar un Dragón de Nivel 5 en mano, busca un monstruo 'Gaia', 'Buster Blader' monster, busca una Bestia de Nivel 5

function s.cfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(5) and not c:IsPublic()
end
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.thfilter2(c)
	return c:IsSetCard(0xbd) or (c:IsRace(RACE_BEAST) and c:IsLevel(5)) or c:IsSetCard(0xd7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-------------------------------------------------------
-- Efecto 3: Revelar un 'Buster Blader' en mano, busca un monstruo 'Gaia', 1 dragon de nivel 5, busca una Bestia de Nivel 5

function s.cfilter3(c)
	return c:IsSetCard(0xd7) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function s.thcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter3,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.thfilter3(c)
	return c:IsSetCard(0xbd) or (c:IsRace(RACE_BEAST) and c:IsLevel(5)) or (c:IsRace(RACE_DRAGON) and c:IsLevel(5)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter3,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
