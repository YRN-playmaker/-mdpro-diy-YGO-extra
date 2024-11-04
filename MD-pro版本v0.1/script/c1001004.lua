--电子三重进化光焰
function c1001004.initial_effect(c)
	-- 速攻魔法效果
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001004, 0))
	e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DISABLE + CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, 1001004)
	e1:SetTarget(c1001004.target)
	e1:SetOperation(c1001004.activate)
	c:RegisterEffect(e1)
end

function c1001004.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end

function c1001004.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(c1001004.filter, tp, LOCATION_MZONE, 0, 1, nil) end
	local opt = 0
	if Duel.IsExistingMatchingCard(c1001004.filter, tp, LOCATION_MZONE, 0, 1, nil) then
		opt = 3 -- 选择三者
	end
	e:SetLabel(opt)
	Duel.SetTargetPlayer(tp)
end

function c1001004.activate(e, tp, eg, ep, ev, re, r, rp)
	local opt = e:GetLabel()
	if opt == 0 then return end
	if opt == 1 then
		-- 降低攻击力
		local g = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_MZONE, LOCATION_MZONE, nil, TYPE_MONSTER)
		local tc = g:GetFirst()
		while tc do
			if not tc:IsRace(RACE_MACHINE) then
				local atk = tc:GetAttack()
				if atk > 0 then
					local new_atk = math.max(0, atk - 200)
					Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
					tc:SetAttack(new_atk)
				end
			end
			tc = g:GetNext()
		end
	elseif opt == 2 then
		-- 禁止发动效果
		local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
		local tc = g:GetFirst()
		while tc do
			if tc:GetAttack() > Duel.GetLP(tp) then
				local e1 = Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetTargetRange(LOCATION_MZONE, 0)
				e1:SetTarget(function(e, c) return c:IsFaceup() end)
				e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
				Duel.RegisterEffect(e1, tp)
			end
			tc = g:GetNext()
		end
	elseif opt == 3 then
		-- 特殊召唤怪兽
		local g = Duel.SelectMatchingCard(tp, function(c) return c:IsSetCard(0x93) and c:IsAbleToSpecialSummon() end, tp, LOCATION_GRAVE, 0, 1, 1, nil)
		if #g > 0 then
			Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
		end
	end
end
