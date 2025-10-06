CREATE procedure dbo.xsp_dashboard_get_quotation
(
	@p_company_code nvarchar(50)
)
as
begin
	declare @msg		  nvarchar(max)
			,@branch_code nvarchar(50)
			,@branch_name nvarchar(250) ;

	begin try
		declare cursor_name cursor fast_forward read_only for
		select	code
				,description
		from	ifinsys.dbo.master_branch
		where	company_code = @p_company_code ;

		open cursor_name ;

		fetch next from cursor_name
		into @branch_code
			 ,@branch_name ;

		while @@fetch_status = 0
		begin
			declare @temp_table table
			(
				total_data decimal(18, 2)
				,reff_name nvarchar(250)
			) ;

			insert into @temp_table
			(
				total_data
				,reff_name
			)
			select	count(1)
					,@branch_name
			from	dbo.quotation
			where	status			= 'NEW'
					and branch_code = @branch_code ;

			fetch next from cursor_name
			into @branch_code
				 ,@branch_name ;
		end ;

		close cursor_name ;
		deallocate cursor_name ;

		select	total_data
				,reff_name
				,'Branch' 'series_name'
		from	@temp_table ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
