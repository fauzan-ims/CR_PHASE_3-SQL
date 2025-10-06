CREATE PROCEDURE dbo.xsp_application_main_get_next_level
(
	@p_application_no				nvarchar(50)
	,@p_workflow_code				nvarchar(50) OUTPUT
	,@p_is_approval					NVARCHAR(1) OUTPUT
	--
	,@p_mod_date					DATETIME
	,@p_mod_by						NVARCHAR(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin

	declare @msg					nvarchar(max)
			,@id					bigint
			,@application_flow_code nvarchar(50)
			,@level_status			nvarchar(20)
			,@order_key				int ;
	begin try
    
		select	@application_flow_code = isnull(ai.application_flow_code, '')
				,@level_status = am.level_status
		from	dbo.application_information ai
				inner join dbo.application_main am on (am.application_no = ai.application_no) 
		where   ai.application_no = @p_application_no ;


		if (@application_flow_code = '')
		begin		  
			exec dbo.xsp_dimension_get_data_match @p_code					= @application_flow_code OUTPUT,     
												  @p_reff_tabel_dimension	= N'MASTER_APPLICATION_FLOW', 
												  @p_reff_no				= @p_application_no,             
												  @p_reff_tabel_type		= 'APPLICATION',    
												  @p_reff_from_table		= 'APPLICATION_MAIN'

			if (isnull(@application_flow_code, '') = '')
			begin
				set @msg = 'Cannot find application flow setting';
				raiserror(@msg,18, 1)
			end

			update	dbo.application_information
			set		application_flow_code = @application_flow_code
			where	application_no = @p_application_no ;
		end ;

		if @level_status = 'ENTRY'
		begin
			if exists (select 1 from master_application_flow_detail where order_key < 0 and application_flow_code = @application_flow_code)
			begin
			    set @msg = 'Please setting Application Workflow';
				raiserror(@msg, 16,1)
			end

			select	@p_workflow_code = workflow_code
					,@p_is_approval = is_approval
			from	master_application_flow_detail
			where	application_flow_code = @application_flow_code
					and order_key		  = 1 ;
		end ;
		else
		begin
			select	@order_key = order_key
			from	master_application_flow_detail
			where	application_flow_code = @application_flow_code
					and workflow_code	  = @level_status ;

			select	@p_workflow_code = workflow_code
					,@p_is_approval = is_approval
			from	master_application_flow_detail
			where	application_flow_code = @application_flow_code
					and order_key		  = @order_key + 1 ;

			if (isnull(@p_workflow_code, '') = '')
			begin	
				set @p_workflow_code = 'GO LIVE';
			end
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

