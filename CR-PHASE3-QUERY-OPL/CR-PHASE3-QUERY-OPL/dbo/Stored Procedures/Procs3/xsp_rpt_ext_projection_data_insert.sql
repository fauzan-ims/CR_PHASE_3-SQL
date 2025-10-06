CREATE PROCEDURE dbo.xsp_rpt_ext_projection_data_insert
AS
BEGIN
	DECLARE @code	NVARCHAR(50)
			,@year	NVARCHAR(4)
			,@month NVARCHAR(2)
			,@msg	NVARCHAR(MAX) 
			,@p_cre_date		 DATETIME = '2025-07-31' 
			,@p_cre_by			 NVARCHAR(15) = 'JOB'
			,@p_cre_ip_address	 NVARCHAR(15) = 'JOB'
			,@ppn				 DECIMAL(9,6) = 0
		 
	BEGIN TRY
    /*
		jadwal schedule yang belumjatuh tempo, per angsuran insert ppn, ar, income, 
	ditambah
		jadwal depresiasi yang belum jatuh tempo , group by bulan dan tahun. ( time nya di anggap tanggal 1) asset ini hanya ada 3 baris per bulan schedule
	ditambah 
		prepaid asuransi 1 baris
	ditambah 
		prepaid stnk 1 baris"
	*/
		SELECT @ppn = CAST(value AS DECIMAL) 
		FROM dbo.sys_global_param 
		WHERE code = 'RTAXPPN'

		DELETE dbo.rpt_ext_projection_data

		BEGIN 
			-- journal AR
			DECLARE @coa_agreement TABLE
			(
				COA NVARCHAR(50)

			)
			INSERT @coa_agreement
			(
				COA
			)
			VALUES
			('20401100')   --AR
			,('19201000')  --PPN
			,('50401100')  --INCOME

			DECLARE @coa_asset TABLE
			(
				COA NVARCHAR(50)

			)
			
			INSERT @coa_asset
			(
				COA
			)
			VALUES
			 ('20410150')  --vehicle for lease
			,('20411150')  --acumm
			,('70404150')  --depre


--20409100	prepaid asuransi
--20409101	prepaid stnk
		END
        
	 
        
		INSERT INTO rpt_ext_projection_data
		(
			agreement_id
			,coa_account
			,time
			,sequence
			,asset_model
			,asset_brand
			,asset_brand_type
			,asset_brand_type_name
			,asset_type
			,asset_condition
			,amount
			,as_of
			,create_date
			,create_time
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		
		SELECT  am.agreement_external_no
				,dcoa.COA
				--,convert(varchar, DATEADD(DAY,1,EOMONTH(aaa.due_date)), 23) --CONVERT(nvarchar(10),aaa.due_date,101)--am.periode
				--,DATEADD(DAY,1,EOMONTH(aaa.due_date)) --CONVERT(nvarchar(10),aaa.due_date,101)--am.periode
				,DATEFROMPARTS(YEAR(aaa.due_date),MONTH(aaa.due_date),'01')
				,rpt.sequence
				,CASE  ISNULL( av.type_item_code,'')
						 WHEN '' THEN RIGHT(astv.vehicle_unit_code, LEN(astv.vehicle_unit_code)-1-LEN(astv.vehicle_model_code))
						ELSE RIGHT(av.type_item_code, LEN(av.type_item_code)-1-LEN(av.model_code))
				END
				,ISNULL(av.merk_code, astv.vehicle_merk_code)		
				 ,LEFT(ISNULL(av.MODEL_NAME , astvmodel.DESCRIPTION),50)
               ,ISNULL(av.MODEL_NAME , astvmodel.DESCRIPTION)
				,'1'
				,aa.asset_condition
				, SUM(CASE 
					WHEN dcoa.coa = '20401100' THEN (aaa.billing_amount  + CAST((aaa.billing_amount*11/100) AS INTEGER))/1000
					WHEN dcoa.coa = '19201000' THEN ( CAST((aaa.billing_amount*11/100) AS INTEGER))/1000
					WHEN dcoa.coa = '50401100' THEN (aaa.billing_amount   )/1000
				  END)
				 ,EOMONTH(@p_cre_date)
				,@p_cre_date
				,CAST(GETDATE() AS TIME)
				--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
			 FROM dbo.XXX_AGREEMENT_MAIN_AFTER_EOM_20250731 am
		INNER JOIN dbo.XXX_AGREEMENT_ASSET_AFTER_EOM_20250731 aa ON aa.agreement_no = am.agreement_no
		INNER JOIN dbo.agreement_asset_amortization aaa ON aaa.asset_no = aa.asset_no
		INNER JOIN ifinopl.dbo.rpt_ext_agreement_main rpt ON rpt.agreement_id = am.agreement_external_no
		INNER JOIN @coa_agreement dcoa ON 1=1
		LEFT JOIN ifinams.dbo.XXX_ASSET_VEHICLE_AFTER_EOM_20250731 av ON av.asset_code = aa.fa_code

		LEFT JOIN ifinopl.dbo.XXX_AGREEMENT_ASSET_VEHICLE_AFTER_EOM_20250731 astv ON astv.asset_no = aa.asset_no
		LEFT JOIN ifinopl.dbo.XXX_MASTER_VEHICLE_MERK_AFTER_EOM_20250731 astvmerek ON astvmerek.code = astv.vehicle_merk_code
		LEFT JOIN ifinopl.dbo.XXX_MASTER_VEHICLE_MODEL_AFTER_EOM_20250731 astvmodel ON astvmodel.code = astv.vehicle_model_code

		--outer apply (
		--				SELECT TOP 1 rpt.sequence
		--				from ifinopl.dbo.rpt_ext_agreement_main rpt
		--				where rpt.agreement_id = isnull(am.agreement_external_no, aa.fa_code)
		--	) rpt
		WHERE am.agreement_status = 'GO LIVE'
		AND aa.asset_status = 'RENTED'
		AND  CONVERT(VARCHAR(6), aaa.due_date , 112) >  CONVERT(VARCHAR(6), @p_cre_date , 112)  

		GROUP BY	am.agreement_external_no
					,dcoa.coa
					,DATEFROMPARTS(YEAR(aaa.due_date),MONTH(aaa.due_date),'01')
					,rpt.sequence
					,CASE  ISNULL( av.type_item_code,'')
						 WHEN '' THEN RIGHT(astv.vehicle_unit_code, LEN(astv.vehicle_unit_code)-1-LEN(astv.vehicle_model_code))
						ELSE RIGHT(av.type_item_code, LEN(av.type_item_code)-1-LEN(av.model_code))
					END
					,ISNULL(av.merk_code, astv.vehicle_merk_code)
					,av.merk_code
					 ,LEFT(ISNULL(av.MODEL_NAME , astvmodel.DESCRIPTION),50)
					 ,ISNULL(av.MODEL_NAME , astvmodel.DESCRIPTION)
					,aa.asset_condition
	
	BEGIN -- asset  current month			  
		INSERT INTO rpt_ext_projection_data
		(
			agreement_id
			,coa_account
			,time
			,sequence
			,asset_model
			,asset_brand
			,asset_brand_type
			,asset_brand_type_name
			,asset_type
			,asset_condition
			,amount
			,as_of
			,create_date
			,create_time
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		SELECT 'NA'
				,dcoa.coa
				--,convert(varchar, DATEADD(DAY,1,EOMONTH(adsc.DEPRECIATION_DATE)), 23) --CONVERT(nvarchar(10),eomonth(adsc.depreciation_date),101) periode--am.periode
				--,DATEADD(DAY,1,EOMONTH(adsc.DEPRECIATION_DATE))
				,DATEFROMPARTS(YEAR(@p_cre_date), MONTH(@p_cre_date), '01')
				,3802
				,'NA_VEHICLE'
				,'NA'
				,'NA'
				,'NA'
				,'NA'
				,'New'
				, CASE 
					WHEN dcoa.coa = '20410150' THEN (SUM(ass.purchase_price) )/1000
					WHEN dcoa.coa = '20411150' THEN (SUM(ISNULL(ass.purchase_price-ass.total_depre_comm ,0))*-1 )/1000
					WHEN dcoa.coa = '70404150' THEN (SUM(ISNULL(ass.total_depre_comm   ,0))*-1 )/1000
				  END
				,EOMONTH(@p_cre_date)
				,@p_cre_date
				,CAST(GETDATE() AS TIME)
                  	--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
		FROM ifinams.dbo.XXX_ASSET_AFTER_EOM_20250731 ass
		--from ifinams.dbo.asset_depreciation_schedule_commercial adsc
		--inner join ifinams.dbo.asset ass on ass.code = adsc.asset_code 
		INNER JOIN @coa_asset dcoa ON 1=1
			--WHERE	   ass.CRE_DATE			<= @p_cre_date
			--   AND (
			--		   ass.SALE_DATE IS NULL
			--		   OR ass.SALE_DATE		> @p_cre_date
			--	   )
		 --  AND (
			--	   ass.DISPOSAL_DATE IS NULL
			--	   OR ass.DISPOSAL_DATE > @p_cre_date
			--   )
		 --  AND ass.STATUS				NOT IN ( 'CANCEL', 'hold')
		 --       AND (
			--	   ass.PERMIT_SELL_DATE IS NULL
			--	   OR  CAST(ass.PERMIT_SELL_DATE AS DATE) > @p_cre_date
			--   )
						WHERE	   ass.CRE_DATE			<= @p_cre_date
			   AND (
					   ass.SALE_DATE IS NULL
					   OR ass.SALE_DATE		> @p_cre_date
				   )
		   AND (
				   ass.DISPOSAL_DATE IS NULL
				   OR ass.DISPOSAL_DATE > @p_cre_date
			   )
		   AND ass.STATUS				NOT IN ( 'CANCEL', 'hold')
		        AND (
				   ass.PERMIT_SELL_DATE IS NULL
				   OR  CAST(ass.PERMIT_SELL_DATE AS DATE) > @p_cre_date
			   )
		   		AND CODE  NOT IN (
					 '1000.MIG.0001.0019'
					,'2001.AST.2312.00001'
					,'2008.AST.2312.00004'
					,'2010.AST.2312.00001'
					,'2010.AST.2312.00002'			   
					)
			GROUP BY dcoa.coa

			END
			
			
			BEGIN -- asset next month
				INSERT INTO RPT_EXT_PROJECTION_DATA
					(
						AGREEMENT_ID
						,COA_ACCOUNT
						,TIME
						,SEQUENCE
						,ASSET_MODEL
						,ASSET_BRAND
						,ASSET_BRAND_TYPE
						,ASSET_BRAND_TYPE_NAME
						,ASSET_TYPE
						,ASSET_CONDITION
						,AMOUNT
						,AS_OF
						,CREATE_DATE
						,CREATE_TIME
						--
						,CRE_DATE
						,CRE_BY
						,CRE_IP_ADDRESS
						,MOD_DATE
						,MOD_BY
						,MOD_IP_ADDRESS
					)
				SELECT	   'NA'
						   ,dcoa.COA
						   --,convert(varchar, DATEADD(DAY,1,EOMONTH(adsc.DEPRECIATION_DATE)), 23) --CONVERT(nvarchar(10),eomonth(adsc.depreciation_date),101) periode--am.periode
						   --,DATEADD(DAY,1,EOMONTH(adsc.DEPRECIATION_DATE))
						   ,DATEFROMPARTS(YEAR(com.DEPRECIATION_DATE), MONTH(com.DEPRECIATION_DATE), '01')
						   ,3802
						   ,'NA_VEHICLE'
						   ,'NA'
						   ,'NA'
						   ,'NA'
						   ,'NA'
						   ,'New'
						   ,CASE
								WHEN dcoa.COA = '20410150' THEN (SUM(com.ORIGINAL_PRICE)) / 1000
								WHEN dcoa.COA = '20411150' THEN (SUM(com.ACCUM_DEPRE_AMOUNT) * -1) / 1000
								WHEN dcoa.COA = '70404150' THEN ((SUM(com.ORIGINAL_PRICE) - SUM(com.ACCUM_DEPRE_AMOUNT)) * -1) / 1000
							END
						   ,EOMONTH(@p_cre_date)
						   ,@p_cre_date
						   ,CAST(GETDATE() AS TIME)
						   --
						   ,@p_cre_date
						   ,@p_cre_by
						   ,@p_cre_ip_address
						   ,@p_cre_date
						   ,@p_cre_by
						   ,@p_cre_ip_address
				FROM	   IFINAMS.dbo.XXX_ASSET_DEPRECIATION_SCHEDULE_COMMERCIAL_AFTER_EOM_20250731 com
				INNER JOIN @coa_asset										  dcoa ON 1 = 1
				WHERE	   com.DEPRECIATION_DATE > '2023-11-30'
						   AND com.ASSET_CODE IN
							   (
								   SELECT	  ast.CODE
								   FROM		  IFINAMS.dbo.XXX_ASSET_AFTER_EOM_20250731			ast
								   INNER JOIN IFINAMS.dbo.XXX_ASSET_VEHICLE_AFTER_EOM_20250731 av ON av.ASSET_CODE = ast.CODE
					where	ASSET_FROM								 = 'BUY'
				and isnull(IS_PERMIT_TO_SELL, '0')		 = '0'
				and STATUS in
		(
			'STOCK', 'REPLACEMENT'
		)
				and convert(char(6), PURCHASE_DATE, 112) <= convert(char(6), @p_cre_date, 112) 
				AND convert(char(6), ast.CRE_DATE, 112) <= convert(char(6), @p_cre_date, 112)
											  AND CODE NOT IN
				(
					'1000.MIG.0001.0019', '2001.AST.2312.00001', '2008.AST.2312.00004', '2010.AST.2312.00001', '2010.AST.2312.00002'
				)
							   )
				GROUP BY   DATEFROMPARTS(YEAR(com.DEPRECIATION_DATE), MONTH(com.DEPRECIATION_DATE), '01')
						   ,dcoa.COA
				ORDER BY   DATEFROMPARTS(YEAR(com.DEPRECIATION_DATE), MONTH(com.DEPRECIATION_DATE), '01');
			end;

	
		insert into rpt_ext_projection_data
		(
			agreement_id
			,coa_account
			,time
			,sequence
			,asset_model
			,asset_brand
			,asset_brand_type
			,asset_brand_type_name
			,asset_type
			,asset_condition
			,amount
			,as_of
			,create_date
			,create_time
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select 'NA'
				,'20409100'
				--,convert(varchar, DATEADD(DAY,1,EOMONTH(adsc.prepaid_date)), 23)--convert(nvarchar(10),eomonth(adsc.prepaid_date),101) periode--am.periode
				--,DATEADD(DAY,1,EOMONTH(adsc.prepaid_date))
				,datefromparts(year(adsc.prepaid_date),month(adsc.prepaid_date),'01')
				,3802
				,'NA_VEHICLE'
				,'NA'
				,'NA'
				,'NA'
				,'NA'
				,'New'
				, (SUM(adsc.prepaid_amount) )/1000
				,EOMONTH(@p_cre_date)
				,@p_cre_date
				,CAST(GETDATE() AS TIME)
                  	--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
		from ifinams.dbo.asset_prepaid_schedule adsc
		inner join ifinams.dbo.asset_prepaid_main pm on pm.prepaid_no = adsc.prepaid_no
		inner join ifinams.dbo.XXX_ASSET_AFTER_EOM_20250731 ass on ass.code = pm.fa_code
		where convert(varchar(6), adsc.prepaid_date, 112) >  convert(varchar(6),@p_cre_date, 112)
		and pm.prepaid_type ='INSURANCE'
		group by  datefromparts(year(adsc.prepaid_date),month(adsc.prepaid_date),'01')

		insert into rpt_ext_projection_data
		(
			agreement_id
			,coa_account
			,time
			,sequence
			,asset_model
			,asset_brand
			,asset_brand_type
			,asset_brand_type_name
			,asset_type
			,asset_condition
			,amount
			,as_of
			,create_date
			,create_time
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select 'NA'
				,'20409101'
				--,convert(varchar, DATEADD(DAY,1,EOMONTH(adsc.prepaid_date)), 23)
				--,DATEADD(DAY,1,EOMONTH(adsc.prepaid_date))
				,datefromparts(year(adsc.prepaid_date),month(adsc.prepaid_date),'01')
				,3802
				,'NA_VEHICLE'
				,'NA'
				,'NA'
				,'NA'
				,'NA'
				,'New'
				, (SUM(adsc.prepaid_amount) )/1000
				,EOMONTH(@p_cre_date)
				,@p_cre_date
				,CAST(GETDATE() AS TIME)
                  	--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
		from ifinams.dbo.asset_prepaid_schedule adsc
		inner join ifinams.dbo.asset_prepaid_main pm on pm.prepaid_no = adsc.prepaid_no
		inner join ifinams.dbo.XXX_ASSET_AFTER_EOM_20250731 ass on ass.code = pm.fa_code
		where convert(varchar(6), adsc.prepaid_date, 112) >  convert(varchar(6),@p_cre_date, 112)
		and pm.prepaid_type ='REGISTER'
		group by  datefromparts(year(adsc.prepaid_date),month(adsc.prepaid_date),'01')
		--AND 



		UPDATE	dbo.RPT_EXT_PROJECTION_DATA
		SET		ASSET_MODEL = 'XCN5PT'
		WHERE	ASSET_MODEL = 'N5PT'	
		
		UPDATE dbo.RPT_EXT_PROJECTION_DATA
		SET ASSET_MODEL = 'HSC24D'
		WHERE ASSET_MODEL = 'C24D'
		
		UPDATE dbo.RPT_EXT_PROJECTION_DATA
		SET ASSET_MODEL = 'HSCD4M'
		WHERE ASSET_MODEL = 'CD4M'	
		--select	 am.agreement_external_no
		--		,jd.account_no
		--		,convert(nvarchar(10),jo.journal_trx_date,103)--am.periode
		--		,am.asset_no
		--		,am.model_code
		--		,am.merk_code
		--		,am.type_item_code
		--		,am.type_item_name
		--		,am.type_code
		--		,am.condition
		--		,am.asset_amount
		--		,@p_cre_date
		--		,@p_cre_date
		--		,@p_cre_date
		--		--
		--		,@p_cre_date		
		--		,@p_cre_by			
		--		,@p_cre_ip_address	
		--		,@p_cre_date		
		--		,@p_cre_by			
		--		,@p_cre_ip_address	
		--from	ifinacc.dbo.journal_detail jd
		--		inner join ifinacc.dbo.journal jo on (jo.code = jd.journal_code)
		--		outer apply
		--(
		--	select	am.agreement_external_no
		--			,ags.periode
		--			,ags.asset_no
		--			,av.model_code
		--			,av.merk_code
		--			,av.type_item_code
		--			,av.type_item_name
		--			,ass.type_code
		--			,ass.condition
		--			,ags.asset_amount
		--	from	dbo.agreement_main am
		--			inner join dbo.agreement_asset ags on (ags.agreement_no	  = am.agreement_no)
		--			inner join ifinams.dbo.asset ass on (ass.code			  = ags.fa_code)
		--			inner join ifinams.dbo.asset_vehicle av on (av.asset_code = ass.code)
		--			inner join ifinams.dbo.master_category mc on (mc.code	  = ass.category_code)
		--	where	ass.status in	('STOCK', 'REPLACEMENT') 
		--	and		am.agreement_no = jd.agreement_no
		--) am
		--where	jd.account_no in('19201000','20401100','50401100')
		--and		isnull(jd.agreement_no,'') <> ''
		--and		year(jo.journal_trx_date) + month(jo.journal_trx_date) = year(@p_cre_date) + month(@p_cre_date)
		--and not exists(
		--				select	1
		--				from	rpt_ext_projection_data
		--				where	agreement_id			= am.agreement_external_no
		--				and		coa_account				= jd.account_no
		--				and		time					= jo.journal_trx_date--am.periode
		--				and		sequence				= am.asset_no
		--				and		asset_model				= am.model_code
		--				and		asset_brand				= am.merk_code
		--				and		asset_brand_type		= am.type_item_code
		--				and		asset_brand_type_name	= am.type_item_name
		--				and		asset_type				= am.type_code
		--				and		asset_condition			= am.condition
		--				and		amount					= am.asset_amount
		--				and		as_of					= @p_cre_date
		--				and		create_date				= @p_cre_date
		--				and		create_time				= @p_cre_date)
						

		
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
