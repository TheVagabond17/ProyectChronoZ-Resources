--Trinity Force
local s,id=GetID()
function s.initial_effect(c)
	--Destroy up to 1 card per Knight you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT}

-- Check if you control Q/K/J Knight
function s.knightfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	if Duel.IsExistingMatchingCard(s.knightfilter,tp,LOCATION_MZONE,0,1,nil,25652259) then ct=ct+1 end -- Queen's Knight
	if Duel.IsExistingMatchingCard(s.knightfilter,tp,LOCATION_MZONE,0,1,nil,64788463) then ct=ct+1 end -- King's Knight
	if Duel.IsExistingMatchingCard(s.knightfilter,tp,LOCATION_MZONE,0,1,nil,90876561) then ct=ct+1 end -- Jack's Knight

	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
