-- 电子龙
function c1001001.initial_effect(c)
	-- 召唤手续
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),1,1,c1001001.lcheck)
	-- 添加手牌效果
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1001001, 0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, 1001001 + EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c1001001.thcost)
	e1:SetTarget(c1001001.thtg)
	e1:SetOperation(c1001001.thop)
	c:RegisterEffect(e1)

	-- 融合素材效果
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1001001, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, 1001001 + 1)
	e2:SetCondition(c1001001.fusioncon)
	e2:SetTarget(c1001001.fusiontg)
	e2:SetOperation(c1001001.fusionop)
	c:RegisterEffect(e2)

	-- 从卡组加入一张电子龙
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1001001, 2))
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1, 1001001 + 2)
	e3:SetTarget(c1001001.thtg2)
	e3:SetOperation(c1001001.thop2)
	c:RegisterEffect(e3)
end
function c1001001.lcheck(g,lc)
	return g:IsExists(Card.IsLinkCode,1,nil,70095154)
end
-- 添加手牌成本
function c1001001.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- 搜索电子融合支援
function c1001001.thfilter(c)
	return c:IsCode(58199906) and c:IsAbleToHand() 
end
function c1001001.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1001001.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function c1001001.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectMatchingCard(tp,c1001001.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- 融合素材效果
function c1001001.fusioncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_FUSION)
end

function c1001001.fufilter(c)
	return c:IsSetCard(0x46) and c:IsAbleToHand()  
end

function c1001001.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(c1001001.fufilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function c1001001.fusionop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g = Duel.SelectMatchingCard(tp,c1001001.fufilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount() > 0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- 从卡组加入电子龙
function c1001001.thfilter2(c)
	return c:IsCode(70095154) and c:IsAbleToHand()  -- 假设电子龙的系列代码是0x209
end

function c1001001.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1001001.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function c1001001.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectMatchingCard(tp,c1001001.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

