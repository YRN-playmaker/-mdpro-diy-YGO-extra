function c1001002.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCodeRep(c, 70095154, 3, false, false)

	-- 融合召唤成功时支付基本分并禁止对方发动效果
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001002, 0))
	e1:SetCategory(0)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1, 1001002 + 1)
	e1:SetCost(c1001002.lpcost)
	e1:SetOperation(c1001002.lpoperation)
	c:RegisterEffect(e1)

	-- 攻击力变为墓地怪兽数量×300
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(c1001002.atkval)
	c:RegisterEffect(e2)

	-- 特殊效果
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1001002, 1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(c1001002.battledcon)
	e3:SetOperation(c1001002.battledop)
	c:RegisterEffect(e3)

	-- 额外攻击效果
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1001002, 2))
	e4:SetCategory(CATEGORY_ATTACK)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c1001002.atkcon)
	e4:SetOperation(c1001002.atkop)
	c:RegisterEffect(e4)
end

function c1001002.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp) > 100 end  -- 检查基本分是否大于100
	Duel.SetLP(tp, 100)						  -- 直接将生命值设置为100
end

function c1001002.lpoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 禁止对方发动效果直到战斗阶段结束
	local c = e:GetHandler()
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0, 1)
	e2:SetValue(1) -- 1表示禁止发动
	e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE) -- 战斗阶段结束时失效
	c:RegisterEffect(e2)
	
end

function c1001002.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsMonster, c:GetControler(), LOCATION_GRAVE, 0, nil) * 300
end

function c1001002.battledcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttack() >= 2000 and Duel.GetAttacker():IsControler(tp) and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsDefensePos()
end

function c1001002.battledop(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetAttackTarget()
	if tc and tc:IsDefensePos() then
		local damage = e:GetHandler():GetAttack() - tc:GetDefense()
		if damage > 0 then
			Duel.Damage(1-tp, damage, REASON_EFFECT)
		end
	end
end

function c1001002.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttack() >= 3000 and Duel.GetAttacker() == e:GetHandler() and Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 1
end

function c1001002.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.SelectMatchingCard(tp, aux.FilterBoolFunction(Card.IsSetCard, 0x93), tp, LOCATION_EXTRA, 0, 1, 1, nil) -- 使用系列代码0x93
	if #g > 0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
		e:GetHandler():RegisterFlagEffect(1001002, RESET_EVENT + RESETS_STANDARD, 0, 1)
		Duel.ChainAttack()
	end
end

