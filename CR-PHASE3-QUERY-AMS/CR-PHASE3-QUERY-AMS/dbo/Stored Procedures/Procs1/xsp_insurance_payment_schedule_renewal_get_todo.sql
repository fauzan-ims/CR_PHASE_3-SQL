CREATE PROCEDURE dbo.xsp_insurance_payment_schedule_renewal_get_todo
(
	@p_todo_code	   nvarchar(50) = ''
	,@p_user_id		   nvarchar(50) = ''
	,@p_array_position varchar(max) = ''
	,@p_array_branch   varchar(max) = ''
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		select		@p_todo_code 'todo_code'
					,ipm.branch_name
					,'PENDING PAYMENT RENEWAL'
					,count(1) as count
		from		insurance_payment_schedule_renewal ipsr
					inner join dbo.insurance_policy_main ipm on (ipm.code = ipsr.policy_code)
					inner join dbo.master_insurance mi on (mi.code		  = ipm.insurance_code)
		where		payment_renual_status = 'ON PROCESS'
					and ipm.cre_by		  = @p_user_id
		group by	branch_name ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
