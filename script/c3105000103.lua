-- Alien Invasion
local s, id = GetID()

function s.initial_effect(c)
	-- Activate: Add 1 "Alien" card from Deck to hand
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Place 1 A-Counter on each face-up monster once per turn
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.place_counter_condition)
	e2:SetOperation(s.place_counter)
	c:RegisterEffect(e2)

	-- Remove A-Counters and apply effect
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.effect_target)
	e3:SetOperation(s.effect_operation)
	c:RegisterEffect(e3)
end

s.listed_series = {0xc} -- "Alien" archetype
s.counter_place_list = {COUNTER_A} -- A-Counter

-- Effect 1: Add 1 "Alien" card from your Deck to your hand, except "Alien Invasion"
function s.activate(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetMatchingGroup(s.alien_filter, tp, LOCATION_DECK, 0, nil)
	if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local sg = g:Select(tp, 1, 1, nil)
		Duel.SendtoHand(sg, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, sg)
	end
end

function s.alien_filter(c)
	return c:IsSetCard(0xc) and not c:IsCode(id) and c:IsAbleToHand()
end

-- Effect 2: Condition to place A-Counters (requires at least 1 monster on the field)
function s.spfilter(c, e, tp)
	return c:IsSetCard(0xc) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.place_counter_condition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCanAddCounter, COUNTER_A, 1), tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
end

function s.place_counter(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter, COUNTER_A, 1), tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	for tc in g:Iter() do
		tc:AddCounter(COUNTER_A, 1)
	end
end

-- Effect 3: Remove 3, 5, or 8 A-Counters and apply effects
function s.effect_target(e, tp, eg, ep, ev, re, r, rp, chk)
	local canSummonHand = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsCanRemoveCounter(tp, LOCATION_MZONE, LOCATION_MZONE, COUNTER_A, 3, REASON_COST)
		and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp)
	
	local canDestroy = Duel.IsCanRemoveCounter(tp, LOCATION_MZONE, LOCATION_MZONE, COUNTER_A, 5, REASON_COST)
		and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)

	local canSummonDeckGY = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsCanRemoveCounter(tp, LOCATION_MZONE, LOCATION_MZONE, COUNTER_A, 8, REASON_COST)
		and Duel.IsExistingMatchingCard(s.spfilter_deck_gy, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)

	if chk == 0 then return canSummonHand or canDestroy or canSummonDeckGY end

	if canSummonHand then Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND) end
	if canDestroy then Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD) end
	if canSummonDeckGY then Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE) end
end

function s.spfilter(c, e, tp)
	return c:IsSetCard(0xc) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spfilter_deck_gy(c, e, tp)
	return c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.effect_operation(e, tp, eg, ep, ev, re, r, rp)
	local canSummonHand = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp) -- Aquí aseguramos que haya al menos 1 monstruo válido

	local canDestroy = Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)

	local canSummonDeckGY = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(s.spfilter_deck_gy, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)

	local op = Duel.SelectEffect(tp,
		{canSummonHand and Duel.IsCanRemoveCounter(tp, LOCATION_MZONE, LOCATION_MZONE, COUNTER_A, 3, REASON_COST), aux.Stringid(id,3)}, -- Special Summon from hand
		{canDestroy and Duel.IsCanRemoveCounter(tp, LOCATION_MZONE, LOCATION_MZONE, COUNTER_A, 5, REASON_COST), aux.Stringid(id,4)}, -- Destroy
		{canSummonDeckGY and Duel.IsCanRemoveCounter(tp, LOCATION_MZONE, LOCATION_MZONE, COUNTER_A, 8, REASON_COST), aux.Stringid(id,5)} -- Special Summon from Deck/GY
	)

	local ct = (op == 1 and 3) or (op == 2 and 5) or (op == 3 and 8)
	if not Duel.RemoveCounter(tp, LOCATION_MZONE, LOCATION_MZONE, COUNTER_A, ct, REASON_COST) then return end

	if op == 1 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
		if #g > 0 then
			Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
		end
	elseif op == 2 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
		if #g > 0 then
			Duel.Destroy(g, REASON_EFFECT)
		end
	elseif op == 3 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g = Duel.SelectMatchingCard(tp, s.spfilter_deck_gy, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
		if #g > 0 then
			Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
		end
	end
end
