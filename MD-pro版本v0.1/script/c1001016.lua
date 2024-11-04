--连魔导师-五阵魔导2
-- 连魔导师-五阵魔术师
-- 魔法师连接怪兽
function c1001016.initial_effect(c)
	-- 连接召唤
	aux.AddLinkProcedure(c, nil, 3, 99, c1001016.lcheck)
	c:EnableReviveLimit()

	-- 额外连接素材
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(0, LOCATION_MZONE)
	e1:SetValue(c1001016.matval)
	c:RegisterEffect(e1)
--atk up
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c1001016.atkval)
	c:RegisterEffect(e2)
--canot Release
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)

	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetCondition(c1001016.effcon)
	e4:SetValue(1)
	e4:SetLabel(1)
	c:RegisterEffect(e4)


	local e5 = Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetTargetRange(LOCATION_SZONE, 0) -- 适用于自己的魔陷区
	e5:SetCondition(c1001016.effcon)
	e5:SetValue(c1001016.efilter)
	e5:SetLabel(2)
	Duel.RegisterEffect(e5, tp) -- tp是当前控制者

	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	   --  e3:SetReset(RESET_EVENT)
	e6:SetTarget(c1001016.distg)
	e6:SetCondition(c1001016.effcon)
	e6:SetLabel(3)
	c:RegisterEffect(e6)

	local e7 = Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetValue(c1001016.efilter)
	e7:SetCondition(c1001016.effcon)
	e7:SetLabel(4)
	c:RegisterEffect(e7)

	-- 效果2：回合结束时发动
	local e8 = Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(1001016, 1))
	e8:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE + PHASE_END)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(c1001016.destroy_condition)
	e8:SetTarget(c1001016.dtg)
	e8:SetOperation(c1001016.destroy_operation)
	c:RegisterEffect(e8)
 -- 
	

end

function c1001016.lcheck(g, lc)
	return g:IsExists(Card.IsLinkRace, 1, nil, RACE_SPELLCASTER)  -- 包含魔法师族怪兽
end

function c1001016.matval(e, lc, mg, c, tp)
	if e:GetHandler()~=lc then return false,nil end
	return true,not mg or not mg:IsExists(Card.IsControler,1,nil,1-tp)
end



function c1001016.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroupCount()>=e:GetLabel()
end

function c1001016.distg(e,c)
	return c:IsType(TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
function c1001016.efilter(c,e,tp)
	return re:GetOwnerPlayer() ~= e:GetHandlerPlayer()
end
function c1001016.dfilter(c,e,tp)
	return  c:IsLinkState()  and c:IsType(TYPE_MONSTER)
end

function c1001016.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
function c1001016.destroy_condition(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetLinkedGroupCount() >= 5
end

function c1001016.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lg=Duel.GetMatchingGroup(c1001016.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,lg,lg:GetCount(),0,0)
end

function c1001016.destroy_operation(e, tp, eg, ep, ev, re, r, rp)
	local lg=Duel.GetMatchingGroup(c1001016.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Destroy(lg, REASON_EFFECT)
end
