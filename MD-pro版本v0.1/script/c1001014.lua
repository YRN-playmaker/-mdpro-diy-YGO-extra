-- 魔术师弟子之杖
function c1001014.initial_effect(c)
	aux.AddCodeList(c,46986414)
	-- 效果1：选1只「黑魔术师」或者「黑魔术少女」从卡组送入墓地
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001014, 0))
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c1001014.target)
	e1:SetOperation(c1001014.operation)
	e1:SetCountLimit(1, 1001014)
	c:RegisterEffect(e1)

	-- 效果2：除外自己在墓地的这张卡，加入1只[魔术师双魂]到手卡
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001014, 1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, 1001014 + 1)
	e2:SetCondition(c1001014.thcon)  -- 添加条件限制
	e2:SetCost(c1001014.thcost)
	e2:SetTarget(c1001014.thtg)
	e2:SetOperation(c1001014.thop)
	e2:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e2)
end

function c1001014.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then 
		return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1, nil, 46986414) or 
			   Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1, nil, 38033121) 
	end -- 黑魔术师或者黑魔术少女
end

function c1001014.operation(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.SelectMatchingCard(tp, function(c) return c:IsCode(46986414) or c:IsCode(38033121) end, tp, LOCATION_DECK, 0, 1, 1, nil) -- 选择1只
	if #g > 0 then
		Duel.SendtoGrave(g, REASON_EFFECT) -- 送入墓地
	end
end

function c1001014.thcon(e, tp, eg, ep, ev, re, r, rp)
	-- 条件：自己场上有魔法或陷阱卡
	return Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_ONFIELD, 0, 1, nil, TYPE_SPELL + TYPE_TRAP)and 
		   Duel.IsExistingMatchingCard(Card.IsPosition, tp, LOCATION_SZONE, 0, 1, nil, POS_FACEUP)
end

function c1001014.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST) -- 除外自己在墓地的这张卡
end

function c1001014.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1, nil, 97631303) end -- [魔术师双魂]
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK) -- 目标设定
end

function c1001014.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_DECK, 0, 1, 1, nil, 97631303) -- 选择1只[魔术师双魂]
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT) -- 加入手卡
		Duel.ConfirmCards(1 - tp, g) -- 确认
	end
end


