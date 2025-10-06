create PROCEDURE dbo.xsp_insert_insurance
as
begin
	insert into dbo.insurance_policy_main
	(
		code
		,sppa_code
		,register_code
		,branch_code
		,branch_name
		,source_type
		,policy_status
		,policy_payment_status
		,insured_name
		,insured_qq_name
		,policy_payment_type
		,object_name
		,insurance_code
		,insurance_type
		,currency_code
		,cover_note_no
		,cover_note_date
		,policy_no
		,policy_eff_date
		,policy_exp_date
		,eff_rate
		,file_name
		,paths
		,doc_file
		,invoice_no
		,invoice_date
		,from_year
		,to_year
		,total_premi_buy_amount
		,total_discount_amount
		,total_net_premi_amount
		,stamp_fee_amount
		,admin_fee_amount
		,total_adjusment_amount
		,is_policy_existing
		,endorsement_count
		,policy_process_status
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select		'1000.AMSMIG.2307.' + right('00000' + convert(nvarchar(6), row_number() over (order by [no polis])), 6) as num_row	
				,null																												
				,null																												
				,'1000'																												
				,'HO'																												
				,'ASSET'																											
				,'ACTIVE'																											
				,max([is not paid])																									
				,'PT DIPO STAR FINANCE'																								
				,''																													
				,'FTFP'																												
				,''																													
				,'AMSINS.2306.000002'																								
				,'NON LIFE'																											
				,'IDR'																												
				,null																												
				,null																												
				,[no polis]																											
				,dateadd(year, -1, cast(max([end polis asuransi]) as datetime))														
				,max([end polis asuransi])																							
				,0																													
				,null																												
				,null																												
				,null																												
				,'MIGRASI'																											
				,getdate()																											
				,1																													
				,1																													
				,sum(isnull([net premi], 0))																						
				,0																													
				,0																													
				,0																													
				,0																													
				,0																													
				,'0'																												
				,'0'																												
				,''																													
				,getdate()
				,'MIGRASI'
				,'MIGRASI'
				,getdate()
				,'MIGRASI'
				,'MIGRASI'
	from		temp_insurance_policy_plus_acode
	where		[end polis asuransi] <> '1900-01-00'
				and [no polis] is not null
	group by	[no polis] ;

	insert into dbo.insurance_policy_asset
	(
		code
		,policy_code
		,fa_code
		,sum_insured_amount
		,depreciation_code
		,collateral_type
		,collateral_category_code
		,occupation_code
		,region_code
		,collateral_year
		,is_authorized_workshop
		,is_commercial
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select	'DSF.IPAMIG.2307.' + right('00000' + convert(nvarchar(6), row_number() over (order by [no polis])), 6) as num_row
			,ipm.code
			,'' --fa_code
			,ipm.total_premi_buy_amount
			,'AMSMD.2306.000003'
			,'VHCL'
			,'MCC.2306.000003'
			,'AMSMO.2306.000001'
			,'W0'
			,tap.YEAR
			,'0'
			,'0'
			,getdate()
			,'MIGRASI'
			,'MIGRASI'
			,getdate()
			,'MIGRASI'
			,'MIGRASI'
	from	dbo.insurance_policy_main						ipm
			inner join dbo.temp_insurance_policy_plus_acode tap on (ipm.policy_no = tap.[no polis])
	where	ipm.MOD_BY = 'MIGRASI' ;
	
	insert into dbo.insurance_policy_main_period
	(
		code
		,policy_code
		,rate_depreciation
		,coverage_code
		,is_main_coverage
		,year_periode
		,buy_amount
		,discount_pct
		,discount_amount
		,admin_fee_amount
		,stamp_fee_amount
		,adjustment_amount
		,total_buy_amount
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select		'DSF.IPAMIG.2307.' + right('0000' + convert(nvarchar(6), row_number() over (order by ipm.CODE)), 6) as num_row
				,ipm.CODE
				,100
				,'AMSMC.2306.000001'
				,'1'
				,'1'
				,sum(ipm.total_premi_buy_amount)
				,0
				,0
				,0
				,0
				,0
				,sum(ipm.total_premi_buy_amount)
				,getdate()
				,'MIGRASI'
				,'MIGRASI'
				,getdate()
				,'MIGRASI'
				,'MIGRASI'
	from		dbo.insurance_policy_main ipm
	where		ipm.mod_by = 'MIGRASI'
	group by	ipm.code ;
end ;
