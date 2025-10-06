-- Louis Jumat, 07 Juli 2023 20.46.41 -- 
CREATE PROCEDURE dbo.xsp_agreement_main_update_opl_status
(
	@p_agreement_no	   nvarchar(50)
	,@p_status		   nvarchar(250) = ''
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.agreement_main
		set		opl_status = @p_status
		where	agreement_no = @p_agreement_no ;
	end try
	begin catch 
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
