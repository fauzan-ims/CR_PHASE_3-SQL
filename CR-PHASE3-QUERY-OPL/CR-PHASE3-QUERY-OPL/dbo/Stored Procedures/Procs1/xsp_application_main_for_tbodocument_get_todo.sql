CREATE PROCEDURE dbo.xsp_application_main_for_tbodocument_get_todo
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
					,'TBO APPLICATION'
					,count(1) as count
		from		application_main ap
					inner join dbo.client_main cm on (cm.code = ap.client_code)
					inner join dbo.master_facility mf on (mf.code = ap.facility_code)
					left join dbo.master_workflow mw on (mw.code = ap.level_status)
					outer apply
		(
			select top 1
					promise_date
			from	dbo.application_doc
			where	promise_date is not null
					and is_required = '1'
		) ad
					outer apply
		(
			select top 1
					aad.promise_date
			from	dbo.application_asset_doc aad
					left join dbo.application_asset aa on (aa.asset_no		= aad.asset_no)
					left join dbo.application_main am on (am.application_no = aa.application_no)
			where	aad.promise_date is not null
					and is_required = '1'
		) aad 
		where		application_status	  = 'HOLD'
					and ap.marketing_code = @p_user_id
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

