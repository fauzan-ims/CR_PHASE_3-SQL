CREATE PROCEDURE [dbo].[xsp_sppa_main_print]
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			,@code				nvarchar(50)
			,@initial_buy_rate	decimal(9, 6)
			,@initial_sell_rate decimal(9, 6)
			,@rate				decimal(18, 2)
			,@company_address	nvarchar(250)
			,@delivery_addres	nvarchar(4000)
			,@fa_code			nvarchar(50) ;

	begin try
		select	@fa_code = fa_code
		from	dbo.sppa_detail
		where	sppa_code = @p_code ;

		if exists
		(
			select	1
			from	dbo.asset
			where	isnull(agreement_no, '') <> ''
					and code				 = @fa_code
		)
		begin
			select	@company_address = deliver_to_address
			from	ifinopl.dbo.application_asset
			where	fa_code = @fa_code ;
		end ;
		else
		begin
			select	@company_address = value
			from	dbo.sys_global_param
			where	code = 'COMPADD' ;
		end ;

		select	sdac.id
				,sd.sppa_code
				,ir.branch_name
				,ir.register_qq_name									'register_name'
				,sd.fa_code
				,sd.object_name
				,ira.accessories
				,avh.colour
				,avh.chassis_no
				,avh.engine_no
				,avh.built_year
				,avh.remark
				,sd.sum_insured_amount * (sdac.rate_depreciation / 100) 'sum_insured_amount'
				,ir.currency_code
				,mi.phone_no
				,@company_address										'address'
				,mc.coverage_name
				,ir.from_date											'from_date'
				,ir.to_date
				,ir.register_type
				,sd.result_policy_no
				,sdac.initial_buy_rate									'buy_rate'
				,sdac.initial_buy_amount								'buy_amount'
				,sdac.initial_discount_pct								'discount_pct'
				,sdac.initial_discount_amount							'discount_amount'
				,sdac.initial_discount_pph								'pph_discount'
				,sdac.initial_discount_ppn								'ppn_discount'
				,sdac.initial_admin_fee_amount							'admin_fee_amount'
				,sdac.initial_stamp_fee_amount							'stamp_fee_amount'
				,sdac.buy_amount										'net_premi' --'coverage_premi_amount'
				,sd.result_status
				,null													'result_date'
				,sd.result_reason
		from	dbo.sppa_detail							 sd
				left join dbo.sppa_main					 spm on (spm.code			  = sd.sppa_code)
				left join dbo.sppa_request				 sr on (sr.code				  = sd.sppa_request_code)
				left join dbo.insurance_register		 ir on (ir.code				  = sr.register_code)
				left join dbo.insurance_register_asset	 ira on (
																	ira.register_code = ir.code
																	and	 sd.fa_code	  = ira.fa_code
																)
				left join dbo.master_insurance			 mi on (mi.code				  = ir.insurance_code)
				left join dbo.sppa_detail_asset_coverage sdac on (sdac.sppa_detail_id = sd.id)
				left join dbo.master_coverage			 mc on (mc.code				  = sdac.coverage_code)
				left join dbo.asset_vehicle				 avh on (avh.asset_code		  = sd.fa_code)
		where	sd.sppa_code = @p_code ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
