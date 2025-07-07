--Wealdwoe Continuum Seal
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Flip 1 Set "Wealdwoe" monster, then Special Summon Level 3 "Wealdwoe" from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	-- GY Quick Effect: If Mistwoe is controlled and exactly 2 "Wealdwoe" monsters, negate 1 opponent's face-up card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3101}
s.listed_names={2903000801}

-- E1: Flip 1 Set "Wealdwoe", then Special Summon Level 3 "Wealdwoe" from Deck
function s.setfilter(c)
	return c:IsSetCard(0x3101) and c:IsFacedown() and c:IsCanChangePosition()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3101) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.HintSelection(g)

	-- Elegís posición boca arriba para el monstruo Set
	local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
	if Duel.ChangePosition(tc,pos)~=0 then
		-- ✅ Termina la cadena aquí: se permite el Flip Trigger
		Duel.BreakEffect() -- comienza nueva cadena

		-- Invocar desde el Deck
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			local sc=sg:GetFirst()
			local pos2=Duel.SelectPosition(tp,sc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
			Duel.SpecialSummon(sc,0,tp,tp,false,false,pos2)
		end
	end
end



-- e2: GY Quick Effect - negate opponent face-up card
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(2903000801)
end
function s.woefilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3101) and c:IsMonster()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.GetTurnPlayer()~=tp
		and Duel.GetCurrentPhase()~=PHASE_DRAW
		and Duel.GetCurrentPhase()~=PHASE_DAMAGE
		and Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL
		and Duel.GetFlagEffect(tp,id)==0
		and Duel.GetMatchingGroupCount(s.woefilter,tp,LOCATION_MZONE,0,nil)==2
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) 
			and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

