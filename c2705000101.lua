-- Forbidden Memories - Millennium Puzzle
local s, id = GetID()

function s.initial_effect(c)
	
	-- Activate
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e4)

	-- Cannot be targeted or destroyed by monster effects
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)

	local e1 = e0:Clone()
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e1)

	-- Grant immunity to 1 monster you control
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1, {id, 1})
	e2:SetTarget(s.imm_target)
	e2:SetOperation(s.imm_operation)
	c:RegisterEffect(e2)

	-- Stack a card from Deck during opponent's End Phase
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE + PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1, {id, 2})
	e3:SetCondition(s.stack_condition)
	e3:SetTarget(s.stack_target)
	e3:SetOperation(s.stack_operation)
	c:RegisterEffect(e3)
end

-- Not targeted/destroyed by monster effects
function s.efilter(e, re, rp)
	return re:IsActiveType(TYPE_MONSTER)
end

-- Immunity effect: target 1 monster, make it unaffected by opponent's card effects
function s.imm_target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.imm_operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.immfilter)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end

function s.immfilter(e, te)
	return te:GetOwnerPlayer() ~= e:GetOwnerPlayer()
end

-- Stack a card from Deck during opponent's End Phase
function s.stack_condition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer() ~= tp
end

function s.stack_filter(c)
	return c:IsAbleToDeck() and not c:IsType(TYPE_EXTRA)
end

function s.stack_target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.stack_filter, tp, LOCATION_DECK, 0, 1, nil) end
end

function s.stack_operation(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id,2))
	local g = Duel.SelectMatchingCard(tp, s.stack_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(g, tp)
	end
end

