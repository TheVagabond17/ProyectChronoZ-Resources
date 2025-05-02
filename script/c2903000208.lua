--Blue-Eyes Fang Dragon
local s,id=GetID()
s.listed_names={CARD_BLUEEYES_W_DRAGON,2903000205}

function s.initial_effect(c)
	-- Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_BLUEEYES_W_DRAGON,2903000205)
	c:AddMustFirstBeFusionSummoned()

	-- Opponent cannot activate cards/effects during your Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.battlecon)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- Effect on inflicting battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end

-- Battle Phase condition
function s.battlecon(e)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end

-- Battle damage condition
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and ev>0
end

-- Disable effects of monsters with <= damage ATK until end of next turn
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local atk=ev
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetLabel(atk)
	e1:SetValue(s.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
end

function s.actlimit(e,re,tp)
	local c=re:GetHandler()
	return c:IsType(TYPE_MONSTER) and c:GetAttack()<=e:GetLabel()
end

