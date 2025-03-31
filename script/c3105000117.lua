--Alien Overlord
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_A)
	
	-- Gain ATK for each A-Counter on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	
	-- Avoid destruction by removing 10 A-Counters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	c:RegisterEffect(e2)
	
	-- Main Phase effect: Place A-Counters or Quick Effect to take control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.cnttg)
	e3:SetOperation(s.cntop)
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetHintTiming(0, TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCondition(s.ctlcon)
	e4:SetTarget(s.ctltg)
	e4:SetOperation(s.ctlop)
	c:RegisterEffect(e4)
end
s.listed_series={0xc} -- "Alien" archetype
s.counter_place_list={COUNTER_A}

-- Gain 100 ATK for each A-Counter on the field
function s.atkval(e,c)
	return Duel.GetCounter(0,1,1,COUNTER_A) * 100
end

-- Avoid destruction by removing 5 A-Counters
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) 
			and c:GetCounter(COUNTER_A)>=5
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		c:RemoveCounter(tp,COUNTER_A,5,REASON_EFFECT)
		return true
	else
		return false
	end
end

-- Place A-Counters
function s.cnttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end

function s.cntop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	c:AddCounter(COUNTER_A,count)
end

-- Quick Effect to Take Control
function s.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.controlfilter(c)
	return c:IsFaceup() and c:GetCounter(COUNTER_A)>0
end

function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.controlfilter,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 -- Verifica que haya espacio
	end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end

function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.controlfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		tc:RemoveCounter(tp,COUNTER_A,tc:GetCounter(COUNTER_A),REASON_EFFECT)
		if Duel.GetControl(tc,tp) then
			-- Cambiar el tipo a Reptil
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_REPTILE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

