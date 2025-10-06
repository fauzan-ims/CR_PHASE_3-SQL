CREATE PROCEDURE dbo.xsp_rpt_ext_depre_mature_contract_insert
AS
BEGIN
    DECLARE @code NVARCHAR(50),
            @year NVARCHAR(4),
            @month NVARCHAR(2),
            @msg NVARCHAR(MAX),
            @p_cre_date DATETIME  = EOMONTH(DATEADD(MONTH, -1, dbo.xfn_get_system_date())),--'2024-07-31',
            @p_cre_by NVARCHAR(15) = 'JOB',
            @p_cre_ip_address NVARCHAR(15) = N'JOB';

    BEGIN TRY
	/*
		MATURE

	jadwal depresiasi dari berakhirnya kontrak sd jadwal depresiasi berakhir
	*/
        delete dbo.rpt_ext_depre_mature_contract -- data selalu di cleanup


        insert into rpt_ext_depre_mature_contract
        (
            agreement_id,
            end_contract_month,
            depreciation_month,
            total_unit,
            net_investment,
            depr_exp_strightline,
            depr_accum_strightline,
            sequence,
            asset_model,
            asset_brand,
            asset_brand_type,
            asset_brand_type_name,
            asset_type,
            asset_condition,
            as_of,
            create_date,
            create_time,
            --
            cre_date,
            cre_by,
            cre_ip_address,
            mod_date,
            mod_by,
            mod_ip_address
        )
        select ass.agreement_external_no,
               left( convert(varchar, ai.maturity_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
               left( convert(varchar, adsc.depreciation_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
               COUNT(1),  
               SUM(ass.purchase_price),
               SUM(isnull(adsc.depreciation_amount,0)),
               SUM(isnull(adsc.accum_depre_amount,0)),
			   rpt.sequence,
               right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),--ass.model_code,
               ass.merk_code,
               left(ass.model_name,50), --ambil nama item
               ass.model_name,-- ambil nama item
               case ass.type_code WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end, -- 1 vehicle, 2 he , else NA
               ass.condition,
               @p_cre_date,
               @p_cre_date,
               cast(GETDATE() as time),
               --
               @p_cre_date,
               @p_cre_by,
               @p_cre_ip_address,
               @p_cre_date,
               @p_cre_by,
               @p_cre_ip_address
         FROM dbo.XXX_ASSET_AFTER_EOM_20250731 ass
			inner join ifinopl.dbo.XXX_AGREEMENT_ASSET_AFTER_EOM_20250731 aa on aa.fa_code = ass.code and aa.agreement_no = ass.agreement_no AND aa.ASSET_STATUS ='RENTED'
			INNER JOIN IFINOPL.dbo.XXX_AGREEMENT_MAIN_AFTER_EOM_20250731 am ON am.AGREEMENT_NO = aa.AGREEMENT_NO
			inner join	ifinopl.dbo.rpt_ext_agreement_main ram on ass.agreement_external_no = ram.agreement_id
			left join ifinopl.dbo.agreement_information ai on ai.agreement_no = aa.agreement_no
			inner join dbo.XXX_ASSET_DEPRECIATION_SCHEDULE_COMMERCIAL_AFTER_EOM_20250731 adsc on adsc.asset_code = ass.code AND convert(varchar(6), adsc.DEPRECIATION_DATE , 112) >=  convert(varchar(6), ai.MATURITY_DATE , 112)  
			inner join dbo.asset_vehicle av on av.asset_code = ass.code
			outer apply (
						SELECT TOP 1 rpt.sequence
						from ifinopl.dbo.rpt_ext_agreement_main rpt
						where rpt.agreement_id = ass.agreement_external_no
			) rpt
			where am.AGREEMENT_STATUS = 'GO LIVE'
			--and		ass.PURCHASE_DATE							  <= @p_cre_date
			--		and (
			--				ass.SALE_DATE is null
			--				or ass.SALE_DATE					  > @p_cre_date
			--			)
			--		and (
			--				ass.DISPOSAL_DATE is null
			--				or ass.DISPOSAL_DATE				  > @p_cre_date
			--			)
			--		and ass.STATUS not in
			--			(
			--				'CANCEL', 'hold','RETURNED','SOLD'
			--			)
			--		and (
			--				ass.PERMIT_SELL_DATE is null
			--				or cast(ass.PERMIT_SELL_DATE as date) > @p_cre_date
			--			)
			and	ASSET_FROM								 = 'BUY'
				and isnull(IS_PERMIT_TO_SELL, '0')		 = '0'
				and STATUS in
		(
			'STOCK', 'REPLACEMENT'
		)
				and convert(char(6), PURCHASE_DATE, 112) <= convert(char(6), @p_cre_date, 112) 
				AND convert(char(6), ass.CRE_DATE, 112) <= convert(char(6), @p_cre_date, 112)
					and ass.CODE not in
						(
							'1000.MIG.0001.0019', '2001.AST.2312.00001', '2008.AST.2312.00004', '2010.AST.2312.00001', '2010.AST.2312.00002'
						)
			and convert(varchar(6), adsc.DEPRECIATION_DATE , 112) >  convert(varchar(6), @p_cre_date , 112)  

			GROUP BY 
				ass.agreement_external_no,
               left( convert(varchar, ai.maturity_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
               left( convert(varchar, adsc.depreciation_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
			   rpt.sequence,
               right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),--ass.model_code,
               ass.merk_code,
               left(ass.model_name,50), --ambil nama item
               ass.model_name,-- ambil nama item
               case ass.type_code WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end, -- 1 vehicle, 2 he , else NA
               ass.condition

			   UPDATE	dbo.RPT_EXT_DEPRE_MATURE_CONTRACT
				SET		ASSET_MODEL = 'XCN5PT'
				WHERE	ASSET_MODEL = 'N5PT'	
				
				UPDATE dbo.RPT_EXT_DEPRE_MATURE_CONTRACT
				SET ASSET_MODEL = 'HSC24D'
				WHERE ASSET_MODEL = 'C24D'
				
				UPDATE dbo.RPT_EXT_DEPRE_MATURE_CONTRACT
				SET ASSET_MODEL = 'HSCD4M'
				WHERE ASSET_MODEL = 'CD4M'	
		--begin
		--print ' query old'
		 --   select ass.agreement_external_no,
   --            left( convert(varchar, ai.maturity_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
   --            left( convert(varchar, adsc.depreciation_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
   --            COUNT(1),  
   --            SUM(ass.purchase_price),
   --            SUM(adsc.depreciation_amount),
   --            SUM(adsc.accum_depre_amount),
			--   rpt.sequence,
   --            right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),--ass.model_code,
   --            ass.merk_code,
   --            left(ass.model_name,50), --ambil nama item
   --            ass.model_name,-- ambil nama item
   --            case ass.type_code WHEN 'VHCL' THEN '1'
			--		WHEN 'HE' THEN '2'
			--		ELSE 'NA'
			--	end, -- 1 vehicle, 2 he , else NA
   --            ass.condition,
   --            @p_cre_date,
   --            @p_cre_date,
   --            cast(GETDATE() as time),
   --            --
   --            @p_cre_date,
   --            @p_cre_by,
   --            @p_cre_ip_address,
   --            @p_cre_date,
   --            @p_cre_by,
   --            @p_cre_ip_address
   --      FROM dbo.asset ass
			--inner join ifinopl.dbo.agreement_asset aa on aa.fa_code = ass.code and aa.agreement_no = ass.agreement_no AND aa.ASSET_STATUS ='RENTED'
			--INNER JOIN IFINOPL.dbo.AGREEMENT_MAIN am ON am.AGREEMENT_NO = aa.AGREEMENT_NO
			--left join ifinopl.dbo.agreement_information ai on ai.agreement_no = aa.agreement_no
			--left join dbo.asset_depreciation_schedule_commercial adsc on adsc.asset_code = ass.code AND convert(varchar(6), adsc.DEPRECIATION_DATE , 112) >=  convert(varchar(6), ai.MATURITY_DATE , 112)  
			--inner join dbo.asset_vehicle av on av.asset_code = ass.code
			--outer apply (
			--			SELECT TOP 1 rpt.sequence
			--			from ifinopl.dbo.rpt_ext_agreement_main rpt
			--			where rpt.agreement_id = ass.agreement_external_no
			--) rpt
			--where 
			----CONVERT(varchar(6), adsc.DEPRECIATION_DATE , 112) >=  convert(varchar(6), ai.MATURITY_DATE , 112)  
			----AND
			-- am.AGREEMENT_STATUS = 'GO LIVE'
			--AND ass.STATUS IN
			--				(
			--				N'REPLACEMENT',
			--				N'STOCK'
			--			)
			--GROUP BY 
			--	ass.agreement_external_no,
   --            left( convert(varchar, ai.maturity_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
   --            left( convert(varchar, adsc.depreciation_date, 23),7), --CONVERT(nvarchar(4), year(ai.maturity_date)) + '-' + '0'+convert(nvarchar(2),month(ai.maturity_date)),
			--   rpt.sequence,
   --            right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),--ass.model_code,
   --            ass.merk_code,
   --            left(ass.model_name,50), --ambil nama item
   --            ass.model_name,-- ambil nama item
   --            case ass.type_code WHEN 'VHCL' THEN '1'
			--		WHEN 'HE' THEN '2'
			--		ELSE 'NA'
			--	end, -- 1 vehicle, 2 he , else NA
   --            ass.condition

		--end
    --select	ass.agreement_no													
    --		,commercial.depreciation_date										
    --		,convert(nvarchar(7), commercial.depreciation_date, 127) 															
    --		,1																
    --		,ass.purchase_price												
    --		,adsc.depreciation_amount										
    --		,adsc.accum_depre_amount										
    --		,ass.code														
    --		,avh.model_code													
    --		,avh.merk_code													
    --		,avh.type_item_code												
    --		,avh.type_item_name
    --		,ass.type_code
    --		,ass.last_so_condition
    --		,ass.purchase_date
    --		,ass.cre_date
    --		,convert(varchar(8), ass.cre_date, 108)
    --		--
    --		,@p_cre_date
    --		,@p_cre_by
    --		,@p_cre_ip_address
    --		,@p_cre_date
    --		,@p_cre_by
    --		,@p_cre_ip_address
    --from	dbo.asset_depreciation_schedule_commercial adsc
    --		inner join dbo.asset					   ass on (ass.code = adsc.asset_code)
    --		inner join dbo.asset_vehicle			   avh on (avh.asset_code = ass.code)
    --		outer apply
    --(
    --	select	max(depreciation_date) 'depreciation_date'
    --	from	dbo.asset_depreciation_schedule_commercial adsc2
    --	where	adsc2.asset_code = ass.code
    --)												   commercial
    --where	isnull(ass.agreement_no, '') <> ''
    --		and adsc.id in
    --			(
    --				select		max(id)
    --				from		dbo.asset_depreciation_schedule_commercial adsc
    --				where		adsc.transaction_code <> ''
    --				group by	adsc.asset_code
    --			) 

    END TRY
    BEGIN CATCH
        DECLARE @error INT;

        SET @error = @@error;

        IF (@error = 2627)
        BEGIN
            SET @msg = dbo.xfn_get_msg_err_code_already_exist();
        END;

        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'v' + N';' + @msg;
        END;
        ELSE
        BEGIN
            IF (ERROR_MESSAGE() LIKE '%v;%' OR ERROR_MESSAGE() LIKE '%e;%')
            BEGIN
                SET @msg = ERROR_MESSAGE();
            END;
            ELSE
            BEGIN
                SET @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + ERROR_MESSAGE();
            END;
        END;

        RAISERROR(@msg, 16, -1);

        RETURN;
    END CATCH;
END;
