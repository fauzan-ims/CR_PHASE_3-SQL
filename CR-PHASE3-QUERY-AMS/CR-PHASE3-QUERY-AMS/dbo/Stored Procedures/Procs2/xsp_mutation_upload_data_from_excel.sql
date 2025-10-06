CREATE PROCEDURE dbo.xsp_mutation_upload_data_from_excel
(
	--@p_code						 nvarchar(50)
	@p_company_code			 nvarchar(50)
	,@p_mutation_date			 datetime
	,@p_requestor_code			 nvarchar(50)
	,@p_branch_request_code		 nvarchar(50)
	,@p_branch_request_name		 nvarchar(250)
	,@p_from_branch_code		 nvarchar(50)	= ''
	,@p_from_branch_name		 nvarchar(250)	= ''
	,@p_from_division_code		 nvarchar(50)	= ''
	,@p_from_division_name		 nvarchar(250)	= ''
	,@p_from_department_code	 nvarchar(50)	= ''
	,@p_from_department_name	 nvarchar(250)	= ''
	,@p_from_sub_department_code nvarchar(50)	= ''
	,@p_from_sub_department_name nvarchar(250)	= ''
	,@p_from_units_code			 nvarchar(50)	= ''
	,@p_from_units_name			 nvarchar(250)	= ''
	,@p_from_location_code		 nvarchar(50)	= ''
	,@p_from_pic_code			 nvarchar(50)	= ''
	,@p_to_branch_code			 nvarchar(50)
	,@p_to_branch_name			 nvarchar(250)
	,@p_to_division_code		 nvarchar(50)
	,@p_to_division_name		 nvarchar(250)
	,@p_to_department_code		 nvarchar(50)
	,@p_to_department_name		 nvarchar(250)
	,@p_to_sub_department_code	 nvarchar(50)
	,@p_to_sub_department_name	 nvarchar(250)
	,@p_to_units_code			 nvarchar(50)
	,@p_to_units_name			 nvarchar(250)
	,@p_to_location_code		 nvarchar(50)
	,@p_to_pic_code				 nvarchar(50)
	,@p_status					 nvarchar(20)
	,@p_remark					 nvarchar(4000)
	,@p_asset_code				 nvarchar(50)
	,@p_description				 nvarchar(4000)	= ''
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	
	declare @msg				nvarchar(max)
			,@year				nvarchar(4)
			,@month				nvarchar(2)
			,@code				nvarchar(50);
			            
	begin try	
		
		exec dbo.xsp_mutation_upload_insert @p_code								 = @code output
											,@p_company_code					 = @p_company_code
											,@p_mutation_date					 = @p_mutation_date
											,@p_requestor_code					 = @p_requestor_code
											,@p_branch_request_code				 = @p_branch_request_code
											,@p_branch_request_name				 = @p_branch_request_name
											,@p_from_branch_code				 = @p_from_branch_code
											,@p_from_branch_name				 = @p_from_branch_name
											,@p_from_division_code				 = @p_from_division_code
											,@p_from_division_name				 = @p_from_division_name
											,@p_from_department_code			 = @p_from_department_code
											,@p_from_department_name			 = @p_from_department_name
											,@p_from_sub_department_code		 = @p_from_sub_department_code
											,@p_from_sub_department_name		 = @p_from_sub_department_name
											,@p_from_units_code					 = @p_from_units_code
											,@p_from_units_name					 = @p_from_units_name
											,@p_from_location_code				 = @p_from_location_code
											,@p_from_pic_code					 = @p_from_pic_code
											,@p_to_branch_code					 = @p_to_branch_code
											,@p_to_branch_name					 = @p_to_branch_name
											,@p_to_division_code				 = @p_to_division_code
											,@p_to_division_name				 = @p_to_division_name
											,@p_to_department_code				 = @p_to_department_code
											,@p_to_department_name				 = @p_to_department_name
											,@p_to_sub_department_code			 = @p_to_sub_department_code
											,@p_to_sub_department_name			 = @p_to_sub_department_name
											,@p_to_units_code					 = @p_to_units_code
											,@p_to_units_name					 = @p_to_units_name
											,@p_to_location_code				 = @p_to_location_code
											,@p_to_pic_code						 = @p_to_pic_code
											,@p_status							 = @p_status
											,@p_remark							 = @p_remark
											,@p_asset_code						 = @p_asset_code
											,@p_description						 = @p_description
											,@p_cre_date						 = @p_cre_date		
											,@p_cre_by							 = @p_cre_by			
											,@p_cre_ip_address					 = @p_cre_ip_address
											,@p_mod_date						 = @p_mod_date		
											,@p_mod_by							 = @p_mod_by			
											,@p_mod_ip_address					 = @p_mod_ip_address
		
		
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
