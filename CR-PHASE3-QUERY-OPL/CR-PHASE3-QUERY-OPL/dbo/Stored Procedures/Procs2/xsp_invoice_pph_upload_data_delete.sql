CREATE PROCEDURE dbo.xsp_invoice_pph_upload_data_delete
(
	@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	/*
		Cre_by		: sepria
		Cre_date	: 2024-07-02
		Cre_Note	: untuk menampung data upload dan munculkan validasi tanpa memproses data lainnya
	*/
	declare @msg				nvarchar(max);
	
	begin try
		
		delete dbo.invoice_pph_upload_data
		where	p_user_id = @p_mod_by

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
