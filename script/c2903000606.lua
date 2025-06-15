--Parasitized Ultimate Great Moth 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,2903000605,14457896) -- Reemplaza con los IDs reales

	-- Alternative Special Summon condition (banish from field)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.altspcon)
	e1:SetOperation(s.altspop)
	c:RegisterEffect(e1)

	-- Make all other face-up monsters Insect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.racetg)
	e2:SetValue(RACE_INSECT)
	c:RegisterEffect(e2)

	-- Quick Effect: Tribute Insects to take control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1) -- "Once while face-up on the field"
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end

s.listed_names={2903000605,14457896}

-- Función para Fusión alternativa desde el campo
function s.altspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.matfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.matfilter2,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.matfilter1(c)
	return c:IsCode(2903000605) and c:IsAbleToRemoveAsCost()
end
function s.matfilter2(c)
	return c:IsCode(14457896) and c:IsAbleToRemoveAsCost()
end

function s.altspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.SelectMatchingCard(tp,s.matfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

-- Solo afecta a los demás monstruos
function s.racetg(e,c)
	return c~=e:GetHandler()
end

-- Cost: Tribute any number of Insect monsters you control
function s.cfilter(c,tp)
	return c:IsRace(RACE_INSECT) and c:IsAbleToGraveAsCost() and c:IsReleasable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,63,nil,tp)
	e:SetLabel(#g) -- Guardamos cuántos se tributaron
	Duel.Release(g,REASON_COST)
end

-- Target up to the number of monsters tributed
function s.filter(c)
	return c:IsControlerCanBeChanged()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
end

-- Take control of those monsters; they cannot attack this turn
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	for tc in aux.Next(g) do
		if Duel.GetControl(tc,tp)~=0 then
			-- Prevent that monster from attacking this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end

