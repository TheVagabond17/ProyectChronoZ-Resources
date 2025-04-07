-- Dimensional Deflection Field
local s,id=GetID()
function s.initial_effect(c)
	-- Solo puedes activar 1 "Dimensional Deflection Field" por turno
	c:SetUniqueOnField(1,0,id)

	-- Activar
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e0)

	-- Efecto: negar ataque y desterrar un monstruo "D.D." cuando es atacado
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.bancon)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)

	-- Efecto 2: Si se desterraron 3+ monstruos por el efecto 1, puedes destruir esta carta y desterrar todos los monstruos del oponente
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_BATTLE_END+TIMING_END_PHASE)
	e2:SetCondition(s.nukcon)
	e2:SetCost(s.nukcost)
	e2:SetTarget(s.nuktg)
	e2:SetOperation(s.nukop)
	c:RegisterEffect(e2)

	-- Resetear contador al inicio del turno (por carta)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		c:SetTurnCounter(0)
	end)
	c:RegisterEffect(e3)
end

-- Lista de cartas "D.D."
s.listed_cards={
	3773196,7572887,16638212,24508238,33243043,37043180,44792253,48092532,
	48148828,57101885,52702748,56790702,70074904,75991479,80201858,86498013,
	89015998,95291684,3105000126,3105000127,3105000128,3105000129
}

function s.isDDBased(c)
	for _,code in ipairs(s.listed_cards) do
		if c:IsCode(code) then return true end
	end
	return false
end

-- Condición: el objetivo del ataque es un "D.D." que controlas
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and s.isDDBased(d)
end

-- Target: confirmar que existe el objetivo
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(Duel.GetAttackTarget())
end

-- Operación: negar el ataque y desterrar al objetivo
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=Duel.GetFirstTarget()
	if not d or not d:IsRelateToBattle() then return end

	if Duel.Remove(d,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		Duel.NegateAttack()

		-- Aumentar el contador de esta copia de carta
		c:SetTurnCounter(c:GetTurnCounter() + 1)

		-- Devolver al End Phase (una sola vez)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(d)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			local rc=e:GetLabelObject()
			if rc and rc:IsLocation(LOCATION_REMOVED) then
				Duel.ReturnToField(rc)
			end
		end)
		Duel.RegisterEffect(e1,tp)
	end
end

-- Condición para activar el segundo efecto (por carta)
function s.nukcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnCounter()>=3
end

-- Coste: destruir esta carta
function s.nukcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Destroy(e:GetHandler(),REASON_COST)
end

-- Target y operación del segundo efecto
function s.nuktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_MZONE)
end

function s.nukop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end



