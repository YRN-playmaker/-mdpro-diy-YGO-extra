function c1001015.initial_effect(c)
	aux.AddCodeList(c,46986414)
	-- 激活效果 (e1)
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c1001015.rmcon)
	e1:SetTarget(c1001015.rmtg)
	e1:SetOperation(c1001015.rmop)
	c:RegisterEffect(e1)

	-- 禁用区域效果 (e2)
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001015, 0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, 1001015 + 1)
	e2:SetCost(c1001015.thcost)
	e2:SetTarget(c1001015.thtg)
	e2:SetOperation(c1001015.thop)
	e2:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e2)
end

function c1001015.rmcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE, 0, 1, nil, 46986414) -- 判断自己场上有黑魔术师
end

function c1001015.rmtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingTarget(Card.IsType, tp, 0, LOCATION_MZONE, 1, nil, TYPE_MONSTER) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectTarget(tp, Card.IsType, tp, 0, LOCATION_MZONE, 1, 1, nil, TYPE_MONSTER)
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0) -- 指定目标
end

function c1001015.rmop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) -- 除外目标怪兽
	end
end

function c1001015.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST) -- 除外自己在墓地的这张卡
end



function c1001015.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 end -- 检查对方是否有未使用的主要怪兽区域
	local dis = 0

	-- 选择一个对方的主要怪兽区域
	dis = Duel.SelectField(tp, 1, 0, LOCATION_MZONE, 0x60 << 16)

	e:SetLabel(dis) -- 存储选择的区域
	Duel.Hint(HINT_ZONE, tp, dis)
end

function c1001015.thop(e, tp, eg, ep, ev, re, r, rp)
	local dis = e:GetLabel()
	local g = Duel.GetFieldGroup(1 - tp, LOCATION_MZONE, 0)
	local tc = g:GetFirst()

	if tc and tc:IsFaceup() then
		local e0 = Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e0:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		tc:RegisterEffect(e0)

		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		tc:RegisterEffect(e1)
	else
		-- 没有怪兽存在的场合，禁用该区域
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
		local e2 = Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE_FIELD)
		e2:SetValue(dis)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		Duel.RegisterEffect(e2, tp)
	end
end


