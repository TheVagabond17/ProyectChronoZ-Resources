-- Iron Core Self-Destruct Protocol
local s, id = GetID()

function s.initial_effect(c)
	-- Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end

s.listed_series = {0x1d} -- Koa'ki Meiru

-- Target up to 2 "Koa'ki Meiru" monsters you control
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d) and c:IsType(TYPE_MONSTER) and c:IsDestructable()
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc) end
	if chk == 0 then
		return Duel.IsExistingTarget(s.desfilter, tp, LOCATION_MZONE, 0, 1, nil) and
			   Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectTarget(tp, s.desfilter, tp, LOCATION_MZONE, 0, 1, 2, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetTargetCards(e)
	if #g > 0 and Duel.Destroy(g, REASON_EFFECT) > 0 then
		local ct = #g
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local dg = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, ct, ct, nil)
		if #dg > 0 then
			Duel.Destroy(dg, REASON_EFFECT)
		end
	end
end
