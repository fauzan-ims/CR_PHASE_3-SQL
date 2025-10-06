CREATE PROCEDURE dbo.xsp_schedule_maintenance_asset_generate
(
	@p_code			   nvarchar(50)
	--
	,@p_cre_by		   nvarchar(15)
	,@p_cre_date	   datetime
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_by		   nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@code					 nvarchar(50)
			,@usefull				 int
			,@maintenance_time		 int
			,@date_purc				 datetime
			,@maintenance_date		 datetime
			,@maintenance_type		 nvarchar(50)
			,@maintenance_cycle_time int
			,@asset_no				 nvarchar(10)
			,@maintenance_no		 int		  = 0
			,@counter_cycle			 int
			,@counter				 int
			,@week					 int
			,@day					 int ;

	begin try
		if exists
		(
			select	1
			from	dbo.asset_maintenance_schedule
			where	asset_code			   = @p_code
					and maintenance_status = 'DONE'
		)
		begin
			set @msg = 'Generate failed. data already proceed.';
			--set @msg = 'Generate failed. There are already processed data';
			raiserror(@msg ,16,-1);
		end ;

		delete dbo.asset_maintenance_schedule
		where	asset_code = @p_code ;

		select	@code						 = ass.code
				,@maintenance_time			 = maintenance_time
				,@maintenance_type			 = maintenance_type
				,@maintenance_cycle_time	 = ass.maintenance_cycle_time
				,@date_purc					 = isnull(maintenance_start_date, null)
				,@usefull					 = mdc.usefull
		from	dbo.asset ass
				inner join dbo.master_depre_category_commercial mdc on (mdc.code = ass.depre_category_comm_code) and (mdc.company_code = ass.company_code)
		where	ass.code = @p_code ;

		if (@date_purc is null or @date_purc = '')
		begin
			--set @msg = 'Mohon isi Maintenance Start Date.';
			set @msg = 'Please fill Maintenance Start Date';
			raiserror(@msg ,16,-1);
		end


		select	@maintenance_no = min(maintenance_no)
		from	dbo.asset_maintenance_schedule
		where	asset_code = @asset_no ;

		if @maintenance_type = 'MONTH'
		begin
			set @usefull = (@usefull * 12) / @maintenance_cycle_time ;
			set @maintenance_date = dateadd(month, @maintenance_cycle_time, cast(@date_purc as date)) ;
			set @counter = 1 ;

			while (@counter <= @usefull)
			begin
				set @counter_cycle = 1 ;

				while (@counter_cycle <= @maintenance_time)
				begin
					set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;
					

					exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																   ,@p_asset_code			 = @p_code
																   ,@p_maintenance_no		 = @maintenance_no
																   ,@p_maintenance_date		 = @maintenance_date
																   ,@p_maintenance_status	 = 'NOT DUE'
																   ,@p_last_status_date		 = @p_cre_date
																   ,@p_reff_trx_no			 = @msg --''
																   ,@p_miles				 = 0
																   ,@p_month				 = 0
																   ,@p_hour					 = 0
																   ,@p_cre_by				 = @p_cre_by
																   ,@p_cre_date				 = @p_cre_date
																   ,@p_cre_ip_address		 = @p_cre_ip_address
																   ,@p_mod_by				 = @p_mod_by
																   ,@p_mod_date				 = @p_mod_date
																   ,@p_mod_ip_address		 = @p_mod_ip_address

					set @maintenance_date = dateadd(month, @maintenance_cycle_time, cast(@maintenance_date as date)) ;
					set @counter_cycle = @counter_cycle + 1 ;
				end ;

				set @counter = @counter + 1 ;
			end ;
		end ;
		else if @maintenance_type = 'WEEK'
		begin
			set @week = 52 ;
			set @usefull = (@usefull * @week) / @maintenance_cycle_time ;
			set @maintenance_date = dateadd(week, @maintenance_cycle_time, cast(@date_purc as date)) ;
			set @counter = 1 ;

			while (@counter <= @usefull)
			begin
				set @counter_cycle = 1 ;

				while (@counter_cycle <= @maintenance_time)
				begin
					set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;

					exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																   ,@p_asset_code			 = @p_code
																   ,@p_maintenance_no		 = @maintenance_no
																   ,@p_maintenance_date		 = @maintenance_date
																   ,@p_maintenance_status	 = 'NOT DUE'
																   ,@p_last_status_date		 = @p_cre_date
																   ,@p_reff_trx_no			 = @msg --''
																   ,@p_miles				 = 0
																   ,@p_month				 = 0
																   ,@p_hour					 = 0
																   ,@p_cre_by				 = @p_cre_by
																   ,@p_cre_date				 = @p_cre_date
																   ,@p_cre_ip_address		 = @p_cre_ip_address
																   ,@p_mod_by				 = @p_mod_by
																   ,@p_mod_date				 = @p_mod_date
																   ,@p_mod_ip_address		 = @p_mod_ip_address

					set @maintenance_date = dateadd(week, @maintenance_cycle_time, cast(@maintenance_date as date)) ;
					set @counter_cycle = @counter_cycle + 1 ;
				end ;

				set @counter = @counter + 1 ;
			end ;
		end ;
		else if @maintenance_type = 'DAY'
		begin
			set @day = datepart(dayofyear, dateadd(day, -1, '1/1/' + convert(char(4), datepart(year, @date_purc) + 1))) ;
			set @usefull = (@usefull * @day) / @maintenance_cycle_time ;
			set @maintenance_date = dateadd(day, @maintenance_cycle_time, cast(@date_purc as date)) ;
			set @counter = 1 ;

			while (@counter <= @usefull)
			begin
				set @counter_cycle = 1 ;

				while (@counter_cycle <= @maintenance_time)
				begin
					set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;

					exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																   ,@p_asset_code			 = @p_code
																   ,@p_maintenance_no		 = @maintenance_no
																   ,@p_maintenance_date		 = @maintenance_date
																   ,@p_maintenance_status	 = 'NOT DUE'
																   ,@p_last_status_date		 = @p_cre_date
																   ,@p_reff_trx_no			 = @msg --''
																   ,@p_miles				 = 0
																   ,@p_month				 = 0
																   ,@p_hour					 = 0
																   ,@p_cre_by				 = @p_cre_by
																   ,@p_cre_date				 = @p_cre_date
																   ,@p_cre_ip_address		 = @p_cre_ip_address
																   ,@p_mod_by				 = @p_mod_by
																   ,@p_mod_date				 = @p_mod_date
																   ,@p_mod_ip_address		 = @p_mod_ip_address

					set @maintenance_date = dateadd(day, @maintenance_cycle_time, cast(@maintenance_date as date)) ;
					set @counter_cycle = @counter_cycle + 1 ;
				end ;

				set @counter = @counter + 1 ;
			end ;
		end ;
		else if @maintenance_type = 'YEAR'
		begin
			set @maintenance_date = dateadd(year, @maintenance_cycle_time, cast(@date_purc as date)) ;
			set @counter = 1 ;

			while (@counter <= @usefull)
			begin
				set @counter_cycle = 1 ;

				while (@counter_cycle <= @maintenance_time)
				begin
					set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;

					exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																   ,@p_asset_code			 = @p_code
																   ,@p_maintenance_no		 = @maintenance_no
																   ,@p_maintenance_date		 = @maintenance_date
																   ,@p_maintenance_status	 = 'NOT DUE'
																   ,@p_last_status_date		 = @p_cre_date
																   ,@p_reff_trx_no			 = @msg --''
																   ,@p_miles				 = 0
																   ,@p_month				 = 0
																   ,@p_hour					 = 0
																   ,@p_cre_by				 = @p_cre_by
																   ,@p_cre_date				 = @p_cre_date
																   ,@p_cre_ip_address		 = @p_cre_ip_address
																   ,@p_mod_by				 = @p_mod_by
																   ,@p_mod_date				 = @p_mod_date
																   ,@p_mod_ip_address		 = @p_mod_ip_address

					set @maintenance_date = dateadd(year, @maintenance_cycle_time, cast(@maintenance_date as date)) ;
					set @counter_cycle = @counter_cycle + 1 ;
				end ;

				set @counter = @counter + 1 ;
			end ;
		end ;
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
