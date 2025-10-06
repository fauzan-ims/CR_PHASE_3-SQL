CREATE PROCEDURE dbo.xsp_master_coverage_upload_data_from_excel
(
	@p_code								nvarchar(50)
	,@p_coverage_name					nvarchar(250)
	,@p_coverage_short_name				nvarchar(50)
	,@p_is_main_coverage				nvarchar(1)
	,@p_insurance_type					nvarchar(10)
	,@p_is_active						nvarchar(1)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into master_coverage
		(
			code
			,coverage_name		
			,coverage_short_name	
			,is_main_coverage	
			,insurance_type		
			,is_active			
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code					
			,@p_coverage_name		
			,@p_coverage_short_name	
			,@p_is_main_coverage	
			,@p_insurance_type		
			,@p_is_active	
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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


