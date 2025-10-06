/*
	alterd : Yunus Muslim, 24 April 2020
*/
CREATE PROCEDURE dbo.xsp_termination_main_proceed 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@refund_amount		decimal(18,2) ;

	begin try
		
		if exists
		(
			select	tda.refund_amount
			from	dbo.termination_main tmn
					inner join dbo.termination_detail_asset tda on tda.termination_code = tmn.code
			where	code				   = @p_code
					and termination_status = 'HOLD'
					and tda.refund_amount  = 0
		)
		begin
			set @msg = N'Refund amount must greater than 0.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists (select 1 from dbo.termination_main where code = @p_code and termination_status = 'HOLD')
		begin
		    update	dbo.termination_main 
			set		termination_status	= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
		end
        else
		begin
		    raiserror('Error data already proceed',16,1) ;
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

