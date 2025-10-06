/*
exec xsp_withholding_settlement_audit_proceed
*/
-- Louis Jumat, 02 Juni 2023 15.50.12 -- 
CREATE PROCEDURE [dbo].[xsp_withholding_settlement_audit_proceed]
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@request_code				  nvarchar(50)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@req_date					  datetime
			,@reff_dimension_code		  nvarchar(50)
			,@interface_remarks			  nvarchar(4000)
			,@dimension_code			  nvarchar(50)
			,@dim_value					  nvarchar(50)
			,@reff_approval_category_code nvarchar(50)
			,@total_amount				  decimal(18, 2)
			,@settlement_status			  nvarchar(50) = 'ALL'
			,@year						  int 
			,@path						  nvarchar(250)
			,@url_path					  nvarchar(250)
			,@approval_path				  nvarchar(4000)

	begin try
		
		if exists
		(
			select	1
			from	dbo.withholding_settlement_audit
			where	code		  = @p_code
					and status <> 'HOLD'
		)
		begin
			set @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if not exists
		(
			select	1
			from	dbo.invoice_pph
			where	audit_code = @p_code
		)
		begin
			set @msg = 'There are no Withholding Settlement transactions that have not been settled in ' +
					   (
						   select	cast(year as nvarchar(4))
						   from		dbo.withholding_settlement_audit
						   where	code = @p_code
					   ) ;

			raiserror(@msg, 16, 1) ;
		end ;
		 
		select	@year = year
		from	dbo.withholding_settlement_audit
		where	code = @p_code ;

		select	@total_amount = sum(invp.total_pph_amount)
		from	invoice inv
				inner join dbo.invoice_pph invp on (invp.invoice_no = inv.invoice_no)
		where	invp.settlement_status				 = case @settlement_status
														   when 'ALL' then invp.settlement_status
														   else @settlement_status
													   end
				and year(inv.invoice_date)			 = @year
				and isnull(invp.payment_reff_no, '') = '' ;

		if exists
		(
			select	1
			from	dbo.master_approval
			where	code			 = 'WHSAD'
					and is_active	 = '1'
		)
		begin
			select	@branch_code = branch_code
					,@branch_name = branch_name 
			from	dbo.withholding_settlement_audit
			where	code = @p_code ;

			update dbo.withholding_settlement_audit
			set		status			= 'ON PROCESS'
					,mod_by			= @p_mod_by
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
			where   code			= @p_code

			set @interface_remarks = 'Approval Withholding Settlement Audit' + ' ' + @p_code;

			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code = 'WHSAD' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'WHSAD'

			--set approval path
			set	@approval_path = @path + @p_code

			exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @request_code output
																,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= N'HOLD'
																,@p_request_date			= @req_date
																,@p_request_amount			= @total_amount
																,@p_request_remarks			= @interface_remarks
																,@p_reff_module_code		= N'IFINOPL'
																,@p_reff_no					= @p_code
																,@p_reff_name				= N'WITHHOLDING SETTLEMENT AUDIT APPROVAL'
																,@p_paths					= @approval_path
																,@p_approval_category_code	= @reff_approval_category_code
																,@p_approval_status			= N'HOLD'
																--
																,@p_cre_date				= @p_mod_date
																,@p_cre_by					= @p_mod_by
																,@p_cre_ip_address			= @p_mod_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address ;
					
			declare master_approval_dimension cursor for
			select  reff_dimension_code 
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'WHSAD'

			open master_approval_dimension		
			fetch next from master_approval_dimension
			into @reff_dimension_code 
					,@dimension_code
						
			while @@fetch_status = 0

			begin 

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
														  ,@p_reff_code		= @p_code
														  ,@p_reff_table	= 'WITHHOLDING_SETTLEMENT_AUDIT'
														  ,@p_output		= @dim_value output ;
 
				exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id				 = 0
																			 ,@p_request_code	 = @request_code
																			 ,@p_dimension_code	 = @reff_dimension_code
																			 ,@p_dimension_value = @dim_value
																			 --					 
																			 ,@p_cre_date		 = @p_mod_date
																			 ,@p_cre_by			 = @p_mod_by
																			 ,@p_cre_ip_address	 = @p_mod_ip_address
																			 ,@p_mod_date		 = @p_mod_date
																			 ,@p_mod_by			 = @p_mod_by
																			 ,@p_mod_ip_address	 = @p_mod_ip_address ;
						

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


