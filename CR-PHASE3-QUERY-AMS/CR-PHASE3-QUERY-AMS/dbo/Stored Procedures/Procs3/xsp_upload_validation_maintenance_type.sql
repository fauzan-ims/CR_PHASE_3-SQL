create procedure dbo.xsp_upload_validation_maintenance_type
(
	@p_column_name				nvarchar(250)
	,@p_value_check				nvarchar(4000)
	,@p_primary_key				nvarchar(250)
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
	
	declare @number_check numeric(18,2)
			,@error_msg	nvarchar(4000)

	-- Validasi Number Only
	begin
		
		if (@p_value_check not in ('DAY','MONTH','WEEK','YEAR'))
		begin
        
			set @error_msg = @p_column_name + ' Must be DAY or MONTH or WEEK or YEAR'

			exec	dbo.xsp_upload_error_log_insert 
					@p_column_name					
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
