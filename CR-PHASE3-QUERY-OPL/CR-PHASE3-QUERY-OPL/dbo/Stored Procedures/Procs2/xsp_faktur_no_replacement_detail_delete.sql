

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_delete
(
	@p_faktur_no_replacement_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		delete dbo.faktur_no_replacement_detail_upload_validasi_1
		where	faktur_no_replacement_code = @p_faktur_no_replacement_code --and user_id = @p_cre_by --and upload_date = @p_cre_by
		
		delete	dbo.faktur_no_replacement_detail_upload_1
		where	faktur_no_replacement_code = @p_faktur_no_replacement_code ;

		--fauzan 17032025
		delete dbo.faktur_no_replacement_detail
		where	faktur_no_replacement_code = @p_faktur_no_replacement_code --and USER_ID = @p_cre_by --and UPLOAD_DATE = @p_cre_by


	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
