-- 电子龙X型
-- 电子龙·强化版
function c1001005.initial_effect(c)
	-- 作为「电子龙」使用
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(70095154) -- 电子龙的代码
	c:RegisterEffect(e0)

	-- 效果2：特殊召唤墓地的电子龙
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001005, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1, 1001005)
	e1:SetTarget(c1001005.sptg)
	e1:SetOperation(c1001005.spop)
	c:RegisterEffect(e1)

	-- 效果3：从手卡特殊召唤并改变等级
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001005, 1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1, 1001005)
	e2:SetCondition(c1001005.spcon)
	e2:SetOperation(c1001005.spop2)
	c:RegisterEffect(e2)
end

function c1001005.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsCode(70095154) end, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function c1001005.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(function(c) return c:IsCode(70095154) and c:IsAbleToGrave() end, tp, LOCATION_GRAVE, 0, 1, nil)
	end
end

function c1001005.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local g = Duel.SelectMatchingCard(tp, function(c) return c:IsCode(70095154) and c:IsAbleToGrave() end, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
		local summoned = Duel.SpecialSummon(g:GetFirst(), 0, tp, tp, false, false, POS_FACEUP)
		if summoned then
			-- 该怪兽不会被战斗·效果破坏
			local e1 = Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			e1:SetValue(1)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end

function c1001005.spop2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) ~= 0 then
		-- 全部电子龙的等级变成5星
		local g = Duel.GetMatchingGroup(function(c) return c:IsCode(70095154) end, tp, LOCATION_MZONE, 0, nil)
		for tc in aux.Next(g) do
			local e1 = Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(5)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end

		-- 这个回合自己不是机械族怪兽不能特殊召唤
		local e2 = Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetReset(RESET_PHASE + PHASE_END)
		e2:SetTargetRange(LOCATION_HAND + LOCATION_DECK, 0)
		e2:SetTarget(function(e, c) return not c:IsRace(RACE_MACHINE) end)
		Duel.RegisterEffect(e2, tp)
	end
end
