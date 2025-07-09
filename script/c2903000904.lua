--Harvest Angel of Foresight
local s,id=GetID()
function s.initial_effect(c)
	-- When this card is Summoned: Search + Optional Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_SANCTUARY_SKY} -- "The Sanctuary in the Sky"

-- Check for Sanctuary
function s.sanctuaryfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_SANCTUARY_SKY)
end

-- Search filters
function s.hornfilter(c)
	return (c:IsCode(98069388) or c:IsCode(50323155) or c:IsCode(1637760)) and c:IsAbleToHand()
end
function s.mentionfilter(c)
	return c:ListsCode(CARD_SANCTUARY_SKY) and c:IsAbleToHand()
end

-- Target
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local hasSanctuary = Duel.IsExistingMatchingCard(s.sanctuaryfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		local canHorn = Duel.IsExistingMatchingCard(s.hornfilter,tp,LOCATION_DECK,0,1,nil)
		local canMention = Duel.IsExistingMatchingCard(s.mentionfilter,tp,LOCATION_DECK,0,1,nil)
		if hasSanctuary then
			return canHorn or canMention
		else
			return canHorn
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Operation
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local hasSanctuary = Duel.IsExistingMatchingCard(s.sanctuaryfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local g1 = Duel.GetMatchingGroup(s.hornfilter,tp,LOCATION_DECK,0,nil)
	local g2 = Duel.GetMatchingGroup(s.mentionfilter,tp,LOCATION_DECK,0,nil)
	local g=nil

	if hasSanctuary and #g1>0 and #g2>0 then
		-- Elegir entre Horn o cartas que mencionen Sanctuary
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			g = g2:Select(tp,1,1,nil)
		else
			g = g1:Select(tp,1,1,nil)
		end
	elseif #g2>0 and hasSanctuary then
		g = g2:Select(tp,1,1,nil)
	elseif #g1>0 then
		g = g1:Select(tp,1,1,nil)
	end

	if g and #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		-- Optional immediate Normal Summon of LIGHT Fairy
		local hg=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil)
		if #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg=hg:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end

-- Filter for optional summon
function s.nsfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSummonable(true,nil)
end



