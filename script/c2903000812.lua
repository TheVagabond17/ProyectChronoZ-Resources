--Wealdwoe Torture Hall
local s,id=GetID()
function s.initial_effect(c)
	-- Activar
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)

	-- Daño cuando un "Wealdwoe" se voltea boca arriba
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.damcon1)
	e1:SetOperation(s.damop1)
	c:RegisterEffect(e1)

	-- Revelar 1 boca abajo: inflige daño si es "Wealdwoe"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.damcon2)
	e2:SetTarget(s.damtg2)
	e2:SetOperation(s.damop2)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)

	-- Si esta carta boca arriba es destruida por efecto del oponente y controlas "Mistwoe"
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.damcon3)
	e3:SetTarget(s.damtg3)
	e3:SetOperation(s.damop3)
	c:RegisterEffect(e3)
end
s.listed_series={0x3101}
s.listed_names={2903000801}

-- E1: Flip Damage
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c) return c:IsSetCard(0x3101) and c:IsFaceup() and c:IsControler(tp) end,1,nil)
end
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(function(c) return c:IsSetCard(0x3101) and c:IsFaceup() and c:IsControler(tp) end,nil)
	if ct>0 then
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end

-- E2: Reveal face-down monster
-- E2: Voltea 1 boca abajo, inflige daño si es "Wealdwoe"
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		if tc:IsSetCard(0x3101) then
			Duel.Damage(1-tp,400,REASON_EFFECT)
		end
	end
end

-- E3: Daño al ser destruida por el oponente
-- Efecto 3: Si esta carta boca arriba es destruida por el efecto del oponente y controlas "Mistwoe", inflige 500 por cada "Wealdwoe" boca arriba
function s.damcon3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsReason(REASON_EFFECT)
		and rp~=tp
		and c:IsPreviousControler(tp)
		and Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsCode(2903000801)
		end,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.damtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(function(c)
		return c:IsFaceup() and c:IsSetCard(0x3101) and c:IsMonster()
	end,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end

function s.damop3(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

