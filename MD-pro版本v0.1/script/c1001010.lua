--真红眼魔剑士
-- 真红眼魔剑士
function c1001010.initial_effect(c)
	-- 特殊召唤效果
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001010, 0))
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, 1001010)
	e1:SetCondition(c1001010.spcon)
	e1:SetOperation(c1001010.spop)
	c:RegisterEffect(e1)

	-- 当作「黑魔术师」使用的效果
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001010, 1))
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1, 1001010 + 1)
	e2:SetOperation(c1001010.setop)
	c:RegisterEffect(e2)

	local e3 = e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

function c1001010.spcon(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(function(c) return c:IsSetCard(0x3b) end, 1, nil) -- 判断场上是否有「真红眼」怪兽
end

function c1001010.spop(e, tp, eg, ep, ev, re, r, rp)
	Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end

function c1001010.setop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()

	-- 提升等级
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(2) -- 提升2级
	e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
	c:RegisterEffect(e1)

	-- 设置这张卡的名称为「黑魔术师」
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetValue(46986414) -- 黑魔术师的卡片编号
	e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
	c:RegisterEffect(e2)
end
