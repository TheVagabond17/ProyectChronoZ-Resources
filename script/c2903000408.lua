--Enlightenment Gaia the Dragon Champion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,
		aux.FilterBoolFunctionEx(Card.IsSetCard,0xbd), -- "Gaia the Fierce Knight"
		s.matfilter)

	--Name becomes "Gaia the Dragon Champion"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(66889139)
	c:RegisterEffect(e1)

	--Quick Effect: Lose 2600 ATK to destroy 1 other card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	--If destroyed by battle: trigger optional effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(aux.bdocon)
	e3:SetOperation(s.trigop)
	c:RegisterEffect(e3)

	--If destroyed by own effect: trigger optional effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetFlagEffect(id)>0
	end)
	e4:SetOperation(s.trigop)
	c:RegisterEffect(e4)

	--Change position
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetTarget(s.postg)
	e5:SetOperation(s.posop)
	c:RegisterEffect(e5)
end

--Material: Level 5 Dragon
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON,fc,sumtype,tp) and c:IsLevel(5)
end

--Main Phase Quick Effect
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then return c:GetAttack()>=2600 and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:GetAttack()<2600 then return end
	if c:UpdateAttack(-2600,RESET_EVENT+RESETS_STANDARD,c)==-2600 then
		if tc and tc:IsRelateToEffect(e) then
			if Duel.Destroy(tc,REASON_EFFECT)>0 then
				-- Registrar la bandera para activar el trigger opcional
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
			end
		end
	end
end

--Trigger operation (usada por batalla o por propio efecto)
function s.trigop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local b2=true -- siempre válido

	if not (b1 or b2) then return end
	local opt=0
	if b1 and b2 then
		opt=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	elseif b1 then
		opt=1
	else
		opt=2
	end

	if opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif opt==2 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			if c:IsFaceup() and c:IsLocation(LOCATION_MZONE) then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(2600)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
				c:RegisterEffect(e2)
			end
		end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Buscar Spiral Spear Strike o Spiral Discharge
function s.spfilter(c)
	return c:IsCode(49328340,29477860) and not c:IsForbidden()
end

--Change Position
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsControler(1-tp) and d:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d and d:IsRelateToBattle() then
		Duel.ChangePosition(d,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end



