--created by, Rian at 09/06/2023 

CREATE PROCEDURE [dbo].[xsp_deposit_allocation_proceed]
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@request_code					nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@client_name					nvarchar(250)
			,@agreement_external_no			nvarchar(50)
			,@interface_remarks				nvarchar(4000)
			,@req_date						datetime
			,@reff_approval_category_code	nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@request_amount				decimal(18,2)
			,@path							nvarchar(250)
			,@url_path						nvarchar(250)
			,@approval_path					nvarchar(4000)

	begin try
		if exists
		(
			select	1
			from	dbo.deposit_allocation
			where	code				  = @p_code
					and allocation_status <> 'HOLD'
		)
		begin
			set	@msg = 'Data Already Proceed.'
			raiserror (@msg, 16, -1)
		end
		
		if (	
					(select isnull(allocation_base_amount,0) from dbo.deposit_allocation where code = @p_code) <> 
					(select isnull(sum(base_amount),0) from dbo.deposit_allocation_detail where deposit_allocation_code = @p_code)
				)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Total Amount','Base Amount');
			raiserror(@msg ,16,-1)
		end

		if exists
		(
			select	1
			from	dbo.deposit_allocation
			where	code				  = @p_code
					and	isnull(allocation_currency_code, '') = ''
		)
		begin
			set	@msg = 'Please Insert Deposit Allocation Detail.'
			raiserror (@msg, 16, -1)
		end

		if exists
		(
			select	1
			from	dbo.master_approval
			where	code = 'DEPOSIT ALLOCATION'
		)
		begin

			select	@branch_code			= da.branch_code
					,@branch_name			= da.branch_name
					,@client_name			= am.client_name
					,@agreement_external_no	= am.agreement_external_no
					,@request_amount		= da.allocation_base_amount
			from	dbo.deposit_allocation da
					inner join dbo.agreement_main am on (am.agreement_no = da.agreement_no)
			where	da.code = @p_code ;

			update	dbo.deposit_allocation
			set		allocation_status = 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code

			set @interface_remarks = 'Approval Deposit Allocation: ' + @p_code + ' - '  + @agreement_external_no + ' - ' + @client_name ;
			set @req_date = dbo.xfn_get_system_date() ;


			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'DEPOSIT ALLOCATION' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'DEPOSIT'
			
			--set approval path
			set	@approval_path = @path + @p_code
	
			exec dbo.xsp_fin_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_request_status			= N'HOLD'
															   ,@p_request_date				= @req_date
															   ,@p_request_amount			= @request_amount
															   ,@p_request_remarks			= @interface_remarks
															   ,@p_reff_module_code			= N'IFINFIN'
															   ,@p_reff_no					= @p_code
															   ,@p_reff_name				= N'DEPOSIT ALLOCATION'
															   ,@p_paths					= @approval_path
															   ,@p_approval_category_code	= @reff_approval_category_code
															   ,@p_approval_status			= N'HOLD'
															   --
															   ,@p_cre_date					= @p_mod_date
															   ,@p_cre_by					= @p_mod_by
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address
			
				declare master_approval_dimension cursor for
				select  reff_dimension_code 
						,dimension_code
				from	dbo.master_approval_dimension
				where	approval_code = 'DEPOSIT ALLOCATION'

				open master_approval_dimension		
				fetch next from master_approval_dimension
				into @reff_dimension_code 
					 ,@dimension_code
						
				while @@fetch_status = 0

				begin 

					exec dbo.xsp_get_table_value_by_dimension @p_dim_code	 = @dimension_code
															  ,@p_reff_code	 = @p_code
															  ,@p_reff_table = 'DEPOSIT_ALLOCATION'
															  ,@p_output	 = @dim_value output ;
 
					exec dbo.xsp_fin_interface_approval_request_dimension_insert @p_id					= 0
																				 ,@p_request_code		= @request_code
																				 ,@p_dimension_code		= @reff_dimension_code
																				 ,@p_dimension_value	= @dim_value
																				 --
																				 ,@p_cre_date			= @p_mod_date
																				 ,@p_cre_by				= @p_mod_by
																				 ,@p_cre_ip_address		= @p_mod_ip_address
																				 ,@p_mod_date			= @p_mod_date
																				 ,@p_mod_by				= @p_mod_by
																				 ,@p_mod_ip_address		= @p_mod_ip_address ;
						

				fetch next from master_approval_dimension
				into @reff_dimension_code
					,@dimension_code
				end
						
				close master_approval_dimension
				deallocate master_approval_dimension 
		end
		else
		begin
			set @msg = 'Please setting Master Approval';
			raiserror(@msg, 16, 1) ;
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
end
