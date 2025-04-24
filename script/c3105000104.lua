-- Alien Royal Guard
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon (Quick Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)

	-- Negate Effect Monsters with A-Counters (except "Alien" monsters)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)

	-- Cannot Attack (except "Alien" monsters)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)
end

s.counter_list={COUNTER_A}

-- Special Summon Cost: Remove 3 A-Counters from anywhere on the field
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_A,3,REASON_COST)
	end
	Duel.RemoveCounter(tp,1,1,COUNTER_A,3,REASON_COST)
end

-- Special Summon Targeting
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Special Summon Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Negate Effect Target: Monsters with A-Counters, except "Alien" monsters
function s.distg(e,c)
	return c:GetCounter(COUNTER_A)>0 and not c:IsSetCard(0xc)  -- Exclude "Alien" monsters
end

-- Cannot Attack Target: Monsters with A-Counters, except "Alien" monsters
function s.atktg(e,c)
	return c:GetCounter(COUNTER_A)>0 and not c:IsSetCard(0xc)  -- Exclude "Alien" monsters
end

