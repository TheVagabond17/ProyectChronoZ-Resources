--Witness of Destruction Swordsman
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand by sending 1 "Destruction Sword" from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--Effect on Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_names={6390406} -- Emblem of Dragon Destroyer
s.listed_series={0xd6} -- Destruction Sword

-- Special Summon by sending 1 "Destruction Sword" from Deck to GY
function s.tgfilter(c)
	return c:IsSetCard(0xd6) and c:IsAbleToGrave()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	return true -- No cost, handled in operation
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- On Summon: Search 1 of 2 options
function s.thfilter1(c)
	return c:IsCode(6390406) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsSetCard(0xd6) and c:IsAbleToHand() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
			or Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil)
	if not (b1 or b2) then return end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	else
		op=1
	end

	local g=nil
	if op==0 then
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	else
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
	end

	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
