

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_upload_data_delete
(
	 @p_faktur_no_replacement_code		nvarchar(50)
	,@p_cre_by							nvarchar(50)
	,@p_cre_date						datetime
)
as
begin
	
	declare @msg				nvarchar(max);
	
	begin TRY
    
		delete dbo.faktur_no_replacement_detail_upload_validasi_1
		where	faktur_no_replacement_code = @p_faktur_no_replacement_code --and user_id = @p_cre_by --and upload_date = @p_cre_by
		
		delete dbo.faktur_no_replacement_detail_upload_1
		where	faktur_no_replacement_code = @p_faktur_no_replacement_code --and USER_ID = @p_cre_by --and UPLOAD_DATE = @p_cre_by

		delete dbo.faktur_no_replacement_detail
		where	faktur_no_replacement_code = @p_faktur_no_replacement_code --and USER_ID = @p_cre_by --and UPLOAD_DATE = @p_cre_by

		update FAKTUR_NO_REPLACEMENT set validasi = '0' 
		where	CODE = @p_faktur_no_replacement_code 



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
