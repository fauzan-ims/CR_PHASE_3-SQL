CREATE PROCEDURE dbo.xsp_workflow_input_result_insert
(
	@p_code						nvarchar(50)	output
	,@p_code1					nvarchar(50)	= null
	,@p_flow_type				nvarchar(15)	= null
	,@p_reff_code				nvarchar(50)	= null
	,@p_recommendation_status	nvarchar(20)	= null
	,@p_cp_remarks				nvarchar(250)	= null
	,@p_ca_remarks				nvarchar(250)	= null
	,@p_ca_capacity				nvarchar(4000)	= null
	,@p_ca_capital				nvarchar(4000)	= null
	,@p_ca_condition			nvarchar(4000)	= null
	,@p_ca_collateral			nvarchar(4000)	= null
	,@p_ca_constraints			nvarchar(4000)	= null
	,@p_po_remarks				nvarchar(250)	= null
	,@p_printing_remarks		nvarchar(250)	= null
	,@p_signer_remarks			nvarchar(250)	= null
	,@p_fc_receive_date			datetime		= null
	,@p_fc_received_by			nvarchar(15)	= null
	,@p_fc_received_by_relation	nvarchar(15)	= null
	,@p_fc_date_installment		nvarchar(15)	= null
	,@p_fc_unit_condition		nvarchar(250)	= null
	,@p_fc_remarks				nvarchar(250)	= null
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@year						nvarchar(2)
			,@month						nvarchar(2)
			,@code						nvarchar(50)
			,@recommend_id				bigint
			,@application_status		nvarchar(20)
			,@plafond_status			nvarchar(20)
			,@drawdown_status			nvarchar(20)
			,@branch_code				nvarchar(50)
			,@p_id						bigint 
			,@employee_position_name	nvarchar(250)
			,@return_count				nvarchar(10)
			,@remarks					nvarchar(4000);


	begin try

		set @remarks = isnull(@p_cp_remarks, '')+ isnull(@p_ca_remarks, '') + isnull(@p_po_remarks, '') + isnull(@p_printing_remarks, '') + isnull(@p_signer_remarks, '') + isnull(@p_fc_remarks, '')
		
		if exists
		(
			select	1
			from	workflow_input_result
			where	reff_code = @p_reff_code
					and code  = @p_code1
		)
		begin
			update	workflow_input_result
			set		recommendation_status		= @p_recommendation_status
					,cp_remarks					= @p_cp_remarks			
					,ca_remarks					= @p_ca_remarks		
					,ca_capacity				= @p_ca_capacity
					,ca_capital					= @p_ca_capital
					,ca_condition				= @p_ca_condition
					,ca_collateral				= @p_ca_collateral
					,ca_constraints				= @p_ca_constraints	
					,po_remarks					= @p_po_remarks			
					,printing_remarks			= @p_printing_remarks	
					,signer_remarks				= @p_signer_remarks		
					,fc_receive_date			= @p_fc_receive_date
					,fc_received_by				= @p_fc_received_by
					,fc_received_by_relation	= @p_fc_received_by_relation
					,fc_date_installment		= @p_fc_date_installment
					,fc_unit_condition			= @p_fc_unit_condition
					,fc_remarks					= @p_fc_remarks
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code1;
		end ;
		else

		begin
			set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
			set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
														,@p_branch_code = ''
														,@p_sys_document_code = N''
														,@p_custom_prefix = 'WIR'
														,@p_year = @year
														,@p_month = @month
														,@p_table_name = 'WORKFLOW_INPUT_RESULT'
														,@p_run_number_length = 6
														,@p_delimiter = '.'
														,@p_run_number_only = N'0' ;

			insert into dbo.workflow_input_result
			(
				code
				,flow_type
				,reff_code
				,recommendation_status
				,cp_remarks
				,ca_remarks
				,ca_capacity
				,ca_capital
				,ca_condition
				,ca_collateral
				,ca_constraints
				,po_remarks
				,printing_remarks
				,signer_remarks
				,fc_receive_date
				,fc_received_by
				,fc_received_by_relation
				,fc_date_installment
				,fc_unit_condition
				,fc_remarks
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@code
				,@p_flow_type
				,@p_reff_code
				,isnull(@p_recommendation_status, '')
				,@p_cp_remarks
				,@p_ca_remarks
				,@p_ca_capacity
				,@p_ca_capital
				,@p_ca_condition
				,@p_ca_collateral
				,@p_ca_constraints
				,@p_po_remarks
				,@p_printing_remarks
				,@p_signer_remarks
				,@p_fc_receive_date
				,@p_fc_received_by
				,@p_fc_received_by_relation
				,@p_fc_date_installment
				,@p_fc_unit_condition
				,@p_fc_remarks
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			set @p_code = @code ;
		end ;

		if (@p_flow_type = 'APPLICATION')
		begin
			select	@application_status	= level_status 
					,@return_count		= return_count
			from	dbo.application_main 
			where	application_no		= @p_reff_code

			if exists
			(
				select	1
				from	application_recomendation
				where	application_no	 = @p_reff_code
						and level_status = @application_status
						and cycle		 = @return_count + 1
			)
			begin
				update	application_recomendation
				set		recomendation_result = isnull(@p_recommendation_status, '')
						,remarks = @remarks
				where	application_no	 = @p_reff_code
						and level_status = @application_status
						and cycle		 = @return_count + 1 ;
			end ;
			else
			begin
				exec dbo.xsp_application_recomendation_insert @p_id							= @p_id output 
															  ,@p_application_no			= @p_reff_code
															  ,@p_recomendation_result		= @p_recommendation_status
															  ,@p_recomendation_date		= @p_cre_date
															  ,@p_employee_code				= @p_cre_by
															  ,@p_employee_name				= @p_cre_by
															  ,@p_level_status				= @application_status
															  ,@p_remarks					= @remarks
															  ,@p_cre_date					= @p_cre_date
															  ,@p_cre_by					= @p_cre_by
															  ,@p_cre_ip_address			= @p_cre_ip_address
															  ,@p_mod_date					= @p_mod_date
															  ,@p_mod_by					= @p_mod_by
															  ,@p_mod_ip_address			= @p_mod_ip_address
			end	
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

