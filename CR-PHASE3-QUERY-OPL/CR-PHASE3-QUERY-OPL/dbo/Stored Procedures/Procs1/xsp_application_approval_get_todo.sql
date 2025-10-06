CREATE PROCEDURE dbo.xsp_application_approval_get_todo
(
	@p_todo_code	   nvarchar(50) = ''
	,@p_user_id		   nvarchar(50) = ''
	,@p_array_position varchar(max) = ''
	,@p_array_branch   varchar(max) = ''
)
as
begin
	declare @msg nvarchar(max) ;

	declare @temptable table
	(
		position_name nvarchar(250)
		,stringvalue  nvarchar(250)
	) ;

	if isnull(@p_array_position, '') = ''
	begin
		insert into @temptable
		(
			position_name
			,stringvalue
		)
		values
		(	'' -- position_code - nvarchar(50)
			,'' -- stringvalue - nvarchar(250)
		) ;
	end ;
	else
	begin
		insert into @temptable
		(
			position_name
			,stringvalue
		)
		select	name
				,stringvalue
		from	dbo.parsejson(@p_array_position) ;
	end ;

	begin try
		select		@p_todo_code 'todo_code'
					,branch_name
					,'APPLICATION APPROVAL'
					,count(1) as count
		from		application_main am
					inner join dbo.client_main cm on (cm.code			   = am.client_code)
					left join dbo.master_workflow mw on (mw.code		   = am.level_status)
					left join dbo.master_workflow_position mwp on (mw.code = mwp.workflow_code)
		where		am.application_status in
		(
			'ON PROCESS', 'APPROVE'
		)
					and am.level_status			  <> 'GO LIVE'
					and (
							mwp.position_code in
							(
								select	stringvalue
								from	@temptable
							)
							or	@p_array_position = ''
						)
		group by	branch_name ;
	end try
	Begin catch
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

