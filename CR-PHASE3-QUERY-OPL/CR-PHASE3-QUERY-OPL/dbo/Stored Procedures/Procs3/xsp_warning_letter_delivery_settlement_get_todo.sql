CREATE PROCEDURE dbo.xsp_warning_letter_delivery_settlement_get_todo
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
					,branch_name
					,'PENDING WARNING LETTER DELIVERY SETTLEMENT'
					,count(1) as count
		from		warning_letter_delivery wld
					left join dbo.sys_general_subcode sgs on (sgs.code = wld.delivery_courier_code)
					left join dbo.master_collector mc on (mc.code = wld.delivery_collector_code)
					outer apply
					(
						select	count(1) 'count_row'
						from	dbo.warning_letter_delivery_detail wldd
						where	wldd.delivery_code = wld.code
					) detail
		where		wld.delivery_status in
					(
						'ON PROCESS'
					)
					and mc.collector_emp_code = @p_user_id
		group by	branch_name ;
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
