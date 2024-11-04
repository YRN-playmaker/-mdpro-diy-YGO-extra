function c1001000.initial_effect(c) 
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1001000+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c1001000.cost)
	e1:SetTarget(c1001000.target)
	e1:SetOperation(c1001000.activate)
	c:RegisterEffect(e1)
end

function c1001000.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c1001000.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function c1001000.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	if sumtype==SUMMON_TYPE_FUSION then
		return not c:IsRace(RACE_MACHINE)  -- 限制只能召唤机械族
	else
		return false  -- 其他召唤类型不允许
	end
end

function c1001000.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end

function c1001000.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end

function c1001000.filter2(c,e,tp,m,f,chkf)
	if not c:IsType(TYPE_FUSION) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) then return false end
	aux.FCheckAdditional=c1001000.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	aux.FCheckAdditional=nil
	return res
end

function c1001000.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0x1093)
end

function c1001000.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local mg2=Duel.GetMatchingGroup(c1001000.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
		mg1:Merge(mg2)
		local res=Duel.IsExistingMatchingCard(c1001000.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c1001000.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c1001000.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c1001000.filter1,nil,e)
	local mg2=Duel.GetMatchingGroup(c1001000.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	mg1:Merge(mg2)

	-- 找到可以召唤的融合怪兽
	local sg1=Duel.GetMatchingGroup(c1001000.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)

	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c1001000.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end

	if sg1:GetCount()>0 or (sg2 and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()

		aux.FCheckAdditional=c1001000.fcheck
		
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=nil
			repeat
				-- 选择融合素材，最多5只
				mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				if mat1:GetCount() > 5 then
					Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(1001000,1))  -- 提示超过数量限制
				end
			until mat1:GetCount() <= 5
			
			tc:SetMaterial(mat1)  -- 添加这一行
			Duel.Remove(mat1,POS_FACEDOWN,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()

			-- 确保完成融合程序
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()  -- 确认融合完成，触发相关效果
		else
			-- 使用链材融合
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
	end
	
	aux.FCheckAdditional=nil
end


