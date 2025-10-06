CREATE PROCEDURE dbo.xsp_sppa_detail_upload
(
	@p_id							bigint
	,@p_sppa_code			        nvarchar(50)	= null
	,@p_result_status				nvarchar(20)	= null
	,@p_result_date					datetime		= null
	,@p_result_total_nett_amount    decimal(18, 2)	= null
	,@p_result_policy_no            nvarchar(50)    = null
	,@p_result_reason               nvarchar(250)   = null
	,@p_buy_rate					decimal(9,6)	= 0
	,@p_buy_amount					decimal(18,2)	= 0
	,@p_discount_amount				decimal(18,2)	= 0
	,@p_pph_discount				decimal(18,2)	= 0
	,@p_ppn_discount				decimal(18,2)	= 0
	,@p_admin_fee_amount			decimal(18,2)	= 0
	,@p_stamp_fee_amount			decimal(18,2)	= 0
	,@p_net_premi					decimal(18,2)	= 0
	--
	,@p_mod_date				    datetime
	,@p_mod_by					    nvarchar(50)
	,@p_mod_ip_address			    nvarchar(50)

)
as
begin

	declare @msg					nvarchar(max) 
			,@sppa_date             datetime
			,@from_year				int
			,@to_year				int
			,@register_code  		nvarchar(50)
			,@insurance_type		nvarchar(50)
			,@sum_amount			decimal(18,2)
			,@sppa_detail_id		bigint

	begin try 
		if(@p_buy_rate = 0 and @p_buy_amount = 0 and @p_discount_amount = 0 and @p_pph_discount = 0 and @p_ppn_discount = 0 and @p_admin_fee_amount = 0 and @p_stamp_fee_amount = 0 and @p_net_premi = 0)
		begin
			set @msg = 'Cannot insert 0.' ;
			raiserror(@msg, 16, -1) ;
		end

		if(@p_buy_amount = 0 and @p_net_premi = 0)
		begin
			set @msg = 'Cannot insert 0.' ;
			raiserror(@msg, 16, -1) ;
		end


		select @sppa_date		= cast(sppa_date as date)
			   ,@register_code	= sr.register_code
		from dbo.sppa_main sm
			 inner join dbo.sppa_request sr on (sr.sppa_code = sm.code)
		where sm.code = @p_sppa_code
	
		select @insurance_type = insurance_type
		from dbo.insurance_register
		where code = @register_code

		if @p_result_status is null or @p_result_status = ''
		begin
			set @msg = 'Please input result status' ;
			raiserror(@msg, 16, -1) ;
		end

		if @p_result_status not in ('APPROVED','REJECT') 
		begin
			set @msg = 'Result status must be APPROVED or REJECT' ;
			raiserror(@msg, 16, -1) ;
		end
		
		if @p_result_date is null or @p_result_date = ''
		begin
			set @msg = 'Please input result date' ;
			raiserror(@msg, 16, -1) ;
		end

		--if @p_result_total_nett_amount is null
		--begin
		--	set @msg = 'Please input result total buy amount' ;
		--	raiserror(@msg, 16, -1) ;
		--end

		if @p_result_policy_no is null or @p_result_policy_no = ''
		begin
			set @msg = 'Please input result policy no' ;
			raiserror(@msg, 16, -1) ;
		end

		if @p_result_reason is null or @p_result_reason = ''
		begin
			set @msg = 'Please input result reason' ;
			raiserror(@msg, 16, -1) ;
		end
		
		if (@p_result_date < @sppa_date)
		begin
			set @msg = 'result date must be greater than sppa date' ;
			raiserror(@msg, 16, -1) ;
		end

		if (@p_net_premi <> @p_buy_amount - (@p_discount_amount + @p_ppn_discount - @p_pph_discount) + @p_admin_fee_amount + @p_stamp_fee_amount)
		begin
			set @msg = 'Net premi amount doesnt balance.' ;
			raiserror(@msg, 16, -1) ;
		end
		 
		
		if @p_result_status = 'REJECT'
		begin
			update	dbo.sppa_detail_asset_coverage
			set		initial_buy_rate				= @p_buy_rate
					,initial_buy_amount				= @p_buy_amount
					,initial_discount_amount		= @p_discount_amount
					,initial_discount_pph			= @p_pph_discount
					,initial_discount_ppn			= @p_ppn_discount
					,initial_admin_fee_amount		= @p_admin_fee_amount
					,initial_stamp_fee_amount		= @p_stamp_fee_amount
					,buy_amount						= @p_net_premi
					--
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	id								= @p_id ;

			select @sppa_detail_id = sppa_detail_id 
			from dbo.sppa_detail_asset_coverage
			where id = @p_id

			select @sum_amount = sum(buy_amount) 
			from dbo.sppa_detail_asset_coverage
			where sppa_detail_id = @sppa_detail_id

			update	dbo.sppa_detail
			set		result_status				= upper(@p_result_status)
					,result_date				= cast(@p_result_date as datetime)
					--,result_total_buy_amount	= @p_result_total_nett_amount
					,result_policy_no			= upper(@p_result_policy_no)
					,result_reason				= @p_result_reason
					,result_total_buy_amount	= @sum_amount
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	id							= @sppa_detail_id ;
		end
		else if @p_result_status = 'APPROVED'
		begin 
			update	dbo.sppa_detail_asset_coverage
			set		initial_buy_rate				= @p_buy_rate
					,initial_buy_amount				= @p_buy_amount
					,initial_discount_amount		= @p_discount_amount
					,initial_discount_pph			= @p_pph_discount
					,initial_discount_ppn			= @p_ppn_discount
					,initial_admin_fee_amount		= @p_admin_fee_amount
					,initial_stamp_fee_amount		= @p_stamp_fee_amount
					,buy_amount						= @p_net_premi
					--
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	id								= @p_id ;

			select @sppa_detail_id = sppa_detail_id 
			from dbo.sppa_detail_asset_coverage
			where id = @p_id

			select @sum_amount = sum(buy_amount) 
			from dbo.sppa_detail_asset_coverage
			where sppa_detail_id = @sppa_detail_id

			update dbo.sppa_detail
			set	   result_status				= upper(@p_result_status)
					,result_date				= cast(@p_result_date as datetime)
					--,result_total_buy_amount	= @p_result_total_nett_amount
					,result_policy_no			= upper(@p_result_policy_no)
					,result_total_buy_amount	= @sum_amount
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address 
					,result_reason				= @p_result_reason
			where  id							= @sppa_detail_id

		end
		else
		begin
			set @msg = 'Please input result status approved or reject';
			raiserror(@msg, 16, -1) ;
		end
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



