CREATE PROCEDURE dbo.xsp_warning_letter_proceed
(
	@p_code						nvarchar(50)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
AS
begin

	declare @msg					nvarchar(max)
			,@letter_type			nvarchar(20)
			,@agreement_no			nvarchar(50)
			,@installment_no 		int
	
	select	@letter_type				= letter_type
			,@agreement_no				= wl.CLIENT_NO
			,@installment_no			= installment_no 
	from	dbo.warning_letter wl
			inner join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
	where	code = @p_code

	begin TRY
		
		if exists (select 1 from dbo.warning_letter where code = @p_code and letter_status not in ('HOLD','NOT DELIVERED'))
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end

		begin
			update dbo.warning_letter
			set		letter_status		= 'ON PROCESS'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
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
end  
