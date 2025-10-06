CREATE PROCEDURE dbo.xsp_sale_upload_data_from_excel
(
	@p_company_code				 nvarchar(50)
	,@p_sale_date				 datetime
	,@p_description				 nvarchar(4000)	= ''
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)	= ''
	,@p_location_code			 nvarchar(50)
	,@p_buyer					 nvarchar(250)	= ''
	,@p_buyer_phone_no			 nvarchar(50)	= ''
	,@p_sale_amount				 decimal(18, 2)	= 0
	,@p_remark					 nvarchar(4000)	= ''
	,@p_status					 nvarchar(20)
	,@p_asset_code				 nvarchar(50)
	,@p_description_detail		 nvarchar(4000)	= ''
	,@p_sale_value				 decimal(18, 2)
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
		
		exec dbo.xsp_sale_upload_insert @p_code						 = @code output
										,@p_company_code			 = @p_company_code
										,@p_sale_date				 = @p_sale_date
										,@p_description				 = @p_description
										,@p_branch_code				 = @p_branch_code
										,@p_branch_name				 = @p_branch_name
										,@p_location_code			 = @p_location_code
										,@p_buyer					 = @p_buyer
										,@p_buyer_phone_no			 = @p_buyer_phone_no
										,@p_sale_amount				 = @p_sale_amount
										,@p_remark					 = @p_remark
										,@p_status					 = @p_status
										,@p_asset_code				 = @p_asset_code
										,@p_description_detail		 = @p_description_detail
										,@p_sale_value				 = @p_sale_value
										,@p_cre_date				 = @p_cre_date		
										,@p_cre_by					 = @p_cre_by			
										,@p_cre_ip_address			 = @p_cre_ip_address	
										,@p_mod_date				 = @p_mod_date		
										,@p_mod_by					 = @p_mod_by			
										,@p_mod_ip_address			 = @p_mod_ip_address	
			
		
		
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
