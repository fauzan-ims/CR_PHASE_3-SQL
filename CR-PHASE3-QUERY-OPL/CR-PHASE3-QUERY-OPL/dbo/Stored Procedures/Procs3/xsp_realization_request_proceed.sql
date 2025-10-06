CREATE PROCEDURE [dbo].[xsp_realization_request_proceed]
(
	@p_asset_no		   nvarchar(50) 
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				  nvarchar(max)
			,@application_no	  nvarchar(50)
			,@system_date		  datetime      = dbo.xfn_get_system_date()
			,@realization_code	  nvarchar(50)
			,@branch_code		  nvarchar(50)
			,@branch_name		  nvarchar(250)
			,@deliver_to_name	  nvarchar(250)
			,@deliver_to_area_no  nvarchar(4)
			,@deliver_to_phone_no nvarchar(15)
			,@deliver_to_address  nvarchar(4000) ;

	begin try
		begin
			if exists
			(
				select	1
				from	dbo.realization_detail rd
						inner join dbo.realization rz on (rz.code = rd.realization_code)
				where	asset_no	  = @p_asset_no
						and rz.status <> 'CANCEL'
			)
			begin
				set @msg = N'Data already proceed' ;

				raiserror(@msg, 16, 1) ;
			end ;

			select	@branch_code			= am.branch_code
					,@branch_name			= am.branch_name 
					,@deliver_to_name		= aa.deliver_to_name
					,@deliver_to_area_no	= aa.deliver_to_area_no
					,@deliver_to_phone_no	= aa.deliver_to_phone_no
					,@deliver_to_address	= aa.deliver_to_address  
					,@application_no		= aa.application_no
			from	dbo.application_asset aa
					inner join dbo.application_main am on (am.application_no = aa.application_no)
			where	aa.asset_no = @p_asset_no ;
			
			if not exists
			(
				select	1
				from	dbo.realization
				where	application_no	= @application_no 
						and status		= 'HOLD'
			)
			begin  

				exec dbo.xsp_realization_insert @p_code							= @realization_code output  
												,@p_branch_code					= @branch_code
												,@p_branch_name					= @branch_name
												,@p_status						= N'HOLD'
												,@p_date						= @system_date
												,@p_remark						= N'' 
												,@p_delivery_from				= N'INTERNAL' 
												,@p_delivery_pic_code			= null  
												,@p_delivery_pic_name			= null  
												,@p_delivery_vendor_name		= null
												,@p_delivery_vendor_pic_name	= null
												,@p_application_no				= @application_no
												,@p_result						= null
												,@p_agreement_date				= @system_date
												--
												,@p_cre_date					= @p_cre_date	  
												,@p_cre_by						= @p_cre_by		  
												,@p_cre_ip_address				= @p_cre_ip_address
												,@p_mod_date					= @p_mod_date	  
												,@p_mod_by						= @p_mod_by		  
												,@p_mod_ip_address				= @p_mod_ip_address 

				update	dbo.application_asset
				set		realization_code = @realization_code
						--
						,mod_date		 = @p_mod_date	  
						,mod_by			 = @p_mod_by		  
						,mod_ip_address	 = @p_mod_ip_address 
				where	asset_no		 = @p_asset_no ;

				exec dbo.xsp_realization_doc_generate @p_realization_code	= @realization_code, 
				                                      @p_cre_date			= @p_cre_date,		
				                                      @p_cre_by				= @p_cre_by,         
				                                      @p_cre_ip_address		= @p_cre_ip_address, 
				                                      @p_mod_date			= @p_mod_date,		
				                                      @p_mod_by				= @p_mod_by,         
				                                      @p_mod_ip_address		= @p_mod_ip_address  
				

				
			end ;
			else
			begin 
				select	@realization_code = code
				from	dbo.realization
				where	application_no	= @application_no 
						and status		= 'HOLD'
			end ; 

			exec dbo.xsp_realization_detail_insert @p_realization_code	= @realization_code
													,@p_asset_no		= @p_asset_no 
													--
													,@p_cre_date		= @p_cre_date	  
													,@p_cre_by			= @p_cre_by		  
													,@p_cre_ip_address	= @p_cre_ip_address
													,@p_mod_date		= @p_mod_date	  
													,@p_mod_by			= @p_mod_by		  
													,@p_mod_ip_address	= @p_mod_ip_address
		
			update	dbo.application_asset
			set		realization_code = @realization_code
					--
					,mod_date		 = @p_mod_date
					,mod_by			 = @p_mod_by
					,mod_ip_address  = @p_mod_ip_address
			where	asset_no		 = @p_asset_no ;
		end ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

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

