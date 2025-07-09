--The Sanctum in the Sky
local s,id=GetID()
function s.initial_effect(c)
	--Activate (Only 1 per turn)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)

	--Gain LP when a Fairy monster is Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--Avoid battle damage to controller of Fairy monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

-- LP Gain Operation
function s.lpfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsControler(tp)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.lpfilter,nil,tp)
	local ct=#g
	if ct>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end
