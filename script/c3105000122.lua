-- Koa'ki Meiru Protos
local s,id=GetID()
function s.initial_effect(c)
	-- Replace Iron Core send
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	
	-- Special Summon effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
end
s.listed_names={36623431} -- Iron Core of Koa'ki Meiru

-- Check if "Iron Core of Koa'ki Meiru" would be sent from the hand to the GY by a "Koa'ki Meiru" monster effect
function s.repfilter(c,tp)
	return c:IsCode(36623431) and c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re and re:GetHandler():IsSetCard(0x1d) and re:GetHandler():IsMonster() and eg:IsExists(s.repfilter,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,0)) then
		e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
		return true
	else
		return false
	end
end

function s.repval(e,c)
	return c:IsCode(36623431) and c:IsLocation(LOCATION_HAND) and c:IsControler(e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id) > 0 and c:IsLocation(LOCATION_HAND) then
		Duel.SendtoGrave(c, REASON_EFFECT)
	end
end

-- Condition for Special Summon effect
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()==e:GetHandler()
end

-- Target for Special Summon effect
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Special Summon filter
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Operation for Special Summon effect
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end





