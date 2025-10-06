/*
    alterd : Bilal, 06 Januari 2021
*/
CREATE PROCEDURE [dbo].[xsp_waived_obligation_revert]
(
	@p_code						nvarchar(50)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)	
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg				nvarchar(max)
			,@change_amount		decimal(18,2)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@currency			nvarchar(10)
			,@remark			nvarchar(4000)
			,@agreement_no		nvarchar(50)
				
	
	begin try
		
		if exists(select 1 from dbo.waived_obligation where code = @p_code and waived_status <> 'ON PROCESS')
		begin
			set @msg ='Data already proceed';
		    raiserror(@msg,16,1) ;
		end
        else
		begin
			update dbo.waived_obligation
			set		waived_status			= 'HOLD'
					,mod_by					= @p_mod_by
					,mod_date				= @p_mod_date
					,mod_ip_address			= @p_mod_ip_address
			where   code					= @p_code
		end

	end try
	begin catch
	
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;
	
		raiserror(@msg, 16, -1) ;
	
		return ;
	end catch ;
	
end

