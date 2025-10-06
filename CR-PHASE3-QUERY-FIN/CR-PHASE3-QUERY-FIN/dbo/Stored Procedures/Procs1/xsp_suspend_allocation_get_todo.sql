CREATE PROCEDURE dbo.xsp_suspend_allocation_get_todo
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
					,sa.branch_name
					,'PENDING SUSPEND ALLOCATION'
					,count(1) as count
		from		suspend_allocation sa
					inner join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
		where		sa.allocation_status = 'HOLD'
					and sa.cre_by		 = @p_user_id
		group by	sa.branch_name ;
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
