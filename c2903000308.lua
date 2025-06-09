--Ferocious Masaki, the Legendary Swordsman
local s,id=GetID()
function s.initial_effect(c)
	-- Treated as "Masaki, the Legendary Swordsman" anywhere
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(44287299) -- Masaki, the Legendary Swordsman
	c:RegisterEffect(e0)

	-- On Normal Summon: Add 1 "Flame Manipulator", then restriction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- If used as Fusion Material for Flame Swordsman or a monster that mentions it
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end

s.listed_names={34460851,44287299,45231177} -- Flame Manipulator, Masaki, Flame Swordsman

-- Buscar "Flame Manipulator"
function s.thfilter(c)
	return c:IsCode(34460851) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		-- Restricción: solo puedes Invocar monstruos FUEGO el resto del turno
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_DARK)
end

-- Condición para efecto otorgado
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_FUSION and c:IsLocation(LOCATION_GRAVE)
		and eg:IsExists(function(tc) return tc:IsCode(45231177) or tc:ListsCode(45231177) end,1,nil)
end

-- Otorgar efecto al monstruo Fusionado
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsCode(45231177) or tc:ListsCode(45231177) then
			-- Gana 1000 ATK durante la Battle Phase y efecto de recuperar Magia de Equipo
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCondition(s.atkcon)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)

			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,2))
			e2:SetCategory(CATEGORY_TOHAND)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
			e2:SetCode(EVENT_BATTLE_DESTROYING)
			e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CLIENT_HINT)
			e2:SetCondition(aux.bdocon)
			e2:SetTarget(s.eqtg)
			e2:SetOperation(s.eqop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end
end
function s.atkcon(e)
	return Duel.IsBattlePhase()
end

-- Recuperar Equip Spell del GY
function s.eqfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

