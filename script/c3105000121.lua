-- External Iron Core of Koa'ki Meiru
local s, id = GetID()

function s.initial_effect(c)
	-- Name becomes "Iron Core of Koa'ki Meiru" 
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(36623431) -- Iron Core of Koa'ki Meiru ID
	c:RegisterEffect(e0)

	-- Activate and stay on field (Continuous Spell)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	-- Special Summon Koa'ki Meiru monster from hand, Deck, or GY (Level 4 or lower, different name)
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Add "Iron Core of Koa'ki Meiru" when sent to GY
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1, {id, 1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_names = {36623431}  -- Iron Core of Koa'ki Meiru
s.listed_series = {0x1d}	 -- Koa'ki Meiru

-- Quick Effect Condition: Only during Main Phase
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsMainPhase()
end

-- Quick Effect Condition: Only during Main Phase
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsMainPhase()
end

-- Cost: Send 1 "Koa'ki Meiru" card from hand to GY
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST)
end

function s.costfilter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToGraveAsCost()
end

-- Special Summon target: Level 4 or lower "Koa'ki Meiru" with a different name from face-up monsters you control
function s.spfilter(c, e, tp)
	return c:IsSetCard(0x1d) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- Check for monsters with the same name on the field
function s.diffnamefilter(c, e, tp)
	local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard, 0x1d), tp, LOCATION_MZONE, 0, nil)
	for mc in g:Iter() do
		if mc:GetCode() == c:GetCode() then return false end
	end
	return s.spfilter(c, e, tp)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local g = Duel.GetMatchingGroup(s.diffnamefilter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, nil, e, tp)
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and #g > 0
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.diffnamefilter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
	end
end

-- Add "Iron Core of Koa'ki Meiru" to hand when sent to GY
function s.thfilter(c)
	return c:IsCode(36623431) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end
