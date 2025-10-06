--Created, Jeff at 09-08-2023
CREATE PROCEDURE [dbo].[xsp_rpt_replacement_car_control]
(
	@p_user_id			nvarchar(50) = ''
	,@p_month			nvarchar(50)
	,@p_year			nvarchar(4)
    ,@p_is_condition    nvarchar(1)
)
as
BEGIN

	delete dbo.RPT_REPLACEMENT_CAR_CONTROL
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@max_date						decimal
			,@month_format					nvarchar(50)

	begin try
	
		SELECT	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		set	@report_title = 'Report Replacement Car Control';

		select @month_format = case
			when len(@p_month)=1 then '0'+@p_month
			else @p_month
		end

		select @max_date=day(eomonth(cast(@p_year+@month_format+'01' as datetime)));
	BEGIN
		insert into dbo.RPT_REPLACEMENT_CAR_CONTROL
		(
			USER_ID
			,REPORT_TITLE
			,REPORT_COMPANY
			,REPORT_IMAGE
			,PLAT_NO
			,CATEGORY
			,VEHICLE_TYPE
			,month
			,PERIOD_YEAR
			,YEAR
			,COLOR
			,CURRENT_PARKING_LOCATION
			,BREAKDOWN_DAYS
			,BREAKDOWN_PCT
			,IDLE_DAYS
			,IDLE_PCT
			,ACTIVE_DAYS
			,ACTIVE_PCT
		)
		SELECT  @p_user_id
				,@report_title
				,@report_company
				,@report_image
				,avi.plat_no
				,mit.registration_class_type
				,ass.item_name
				,case  @p_month
						when '1'  then 'Januari'
						when '2'  then 'Februari'
						when '3'  then 'Maret'
						when '4'  then 'April'
						when '5'  then 'Mei'
						when '6'  then 'Juni'
						when '7'  then 'Juli'
						when '8'  then 'Agustus'
						when '9'  then 'September'
						when '10' then 'Oktober'
						when '11' then 'November'
						when '12' then 'Desember'
				end
				,@p_year
				,avi.built_year
				,avi.colour
				,ass.parking_location
				,breakdown.jumlah
				,cast(breakdown.jumlah as decimal)/@max_date*100
				,idle.jumlah
				,cast(idle.jumlah as decimal)/@max_date*100
				,active.jumlah
				,cast(active.jumlah as decimal)/@max_date*100
		from ifinams.dbo.asset ass
		left join ifinams.dbo.asset_vehicle avi on avi.asset_code = ass.code
		left join ifinbam.dbo.master_item mit on mit.code = ass.item_code
		outer apply
		(
			select count(aag.AGING_DATE) 'jumlah'
			from ifinams.dbo.asset_aging aag
			where aag.CODE = ass.code
			and aag.wo_no is not null
			and month(aag.AGING_DATE) = @p_month
			and year(aag.AGING_DATE) = @p_year
		)breakdown
		outer apply
		(
			select count(aag.AGING_DATE) 'jumlah'
			from ifinams.dbo.asset_aging aag
			where aag.CODE = ass.code
			and aag.wo_no is null
			and aag.FISICAL_STATUS = 'ON HAND'
			and month(aag.AGING_DATE) = @p_month
			and year(aag.AGING_DATE) = @p_year
		)idle
		outer apply
		(
			select count(aag.AGING_DATE) 'jumlah'
			from ifinams.dbo.asset_aging aag
			where aag.CODE = ass.code
			and aag.wo_no is null
			and aag.FISICAL_STATUS = 'ON CUSTOMER'
			and month(aag.AGING_DATE) = @p_month
			and year(aag.AGING_DATE) = @p_year
		)active;
	end
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

