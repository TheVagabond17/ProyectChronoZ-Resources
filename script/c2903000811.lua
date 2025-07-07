--Wealdwoe Lurking Dread
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Return 1 Set card, optional extra effect if controlling "Mistwoe - Castle of Dark Illusions"
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={2903000801}
s.listed_series={0x3101}

function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function s.tg2filter(c)
	return c:IsAbleToHand()
end
function s.setfilter(c,e,tp)
	return c:IsSetCard(0x3101)
		and ((c:IsSpell() or c:IsTrap() and c:IsSSetable())
		or (c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	-- Check for additional effect if you control "Mistwoe - Castle of Dark Illusions"
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,2903000801)
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			-- Check for Spell/Trap or Monster to Set or Summon
			local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND,0,nil,e,tp)
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
				local sc=sg:Select(tp,1,1,nil):GetFirst()
				if sc:IsSpell() or sc:IsTrap() then
					Duel.SSet(tp,sc)
				elseif sc:IsMonster() then
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
					Duel.ConfirmCards(1-tp,Group.FromCards(sc))
				end
			end
		end
	end
end
