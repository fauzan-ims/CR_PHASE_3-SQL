CREATE PROCEDURE dbo.xsp_sppa_request_get_todo
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
					,@p_array_branch 'branch_name'
					,'PENDING SPPA REQUEST'
					,count(1) as count
		from		sppa_request sr
					inner join dbo.insurance_register ir on (ir.code = sr.register_code)
					inner join dbo.master_insurance mi on (mi.code	 = ir.insurance_code)
		where		sr.register_status = 'HOLD'
					and sr.CRE_BY	   = @p_user_id
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

