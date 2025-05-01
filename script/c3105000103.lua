-- Alien Invasion
local s, id = GetID()

function s.initial_effect(c)
	-- Activate + Search
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)

	-- Place 1 A-Counter on each face-up monster once per turn
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1, {id, 1})
	e1:SetCondition(s.place_counter_condition)
	e1:SetOperation(s.place_counter)
	c:RegisterEffect(e1)

	-- Remove A-Counters and apply effect
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY + CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.effect_target)
	e2:SetOperation(s.effect_operation)
	c:RegisterEffect(e2)
end

s.listed_series = {0xc} -- "Alien"
s.counter_place_list = {COUNTER_A}

-- Effect on activation: Add 1 "Alien" monster from Deck to hand
function s.filter(c)
	return c:IsSetCard(0xc) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetMatchingGroupCount(s.filter, tp, LOCATION_DECK, 0, nil) > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
		if #g > 0 then
			Duel.SendtoHand(g, tp, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, g)
		end
	end
end

-- Place A-Counters if any monster is face-up and valid
function s.place_counter_condition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCanAddCounter, COUNTER_A, 1), tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
end
function s.place_counter(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter, COUNTER_A, 1), tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	for tc in g:Iter() do
		tc:AddCounter(COUNTER_A, 1)
	end
end

-- Effect target check
function s.spfilter_hand(c, e, tp)
	return c:IsSetCard(0xc) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.spfilter_deck_gy(c, e, tp)
	return c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.has_a_counter(c)
	return c:GetCounter(COUNTER_A) > 0
end
function s.effect_target(e, tp, eg, ep, ev, re, r, rp, chk)
	local canSummonHand = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsCanRemoveCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A, 3, REASON_COST)
		and Duel.IsExistingMatchingCard(s.spfilter_hand, tp, LOCATION_HAND, 0, 1, nil, e, tp)

	local canDestroy = Duel.IsCanRemoveCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A, 5, REASON_COST)
		and Duel.IsExistingMatchingCard(s.has_a_counter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)

	local canSummonDeckGY = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsCanRemoveCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A, 8, REASON_COST)
		and Duel.IsExistingMatchingCard(s.spfilter_deck_gy, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)

	if chk == 0 then return canSummonHand or canDestroy or canSummonDeckGY end

	if canSummonHand then Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND) end
	if canDestroy then Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD) end
	if canSummonDeckGY then Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE) end
end

function s.effect_operation(e, tp, eg, ep, ev, re, r, rp)
	local canSummonHand = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(s.spfilter_hand, tp, LOCATION_HAND, 0, 1, nil, e, tp)

	local canDestroy = Duel.IsExistingMatchingCard(s.has_a_counter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)

	local canSummonDeckGY = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(s.spfilter_deck_gy, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)

	local op = Duel.SelectEffect(tp,
		{canSummonHand and Duel.IsCanRemoveCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A, 3, REASON_COST), aux.Stringid(id, 3)}, -- 3: Special Summon from hand
		{canDestroy and Duel.IsCanRemoveCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A, 5, REASON_COST), aux.Stringid(id, 4)}, -- 5: Destroy card with A-Counter
		{canSummonDeckGY and Duel.IsCanRemoveCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A, 8, REASON_COST), aux.Stringid(id, 5)} -- 8: Special Summon from Deck/GY
	)

	local ct = (op == 1 and 3) or (op == 2 and 5) or (op == 3 and 8)
	if not Duel.RemoveCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A, ct, REASON_COST) then return end

	if op == 1 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g = Duel.SelectMatchingCard(tp, s.spfilter_hand, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
		if #g > 0 then
			Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
		end
	elseif op == 2 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local g = Duel.SelectMatchingCard(tp, s.has_a_counter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
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
