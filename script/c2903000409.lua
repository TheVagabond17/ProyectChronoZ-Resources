--Magical Dragon - Curse of Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Fusion Material: 1 Warrior + 1 Level 5 or higher Dragon
	Fusion.AddProcMix(c, true, true,
		aux.FilterBoolFunctionEx(Card.IsRace, RACE_WARRIOR),
		s.matfilter)

	-- While on the field: can banish GY monsters as material for Dragon Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_GRAVE,0)
	e1:SetTarget(function(e,c) return c:IsAbleToRemove() and c:IsMonster() end)
	e1:SetOperation(Fusion.BanishMaterial)
	e1:SetValue(function(e,c)
		return c and c:IsRace(RACE_DRAGON) and c:IsControler(e:GetHandlerPlayer())
	end)
	c:RegisterEffect(e1)

	-- Shuffle 3 Dragon/Warrior monsters into the Deck, then add 1 Spell/Trap that lists Gaia
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_GAIA_CHAMPION}

function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON,fc,sumtype,tp) and c:IsLevelAbove(5)
end

function s.tdfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR)) and c:IsAbleToDeck()
end

function s.thfilter(c)
	return c:IsSpellTrap() and c:ListsCode(CARD_GAIA_CHAMPION) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	if #g==3 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
