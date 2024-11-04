-- 电子龙·零
function c1001003.initial_effect(c)
	-- 超量召唤
	aux.AddXyzProcedure(c, c1001003.mfilter, 4, 2, c1001003.ovfilter, aux.Stringid(1001003, 0), 2, c1001003.xyzop)
	c:EnableReviveLimit()
	
	-- 效果1：无效发动
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001003, 0))
	e1:SetCategory(CATEGORY_NEGATE + CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, 1001003)
	e1:SetCondition(c1001003.negcon)
	e1:SetCost(c1001003.detachcost)
	e1:SetTarget(c1001003.distg)
	e1:SetOperation(c1001003.negop)
	c:RegisterEffect(e1)

	-- 效果2：复制效果
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001003, 1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, 1001004)
	e2:SetTarget(c1001003.eqtg)
	e2:SetOperation(c1001003.eqop)
	c:RegisterEffect(e2)
end

function c1001003.mfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end

function c1001003.ovfilter(c)
	return c:IsFaceup() and c:IsCode(58069384)
end

-- 效果1：无效发动条件
function c1001003.negcon(e, tp, eg, ep, ev, re, r, rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function c1001003.detachcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():GetOverlayCount() > 0 end
	e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST) -- 取除1个超量素材
end

function c1001003.distg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end

function c1001003.negop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.NegateActivation(ev) then
		-- 选择卡组中的一张龙族或机械族怪兽
		local g = Duel.GetMatchingGroup(function(c) return c:IsRace(RACE_DRAGON) or c:IsRace(RACE_MACHINE) end, tp, LOCATION_DECK, 0, nil)
		if #g > 0 then
			local tc = g:Select(tp, 1, 1, nil):GetFirst()
			if tc then
				Duel.Equip(tp, tc, c)

				-- 设置装备限制
				local e1 = Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT + RESETS_STANDARD)
				e1:SetValue(function(e, c) return e:GetOwner() == c end)
				tc:RegisterEffect(e1)

				-- 只在装备后增加攻击力
				local e2 = Effect.CreateEffect(tc)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(800)
				e2:SetReset(RESET_EVENT + RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
end

-- 效果2：选择墓地机械族怪兽
function c1001003.eqfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGrave() -- 选择墓地机械族怪兽
end

function c1001003.eqtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(c1001003.eqfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
end

function c1001003.eqop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local g = Duel.SelectMatchingCard(tp, c1001003.eqfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		local tc = g:GetFirst()
		if Duel.SendtoGrave(tc, REASON_EFFECT) ~= 1 then return end
		
		-- 复制效果
		local code = tc:GetOriginalCode()
		local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1)

		-- 在结束阶段重置效果
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE + PHASE_END)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		e1:SetLabel(cid)
		e1:SetOperation(c1001003.rstop)
		c:RegisterEffect(e1)
	end
end

function c1001003.rstop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local cid = e:GetLabel()
	c:ResetEffect(cid, RESET_COPY)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end
