CREATE PROCEDURE dbo.xsp_rpt_ext_expense_insert
as
	begin
		declare @msg			   nvarchar(max)
				--,@p_cre_date	   datetime		= '2023-12-31'
				,@p_cre_date	   datetime = dbo.xfn_get_system_date()
				,@p_cre_by		   nvarchar(15) = N'JOB'
				,@p_cre_ip_address nvarchar(15) = N'JOB'
				,@system_date	   datetime = dbo.xfn_get_system_date()

		if(@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
		begin
			set @p_cre_date = dateadd(month, -1, @p_cre_date)
			set @p_cre_date = eomonth(@p_cre_date)
		END
        
		begin try
			delete RPT_EXT_EXPENSE;

			--where month(eom) = month(@p_cre_date)
			--      and year(eom) = year(@p_cre_date);
			insert into RPT_EXT_EXPENSE
				(
					EOM
					,ASSETNO
					,AMT
					,ASSETCONDITIONID
					,ASSETTYPEID
					,ASSETBRANDID
					,ASSETBRANDTYPEID
					,ASSETBRANDTYPENAME
					,ASSETMODELID
				    ---- raffy (+) 2025/08/06 imon 2508000017
					,fa_code
					,registration_class_type
					,asset_name
							--
					--
					,CRE_DATE
					,CRE_BY
					,CRE_IP_ADDRESS
					,MOD_DATE
					,MOD_BY
					,MOD_IP_ADDRESS
				)
			select	   eomonth(@p_cre_date)
					   ,ad.ASSET_CODE
					   ,isnull(ad.DEPRECIATION_COMMERCIAL_AMOUNT, 0)
					   ,ast.CONDITION
					   ,case ast.TYPE_CODE
							when 'VHCL' then '1'
							when 'HE' then '2'
							else 'NA'
						end -- 1 vehicle, 2 he , else NA
					   ,ast.MERK_CODE
					   ,ast.TYPE_CODE_ASSET
					   ,ast.TYPE_NAME_ASSET
					   ,right(av.TYPE_ITEM_CODE, len(av.TYPE_ITEM_CODE) - 1 - len(av.MODEL_CODE))
					   ,ast.CODE
					   ,mi.REGISTRATION_CLASS_TYPE
					   ,ast.ITEM_NAME
					   --,@p_cre_date
					   ,@system_date
					   ,@p_cre_by
					   ,@p_cre_ip_address
					   --,@p_cre_date
					   ,@system_date
					   ,@p_cre_by
					   ,@p_cre_ip_address
			from	   dbo.ASSET_DEPRECIATION ad
			inner join ASSET				  ast on ad.ASSET_CODE = ast.CODE
			inner join dbo.ASSET_VEHICLE	  av on av.ASSET_CODE  = ast.CODE
			inner join ifinbam.dbo.master_item mi on mi.code = av.type_item_code
			where	   convert(nvarchar(6), ad.DEPRECIATION_DATE, 112) = convert(nvarchar(6), @p_cre_date, 112);

			insert into rpt_ext_expense
				(
					eom
					,assetno
					,amt
					,assetconditionid
					,assettypeid
					,assetbrandid
					,assetbrandtypeid
					,assetbrandtypename
					,assetmodelid
					---- raffy (+) 2025/08/06 imon 2508000017
					,fa_code
					,registration_class_type
					,asset_name
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
			select	   eomonth(@p_cre_date)
					   ,ad.asset_code
					   ,isnull(ad.expense_amount, 0)
					   ,ast.condition
					   ,case ast.type_code
							when 'VHCL' then '1'
							when 'HE' then '2'
							else 'NA'
						end -- 1 vehicle, 2 he , else NA
					   ,ast.MERK_CODE
					   ,ast.TYPE_CODE_ASSET
					   ,ast.TYPE_NAME_ASSET
					   ,right(av.TYPE_ITEM_CODE, len(av.TYPE_ITEM_CODE) - 1 - len(av.MODEL_CODE))
					   ,ast.CODE
					   ,mi.REGISTRATION_CLASS_TYPE
					   ,ast.ITEM_NAME
							--
					   ,@p_cre_date
					   ,@p_cre_by
					   ,@p_cre_ip_address
					   ,@p_cre_date
					   ,@p_cre_by
					   ,@p_cre_ip_address
			from	   dbo.asset_expense_ledger ad
			inner join asset					ast on ad.asset_code = ast.code
			inner join dbo.asset_vehicle		av on av.asset_code	 = ast.code
			inner join ifinbam.dbo.master_item mi on mi.code = av.type_item_code
			where	   convert(nvarchar(6), ad.date, 112) = convert(nvarchar(6), @p_cre_date, 112)

		--    select EOMONTH(@p_cre_date),
		--           ISNULL(am.agreement_external_no, ISNULL(jd.agreement_no, jrn.JOURNAL_REFF_NO)),
		--           jd.orig_amount_db - jd.orig_amount_cr,
		--             am.asset_condition,
		--case am.asset_type_code WHEN 'VHCL' THEN '1'
		--	WHEN 'HE' THEN '2'
		--	ELSE 'NA'
		--END, -- 1 vehicle, 2 he , else NA
		--am.merk_code,
		--am.vehicle_type_code,
		--am.asset_name,
		--am.model_code,
		--           --
		--           @p_cre_date,
		--           @p_cre_by,
		--           @p_cre_ip_address,
		--           @p_cre_date,
		--           @p_cre_by,
		--           @p_cre_ip_address
		--    from ifinacc.dbo.journal_detail jd
		--        inner join ifinacc.dbo.journal jrn
		--            on (jrn.code = jd.journal_code)
		--       outer apply
		--	(
		--        				select	top 1
		--						am.agreement_external_no
		--						,aa.asset_condition
		--						,aav.vehicle_type_code 
		--						,aav.vehicle_merk_code 'merk_code'
		--						,aa.asset_type_code
		--						,aa.asset_name
		--						,am.currency_code
		--						,right(aav.vehicle_type_code, len(aav.vehicle_type_code)-1-len(aav.vehicle_model_code)) model_code
		--				from	ifinopl.dbo.agreement_main am
		--						inner join ifinopl.dbo.agreement_asset aa on (aa.agreement_no		  = am.agreement_no)
		--						left join ifinopl.dbo.agreement_asset_vehicle aav on (aav.asset_no	  = aa.asset_no)
		--				where	am.agreement_no = jd.agreement_no
		--	) am
		--	where	jd.account_no in
		--	(
		--		'70401103', '70401107', '70402100', '70402101', '70402102', '70402103', '70402104', '70403100', '70404150', '80301021', '80301031'
		--	)

		-- AND 
		--		 CONVERT(varchar(6), jrn.journal_trx_date, 112)  =  convert(varchar(6), @p_cre_date, 112) 


		-- (+) Ari 2024-02-12 ket : add log
		if not exists (
						select	1 
						from	dbo.rpt_ext_expense_log
						where	eom = @p_cre_date
					  )
		begin
			insert into dbo.rpt_ext_expense_log
			(
				eom
				,assetno
				,amt
				,assetconditionid
				,assettypeid
				,assetbrandid
				,assetbrandtypeid
				,assetbrandtypename
				,assetmodelid
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	eom
				   ,assetno
				   ,amt
				   ,assetconditionid
				   ,assettypeid
				   ,assetbrandid
				   ,assetbrandtypeid
				   ,assetbrandtypename
				   ,assetmodelid
				   ,cre_date
				   ,cre_by
				   ,cre_ip_address
				   ,mod_date
				   ,mod_by
				   ,mod_ip_address 
			from	dbo.rpt_ext_expense

		end


		end try
		begin catch
			if (len(@msg) <> 0)
				begin
					set @msg = N'v' + N';' + @msg;
				end;
			else
				begin
					set @msg = N'e;there is an error.' + N';' + error_message();
				end;

			raiserror(@msg, 16, -1);

			return;
		end catch;
	end;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_ext_expense_insert] TO [ims-raffyanda]
    AS [dbo];

