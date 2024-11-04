function c1001007.initial_effect(c)
	-- 作为「真红眼黑龙」使用
	aux.EnableChangeCode(c, 74677422, LOCATION_MZONE + LOCATION_GRAVE)

	-- 特殊召唤效果
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001007, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, 1001007)
	e1:SetCondition(c1001007.spcon1)
	e1:SetOperation(c1001007.spop1)
	c:RegisterEffect(e1)

	-- 解放效果
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001007, 1))
	e2:SetCategory(CATEGORY_RELEASE + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND + LOCATION_MZONE)
	e2:SetCountLimit(1, 1001007)
	e2:SetCost(c1001007.cost)
	e2:SetCondition(c1001007.negcon)
	e2:SetOperation(c1001007.negop)
	c:RegisterEffect(e2)

	-- 回合结束时特招效果
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE + PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1, 1001007 + 1)
	e3:SetCondition(c1001007.endphase_condition)
	e3:SetOperation(c1001007.endphase_operation)
	c:RegisterEffect(e3)
end

function c1001007.spcon1(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(function(c) return c:IsSetCard(0x3b) and c:IsControler(tp) end, 1, nil)
end

function c1001007.spop1(e, tp, eg, ep, ev, re, r, rp)
	Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end

function c1001007.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(), REASON_COST)
end

function c1001007.negfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3b) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end

function c1001007.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c1001007.negfilter, 1, nil, tp) and Duel.IsChainNegatable(ev)
end

function c1001007.negop(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
	local tc = g:Filter(c1001007.negfilter, nil, tp):GetFirst()
	if tc then
		-- 解放被选为效果对象的怪兽
		Duel.Release(tc, REASON_EFFECT)
		-- 注册标记以便在回合结束时特殊召唤
		e:GetHandler():RegisterFlagEffect(1001007, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
		-- 记录解放的怪兽
		tc:RegisterFlagEffect(1001008, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
	end
end

function c1001007.endphase_condition(e, tp, eg, ep, ev, re, r, rp)
	  return e:GetHandler():GetFlagEffect(1001007) > 0
end

function c1001007.endphase_operation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 or not c:IsRelateToEffect(e) then return end
	-- 特殊召唤被解放的怪兽
	local tc = Duel.GetFirstMatchingCard(function(c) return c:GetFlagEffect(1001008) > 0 end, tp, LOCATION_GRAVE, 1, nil)
	if tc then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
		tc:ResetFlagEffect(1001008) -- 重置标记
	end
end


