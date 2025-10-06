CREATE procedure dbo.xsp_dashboard_get_asset_by_status
(
	@p_company_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		declare @temp_table table
		(
			total_data int
			,reff_name nvarchar(250)
		) ;

		insert into @temp_table
		(
			total_data
			,reff_name
		)
		select	count(1)
				,'NEW'
		from	dbo.asset
		where	status = 'NEW'
		union
		select	count(1)
				,'ON PROCESS'
		from	dbo.asset
		where	status = 'ON PROGRESS'
		union
		select	count(1)
				,'AVAILABLE'
		from	dbo.asset
		where	status = 'AVAILABLE'
		union
		select	count(1)
				,'REJECT'
		from	dbo.asset
		where	status = 'REJECT'
		union
		select	count(1)
				,'CANCEL'
		from	dbo.asset
		where	status = 'CANCEL'
		union
		select	count(1)
				,'DISPOSED'
		from	dbo.asset
		where	status = 'DISPOSED'
		union
		select	count(1)
				,'ON REPAIR'
		from	dbo.asset
		where	status = 'ON REPAIR'
		union
		select	count(1)
				,'ON SOLD'
		from	dbo.asset
		where	status = 'SOLD'
		union
		select	count(1)
				,'AVAILABLE-ON REPAIR'
		from	dbo.asset
		where	status = 'AVAILABLEONREPAIR' ;

		select	total_data
				,reff_name
				,'status' 'series_name'
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
