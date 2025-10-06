CREATE PROCEDURE dbo.xsp_endorsement_main_update_amount
(
	@p_endorsement_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max) 
			,@buy_old	decimal(18,2)
			,@sell_old	decimal(18,2)
			,@buy_new	decimal(18,2)
			,@sell_new	decimal(18,2);

	begin try
		select @buy_old = sum(remain_buy),
			   @sell_old = sum(remain_sell)
		from dbo.endorsement_period
		where endorsement_code = @p_endorsement_code
			  and old_or_new = 'OLD';

	
		select @buy_new = sum(remain_buy),
			   @sell_new = sum(remain_sell)
		from dbo.endorsement_period
		where endorsement_code = @p_endorsement_code
			  and old_or_new = 'NEW';
		
		update dbo.endorsement_main
		set endorsement_payment_amount		= isnull(@buy_new,0) - isnull(@buy_old,0)
			,endorsement_received_amount	= isnull(@sell_new,0) - isnull(@sell_old,0)
			,mod_date						= @p_mod_date
			,mod_by							= @p_mod_by
			,mod_ip_address					= @p_mod_ip_address
		where code = @p_endorsement_code

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

