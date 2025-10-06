CREATE PROCEDURE dbo.xsp_task_history_update
(
	@p_id							   bigint
	,@p_task_date					   datetime
	,@p_desk_collector_code			   nvarchar(50)
	,@p_deskcoll_main_id			   bigint
	,@p_field_collector_code		   nvarchar(50) 
	,@p_agreement_no				   nvarchar(50)
	,@p_last_paid_installment_no	   nvarchar(50)
	,@p_installment_due_date		   datetime
	,@p_overdue_period				   int
	,@p_overdue_days				   int
	,@p_overdue_penalty_amount		   decimal(18, 2)
	,@p_overdue_installment_amount	   decimal(18, 2)
	,@p_outstanding_installment_amount decimal(18, 2)
	,@p_outstanding_deposit_amount	   decimal(18, 2)
	--
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	task_history
		set		task_date						= @p_task_date
				,desk_collector_code			= @p_desk_collector_code
				,deskcoll_main_id				= @p_deskcoll_main_id
				,field_collector_code			= @p_field_collector_code 
				,agreement_no					= @p_agreement_no
				,last_paid_installment_no		= @p_last_paid_installment_no
				,installment_due_date			= @p_installment_due_date
				,overdue_period					= @p_overdue_period
				,overdue_days					= @p_overdue_days
				,overdue_penalty_amount			= @p_overdue_penalty_amount
				,overdue_installment_amount		= @p_overdue_installment_amount
				,outstanding_installment_amount = @p_outstanding_installment_amount
				,outstanding_deposit_amount		= @p_outstanding_deposit_amount
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id ;
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
