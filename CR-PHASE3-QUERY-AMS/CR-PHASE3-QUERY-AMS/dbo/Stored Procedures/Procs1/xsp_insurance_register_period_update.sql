CREATE PROCEDURE [dbo].[xsp_insurance_register_period_update]
(
	@p_id							  bigint
	--,@p_initial_buy_admin_fee_amount  decimal(18, 2)
	--,@p_initial_sell_admin_fee_amount decimal(18, 2)
	--,@p_initial_stamp_fee_amount      decimal(18, 2)
	--,@p_deduction_amount		      decimal(18, 2)
	--,@p_total_buy_amount		      decimal(18, 2)
	--,@p_total_sell_amount		      decimal(18, 2)
	,@p_sum_insured					 decimal(18,2) = 0
	--							      
	,@p_mod_date				      datetime
	,@p_mod_by					      nvarchar(15)
	,@p_mod_ip_address			      nvarchar(15)
)								      
as								      
begin							      
	declare @msg			           nvarchar(max) 
			,@main_coverage            nvarchar(1)
			,@p_coverage_code          nvarchar(50)

	begin try
		select	@main_coverage = mc.is_main_coverage
		from	dbo.master_coverage mc
				inner join dbo.insurance_register_period irp on (mc.code = irp.coverage_code)
		where	mc.code = @p_coverage_code ;

		--if exists
		--(
		--	select	1
		--	from	dbo.insurance_register_period
		--	where	coverage_code	   <> @p_coverage_code
		--			and @main_coverage = '1'
		--			and year_periode   = '1'
		--)
		--begin
		--	set @msg = 'Main Coverage already exist' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
        
		update	insurance_register_period
		set		
				--initial_buy_admin_fee_amount	= @p_initial_buy_admin_fee_amount
				--,initial_sell_admin_fee_amount  = @p_initial_sell_admin_fee_amount
				--,initial_stamp_fee_amount		= @p_initial_stamp_fee_amount
				--,deduction_amount				= @p_deduction_amount
				--,total_buy_amount				= @p_total_buy_amount
				--,total_sell_amount				= @p_total_sell_amount
				sum_insured						= @p_sum_insured
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id ;
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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;

