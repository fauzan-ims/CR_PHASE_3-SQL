CREATE PROCEDURE dbo.xsp_order_main_cancel_payment_proceed
(
	@p_code					nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
    
	declare @msg					nvarchar(max)
			,@order_status			nvarchar(20)
			,@system_date			datetime = dbo.xfn_get_system_date()
			,@remarks				nvarchar(4000)
			,@interface_code		nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@order_amount			decimal(18,2)
			,@public_service_name	nvarchar(250)

	begin try
	
		select	@order_status			= order_status
				,@branch_code			= branch_code
				,@branch_name			= branch_name
				,@order_amount			= order_amount
				,@public_service_name	= mps.public_service_name
		from	dbo.order_main om
			inner join dbo.master_public_service mps on mps.code = om.public_service_code
		where	om.code = @p_code
				
		set @remarks = 'REVERSE PAYMENT DP ORDER PUBLIC SERVICE ' + @branch_name + ' to ' + @public_service_name

		if @order_status <> 'PAID'
		begin
			set @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		end

		update	dbo.order_main
		set		order_status	= 'CANCEL REQUEST'
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code = @p_code
		
		exec dbo.xsp_pbs_interface_received_request_insert @p_code					= @interface_code output
		                                                   ,@p_branch_code			= @branch_code
		                                                   ,@p_branch_name			= @branch_name
		                                                   ,@p_received_source		= 'REVERSE DP PUBLIC SERVICE'
		                                                   ,@p_received_source_no	= @p_code
		                                                   ,@p_received_status		= 'HOLD' 
		                                                   ,@p_received_amount		= @order_amount
		                                                   ,@p_received_remarks		= @remarks
		                                                   ,@p_process_date			= null
		                                                   ,@p_process_reff_no		= null
		                                                   ,@p_process_reff_name	= null
			                                               ,@p_cre_date				= @p_cre_date
			                                               ,@p_cre_by				= @p_cre_by
			                                               ,@p_cre_ip_address		= @p_cre_ip_address
			                                               ,@p_mod_date				= @p_mod_date
			                                               ,@p_mod_by				= @p_mod_by
			                                               ,@p_mod_ip_address		= @p_mod_ip_address
		
	
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


