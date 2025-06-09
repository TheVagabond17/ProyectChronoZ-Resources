--Salamandra of Red-Eyes
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to "Red-Eyes" or monster that mentions "Flame Swordsman"
	aux.AddEquipProcedure(c,0,s.eqfilter)

	--ATK Boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(700)
	c:RegisterEffect(e1)

	--Return from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	--If equipped to Flame Swordsman: banish monsters destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetCondition(s.banish_cond)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
  
	--If equipped to Red-Eyes: send equips to GY and destroy cards
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)

	--If equipped to Flame Manipulator or Masaki: perform Fusion Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.fuscon)
	e5:SetTarget(s.fustg)
	e5:SetOperation(s.fusop)
	c:RegisterEffect(e5)
end

-- IDs de Flame Swordsman
s.listed_names={45231177,34460851,44287299} -- Flame Swordsman, Flame Manipulator, Masaki

s.flame_swordsman_ids={45231177,27704731,1047075,50903514,324483}

-- Equip filter
function s.eqfilter(c)
	return c:IsSetCard(0x3b) or c:ListsCode(45231177) or c:IsCode(45231177)
end

-- GY to hand cost
function s.cfilter(c)
	return ((c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)) or (c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER)))
		and c:IsAbleToDeck()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end

-- Flame Swordsman check
function s.isFlameSwordsman(c)
	for _,code in ipairs(s.flame_swordsman_ids) do
		if c:IsCode(code) then return true end
	end
end

function s.banish_cond(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and s.isFlameSwordsman(ec)
end

-- Red-Eyes check
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x3b)
end

-- Target: destruir hasta tantas cartas como equipos tenga el monstruo equipado
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then return false end

	local eqs=ec:GetEquipGroup()
	if chk==0 then return #eqs>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eqs,#eqs,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,#eqs,0,LOCATION_ONFIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then return end

	local eqs=ec:GetEquipGroup()
	local ct=Duel.SendtoGrave(eqs,REASON_EFFECT)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

-- Flame Manipulator or Masaki check
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:IsCode(34460851) or ec:IsCode(44287299)) -- Flame Manipulator or Masaki
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=e:GetHandler():GetEquipTarget()
		local mg=Duel.GetFusionMaterial(tp)
		if ec then mg:AddCard(ec) end
		return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and Duel.GetFusionMaterial(tp):IsExists(Card.IsCanBeFusionMaterial,1,nil,c)
		and c:CheckFusionMaterial(mg)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local mg=Duel.GetFusionMaterial(tp)
	if ec then mg:AddCard(ec) end

	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
	if not mat or #mat==0 then return end

	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end