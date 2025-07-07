--Wealdwoe Crownless Knight
local s,id=GetID()
function s.initial_effect(c)
	-- Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)

	-- Special Summon from hand or GY by banishing 2 "Wealdwoe" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Flip Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.fliptg)
	e2:SetOperation(s.flipop)
	c:RegisterEffect(e2)

	-- Quick Effect: change position if Mistwoe is controlled
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(s.poscond)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end

-- Special Summon Cost
function s.cfilter(c)
	return c:IsSetCard(0x3101) and c:IsMonster() and aux.SpElimFilter(c,true,true) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,2,2,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end

-- Flip Effect
function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1_1 = Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCanTurnSet() end, tp, LOCATION_MZONE, 0, 1, nil)
	local b1_2 = Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCanTurnSet() end, tp, 0, LOCATION_MZONE, 1, nil)
	local b2 = Duel.IsExistingMatchingCard(function(c) return c:IsFacedown() and c:IsCanChangePosition() end, tp, LOCATION_MZONE, 0, 1, nil)
	if chk==0 then return (b1_1 or b1_2) or b2 end
	e:SetLabel(0)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local b1_1 = Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCanTurnSet() end, tp, LOCATION_MZONE, 0, 1, nil)
	local b1_2 = Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCanTurnSet() end, tp, 0, LOCATION_MZONE, 1, nil)
	local b2 = Duel.IsExistingMatchingCard(function(c) return c:IsFacedown() and c:IsCanChangePosition() end, tp, LOCATION_MZONE, 0, 1, nil)

	if not ((b1_1 or b1_2) or b2) then return end

	local main_option = -1
	if (b1_1 or b1_2) and b2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3)) -- "Choose Flip Effect"
		main_option = Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5)) -- 0: Opción 1, 1: Opción 2
	elseif b2 then
		main_option = 1
	else
		main_option = 0
	end

	if main_option == 0 then
		-- Submenú: ¿tuyos o del oponente?
		local sub_option = -1
		if b1_1 and b1_2 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,6)) -- "Choose who to flip face-down"
			sub_option = Duel.SelectOption(tp,aux.Stringid(id,7),aux.Stringid(id,8)) -- 0: tuyos, 1: oponente
		elseif b1_1 then
			sub_option = 0
		else
			sub_option = 1
		end

		if sub_option == 0 then
			local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsCanTurnSet() end, tp, LOCATION_MZONE, 0, nil)
			if #g>0 then Duel.ChangePosition(g, POS_FACEDOWN_DEFENSE) end
		else
			local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsCanTurnSet() end, tp, 0, LOCATION_MZONE, nil)
			if #g>0 then Duel.ChangePosition(g, POS_FACEDOWN_DEFENSE) end
		end

	else
		-- Voltear todos tus monstruos boca abajo a boca arriba DEF
		local g=Duel.GetMatchingGroup(function(c) return c:IsFacedown() and c:IsCanChangePosition() end, tp, LOCATION_MZONE, 0, nil)
		if #g>0 then Duel.ChangePosition(g, POS_FACEUP_DEFENSE) end
	end
end


-- Quick Effect condition
function s.poscond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(2903000801) end,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.posfilter1(c) return c:IsFacedown() and c:IsCanChangePosition() end
function s.posfilter2(c) return c:IsFaceup() and c:IsCanTurnSet() end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.posfilter1,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.posfilter2,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end

	local opt = -1
	if b1 and not b2 then
		opt=0
	elseif not b1 and b2 then
		opt=1
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- 0: to ATK, 1: to facedown DEF
	end
	e:SetLabel(opt)
	local f = (opt==0) and s.posfilter1 or s.posfilter2
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,f,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	else
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

