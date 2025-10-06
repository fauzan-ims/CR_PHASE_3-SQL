create procedure dbo.xsp_upload_validation_must_be_greater_than_zero
(
	@p_tabel_name				nvarchar(250)
	,@p_column_name				nvarchar(250)
	,@p_value_check				nvarchar(4000)
	,@p_primary_key				nvarchar(250)
	--
	 --
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin

	declare @date_check datetime
			,@error_msg	nvarchar(4000)
	

	-- karena amount cek dulu value nya apakah sebuah number
	begin
		begin try
			set @p_value_check =  cast(@p_value_check as decimal)
		end try
		begin CATCH
        
			set @error_msg = @p_column_name + 'Invalid Format Number'

			EXEC	dbo.xsp_upload_error_log_insert 
					@p_tabel_name					
			        ,@p_column_name					
			        ,@error_msg		
					,@p_primary_key
					--				
			        ,@p_cre_date					
			        ,@p_cre_by						
			        ,@p_cre_ip_address				
			        ,@p_mod_date					
			        ,@p_mod_by						
			        ,@p_mod_ip_address				
			
		end catch
	end

	-- VALIDASI value jika kurang dari 0
	BEGIN
    
		if (cast(@p_value_check as decimal) <= 0.0)
		begin
			set @error_msg = @p_column_name + ' must be greater than zero.'

			EXEC	dbo.xsp_upload_error_log_insert 
					@p_tabel_name					
			        ,@p_column_name					
			        ,@error_msg		
					,@p_primary_key
					--				
			        ,@p_cre_date					
			        ,@p_cre_by						
			        ,@p_cre_ip_address				
			        ,@p_mod_date					
			        ,@p_mod_by						
			        ,@p_mod_ip_address
		end
	end	

end



