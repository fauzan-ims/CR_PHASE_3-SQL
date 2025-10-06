CREATE PROCEDURE dbo.xsp_agreement_asset_for_delivery_request_proceed
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
			,@system_date		  datetime      = dbo.xfn_get_system_date()
			,@delivery_to_code	  nvarchar(50)
			,@branch_code		  nvarchar(50)
			,@branch_name		  nvarchar(250)
			,@deliver_to_name	  nvarchar(250)
			,@deliver_to_area_no  nvarchar(4)
			,@deliver_to_phone_no nvarchar(15)
			,@deliver_to_address  nvarchar(4000) ;

	begin try
		begin
			select	@branch_code = am.branch_code
					,@branch_name = am.branch_name 
					,@deliver_to_name = aa.deliver_to_name
					,@deliver_to_area_no = aa.deliver_to_area_no
					,@deliver_to_phone_no = aa.deliver_to_phone_no
					,@deliver_to_address = aa.deliver_to_address  
			from	dbo.agreement_asset aa
					inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
			where	aa.asset_no = @p_asset_no ;
			
			if not exists
			(
				select	1
				from	dbo.asset_delivery
				where	status						= 'HOLD'
						and deliver_to_name			= @deliver_to_name 
						and deliver_to_area_no		= @deliver_to_area_no 
						and deliver_to_phone_no		= @deliver_to_phone_no 
						and deliver_to_address		= @deliver_to_address
						and branch_code				= @branch_code
			)
			begin  
				exec dbo.xsp_asset_delivery_insert @p_code					= @delivery_to_code output
												   ,@p_branch_code			= @branch_code
												   ,@p_branch_name			= @branch_name
												   ,@p_status				= N'HOLD'
												   ,@p_date					= @system_date
												   ,@p_remark				= N''
												   ,@p_deliver_to_name		= @deliver_to_name 
												   ,@p_deliver_to_area_no	= @deliver_to_area_no 
												   ,@p_deliver_to_phone_no	= @deliver_to_phone_no 
												   ,@p_deliver_to_address	= @deliver_to_address
												   ,@p_deliver_from			= N'INTERNAL' 
												   ,@p_deliver_by			= null  
												   ,@p_deliver_pic			= null  
												   ,@p_employee_code		= null
												   ,@p_employee_name		= null
												   --
												   ,@p_cre_date				= @p_cre_date	  
												   ,@p_cre_by				= @p_cre_by		  
												   ,@p_cre_ip_address		= @p_cre_ip_address
												   ,@p_mod_date				= @p_mod_date	  
												   ,@p_mod_by				= @p_mod_by		  
												   ,@p_mod_ip_address		= @p_mod_ip_address

				update	dbo.agreement_asset
				set		handover_status = 'ON PROCESS'
				where	asset_no = @p_asset_no ;
			end ;
			else
			begin 
				select	@delivery_to_code = code
				from	dbo.asset_delivery
				where	status						= 'HOLD'
						and deliver_to_name			= @deliver_to_name 
						and deliver_to_area_no		= @deliver_to_area_no 
						and deliver_to_phone_no		= @deliver_to_phone_no 
						and deliver_to_address		= @deliver_to_address
						and branch_code				= @branch_code
			end ; 

				exec dbo.xsp_asset_delivery_detail_insert @p_delivery_code		= @delivery_to_code
														  ,@p_asset_no			= @p_asset_no
														  ,@p_delivery_status	= N'HOLD'
														  ,@p_delivery_date		= null
														  ,@p_delivery_remark	= null
														  ,@p_receiver_name		= null
														  ,@p_unit_condition	= null
														  ,@p_file_name			= null
														  ,@p_file_path			= null
														  --
														  ,@p_cre_date			= @p_cre_date	  
														  ,@p_cre_by			= @p_cre_by		  
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date	  
														  ,@p_mod_by			= @p_mod_by		  
														  ,@p_mod_ip_address	= @p_mod_ip_address
		
				update	dbo.agreement_asset
				set		handover_status = 'ON PROCESS'
				where	asset_no = @p_asset_no ;
		end ;
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
