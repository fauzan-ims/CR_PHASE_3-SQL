CREATE PROCEDURE [dbo].[xsp_procurement_insert_item_group]
(
	@p_code							nvarchar(50)
	,@p_item_group_code				nvarchar(50)
	,@p_type_asset_code				nvarchar(50)
	,@p_item_category_code			nvarchar(50)
	,@p_item_category_name			nvarchar(250)
	,@p_item_merk_code				nvarchar(50)
	,@p_item_merk_name				nvarchar(250)
	,@p_item_model_code				nvarchar(50)
	,@p_item_model_name				nvarchar(250)
	,@p_item_type_code				nvarchar(50)
	,@p_item_type_name				nvarchar(250)
	,@p_procurement_request_code	nvarchar(50)
	,@p_company_code				nvarchar(50)
	,@p_date_flag					datetime
	,@p_type						nvarchar(50)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
	update	dbo.procurement
	set		item_group_code		= @p_item_group_code
			,type_asset_code	= @p_type_asset_code
			,item_category_code	= @p_item_category_code
			,item_category_name	= @p_item_category_name
			,item_merk_code		= @p_item_merk_code
			,item_merk_name		= @p_item_merk_name
			,item_model_code	= @p_item_model_code
			,item_model_name	= @p_item_model_name
			,item_type_code		= @p_item_type_code
			,item_type_name		= @p_item_type_name
			--				 
			,mod_date			= @p_mod_date
			,mod_by				= @p_mod_by
			,mod_ip_address		= @p_mod_ip_address
	where	code				= @p_code

	--Langsung execute SP Post karena sekarang tidak ada lagi Proceed - Post
	if(@p_type = 'WTQTN')
	begin
		exec dbo.xsp_procurement_post @p_code						= @p_code
									  ,@p_procurement_request_code	= @p_procurement_request_code
									  ,@p_company_code				= @p_company_code
									  ,@p_date_flag					= @p_date_flag
									  ,@p_mod_date					= @p_mod_date	  
									  ,@p_mod_by					= @p_mod_by		  
									  ,@p_mod_ip_address			= @p_mod_ip_address
	end
	else
	begin
		exec dbo.xsp_procurement_post_without_quotation @p_code							= @p_code
														,@p_procurement_request_code	= @p_procurement_request_code
														,@p_company_code				= @p_company_code
														,@p_date_flag					= @p_date_flag
														,@p_mod_date					= @p_mod_date	  
														,@p_mod_by						= @p_mod_by		  
														,@p_mod_ip_address				= @p_mod_ip_address
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
end ;
