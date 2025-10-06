CREATE PROCEDURE dbo.xsp_repossession_letter_update_settlement
(
	@p_code										nvarchar(50)
	,@p_result_status							nvarchar(10)
	,@p_result_action							nvarchar(10)	= null
	,@p_result_date								datetime
	,@p_current_overdue_installment_amount		decimal(18, 2)	= 0
	,@p_current_overdue_penalty_amount			decimal(18, 2)	= 0
	,@p_result_received_amount					decimal(18, 2)	= 0
	--
	,@p_mod_date								datetime
	,@p_mod_by									nvarchar(15)
	,@p_mod_ip_address							nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		if (cast(@p_result_date  as date) > cast(dbo.xfn_get_system_date() as date))
		begin		    
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Result Date','System Date');
			raiserror(@msg, 16, -1) ;
		end

		update	repossession_letter
		set		result_status									= @p_result_status
				,result_date									= @p_result_date
				,result_action									= @p_result_action
				--
				,mod_date										= @p_mod_date
				,mod_by											= @p_mod_by
				,mod_ip_address									= @p_mod_ip_address
		where	code											= @p_code ;

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
