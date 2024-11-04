function c1001006.initial_effect(c)
	-- 融合材料 
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c, 71625222, 74677422, true, true) -- 时间魔术师和真红眼黑龙

	-- 效果1：投掷硬币
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001006, 0))
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1, 1001006)
	e1:SetTarget(c1001006.totarget)
	e1:SetOperation(c1001006.tooperation)
	c:RegisterEffect(e1)

	 local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001006, 1))
	e2:SetCategory(CATEGORY_TOHAND) -- 设置类别为可以选择的效果
	e2:SetType(EFFECT_TYPE_IGNITION) -- 启动效果
	e2:SetRange(LOCATION_GRAVE) -- 可以在墓地发动
	e2:SetCountLimit(1, 1001006 + 1)
	e2:SetCost(c1001006.cost)
	e2:SetTarget(c1001006.setarget)
	e2:SetOperation(c1001006.seoperation)
	c:RegisterEffect(e2)
end
c1001006.material_setcode=0x3b
function c1001006.totarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
end

function c1001006.tooperation(e, tp, eg, ep, ev, re, r, rp)
	local coin = Duel.TossCoin(tp, 1)
	if coin == 1 then
		-- 猜中，返回对方场上的所有怪兽到持有者卡组
	   local g = Duel.GetFieldGroup(1 - tp, LOCATION_MZONE, 0) -- 只获取对方的怪兽
		Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)
	else
		-- 猜错，放置「凡骨之意志」为里侧表示
		local token = Duel.CreateToken(tp, 1001009)
		Duel.MoveToField(token, tp, tp, LOCATION_SZONE, POS_FACEDOWN , true)
		-- 结束自己的回合
		Duel.SkipPhase(tp, PHASE_MAIN1, RESET_PHASE + PHASE_END, 1) -- 跳过自己的主要阶段1
		Duel.SkipPhase(tp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1) -- 跳过战斗阶段
		Duel.SkipPhase(tp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1) -- 跳过自己的主要阶段2
		-- 对方的回合从主要阶段1开始
		Duel.SkipPhase(1 - tp, PHASE_STANDBY, RESET_PHASE + PHASE_END, 1)
		Duel.SkipPhase(1 - tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 1)
	end
end


function c1001006.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST) -- 将这张卡本身除外作为费用
end
function c1001006.setarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(function(c) 
			return c:IsAbleToHand() and c:IsSetCard(0x3b) and c:IsSetCard(0x46) and c:IsType(TYPE_SPELL + TYPE_TRAP) 
		end, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) -- 真红眼字段
	end
end

function c1001006.seoperation(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.SelectMatchingCard(tp, function(c) 
		return c:IsAbleToHand() and c:IsSetCard(0x3b) and c:IsSetCard(0x46) and c:IsType(TYPE_SPELL + TYPE_TRAP) 
	end, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
	end
end


