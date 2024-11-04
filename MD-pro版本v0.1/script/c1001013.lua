-- 黑魔导之魂
-- 连接怪兽
function c1001013.initial_effect(c)
	-- 连接召唤
	aux.AddLinkProcedure(c, c1001013.mfilter, 1, 1)
	c:EnableReviveLimit()

	-- 效果1：从卡组选1张「魔术师的救出」加入手卡或者送去墓地
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001013, 0))
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c1001013.target)
	e1:SetOperation(c1001013.operation)
	e1:SetCountLimit(1,1001013)
	c:RegisterEffect(e1)

	-- 效果2：通常魔法·陷阱卡不送去墓地，直接除外
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1, 0)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)

	-- 效果3：解放这张卡从手卡·卡组特殊召唤1只「黑魔术师」
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1001013, 1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c1001013.spcost)
	e3:SetTarget(c1001013.sptg)
	e3:SetOperation(c1001013.spop)
	e3:SetCountLimit(1,1001013+1000000)
	c:RegisterEffect(e3)
end

function c1001013.mfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(3)
end

-- 效果1：选择「魔术师的救出」
function c1001013.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1, nil, 95477924) end -- 魔术师的救出
end

function c1001013.operation(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_DECK, 0, 1, 1, nil, 95477924) -- 选择1张「魔术师的救出」
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT) -- 加入手卡
		Duel.ConfirmCards(1-tp, g) -- 确认
	end
end

-- 效果3：解放这张卡特殊召唤「黑魔术师」
function c1001013.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST) -- 解放这张卡
end

function c1001013.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, 46986414) end -- 黑魔术师
end

function c1001013.spop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, 46986414) -- 选择1只「黑魔术师」
	if #g > 0 then
		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP) -- 特殊召唤
	end
end

