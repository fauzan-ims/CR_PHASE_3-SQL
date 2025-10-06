CREATE PROCEDURE dbo.xsp_asset_maintenance_schedule_for_date_update
(
	@p_id				   bigint
	,@p_maintenance_date   datetime = null
	--
	,@p_mod_by			   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@asset_code			nvarchar(50)
			,@max_date				datetime
			,@reff_no				nvarchar(50)
			,@asset_code_date		nvarchar(50)
			,@asset_id				int
			,@count_diff_date		int
			,@min_date				datetime
			,@maintenance_date		datetime


	select	@asset_code = asset_code 
	from	dbo.asset_maintenance_schedule 
	where	id = @p_id ;

	select @min_date = min(maintenance_date) 
	from dbo.asset_maintenance_schedule
	where asset_code = @asset_code

	select @maintenance_date = maintenance_date 
	from dbo.asset_maintenance_schedule
	where id = @p_id

	if (@min_date <> @maintenance_date)
	begin
		if exists(select 1 from dbo.asset_maintenance_schedule where asset_code =  @asset_code and @p_maintenance_date < @min_date and id <> @p_id)
		begin
			set @msg = 'Date must greater than miniminum date.';
			raiserror(@msg, 16, -1) ;
		end
	end

	select	@max_date = max(maintenance_date)
	from	dbo.asset_maintenance_schedule
	where	asset_code		= @asset_code
			and reff_trx_no <> '' ;

	with cte (id, asset_code, countdiffdate) as
	(
		select	id
				,asset_code
				,datediff(day, maintenance_date, lag(maintenance_date, 1) over (order by id))
		from	dbo.asset_maintenance_schedule
		where	asset_code = @asset_code
	)
	select	@asset_code_date = cte.asset_code
			,@count_diff_date = cte.countdiffdate
	from	cte
	where	cte.id = @p_id ;

	--with cte (id,maintenance_date) as
	--(
	--	select	id
	--	,maintenance_date
	--	from dbo.asset_maintenance_schedule
	--	where id = (select top 1 id from dbo.asset_maintenance_schedule where id > @p_id and asset_code=@asset_code)
	--)
	--select	@asset_id = id
	--		,@asset_code_date = maintenance_date
	--from	cte
	--where	cte.id = @p_id ;

	--if @count_diff_date > 0
	--begin

	--	set @msg = 'Date must greater than the last maintenance.';
	
	--	raiserror(@msg, 16, -1) ;

	--end

	--if @asset_code_date > @p_maintenance_date
	--begin

	--	set @msg = 'Date must greater than the last maintenance.';
	
	--	raiserror(@msg, 16, -1) ;

	--end

	SELECT	@reff_no= REFF_TRX_NO 
	from	dbo.ASSET_MAINTENANCE_SCHEDULE 
	where	id=@p_id ;
	
	begin try

		if @reff_no = ''
		begin
			update	asset_maintenance_schedule
			set		maintenance_date		 = @p_maintenance_date
					--
					,mod_by					 = @p_mod_by
					,mod_date				 = @p_mod_date
					,mod_ip_address			 = @p_mod_ip_address
			where	id						 = @p_id ;

		end
		else
		begin
			
			update	asset_maintenance_schedule
			set		maintenance_date		 = @p_maintenance_date
					--
					,mod_by					 = @p_mod_by
					,mod_date				 = @p_mod_date
					,mod_ip_address			 = @p_mod_ip_address
			where	id						 = @p_id ;

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
