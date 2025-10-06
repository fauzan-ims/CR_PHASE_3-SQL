
CREATE procedure dbo.xsp_generate_reminder_data
(
	@p_mail_file_name	nvarchar(100)
)
as
begin
	
	declare	@item_code				nvarchar(10)
			,@email_notif_code		nvarchar(50)
			,@reminder_maintenance	int
			,@eod					datetime = dbo.xfn_get_system_date()
			,@save_file_name		nvarchar(250)
			,@save_file_path		nvarchar(250)
			,@sql_script			nvarchar(max)
			,@values				nvarchar(max)
			,@id					int
			,@start_days			int
			,@end_days				int
			,@reminder_type			nvarchar(50)
			,@item_group_code		nvarchar(10)
			,@asset_code			nvarchar(50)
	
	
	declare @maintenance_schedule table
	(
		Location			nvarchar(250),
		Asset				nvarchar(250),
		Barcode				nvarchar(100),
		Purchase_Date		datetime,
		Maintenance_Date	datetime,
		Office_Name			nvarchar(250),
		Division			nvarchar(250),
		Department			nvarchar(250)
	)

	declare @expired_rental_building table
	(
		Location				nvarchar(250),
		Starting_Rental_Date	nvarchar(20),
		Expired_Rental_Date		nvarchar(20),
		Total_Rental_Price		decimal(18,2)
	)

	
	declare c_email_notif cursor fast_forward read_only for
	select	email_notification_type, start_days, end_days
	from	eprocbase.dbo.master_email_reminder_notification
	where	email_notification_type in ('EXPDOC','MNTANC','OPNAME')
	and		is_active = '1'
									
	open c_email_notif
	fetch next from c_email_notif
	into @reminder_type, @start_days, @end_days
								
	while @@fetch_status = 0
	begin
		
		
		if @p_mail_file_name like '%reminderdatamaintenanceasset%' and @reminder_type = 'MNTANC'  -- maintenance
		begin
			if exists (select 1
						from	dbo.asset_maintenance_schedule
						where	maintenance_status <> 'DONE'
						and		datediff(day,cast(maintenance_date as date),cast(@eod as date)) between @start_days and @end_days
					)
			begin
					
				declare c_maintenance cursor fast_forward read_only for
				select	id
				from	dbo.asset_maintenance_schedule
				where	maintenance_status <> 'DONE'
				and		datediff(day,cast(maintenance_date as date),cast(@eod as date)) between @start_days and @end_days
										
				open c_maintenance
				fetch next from c_maintenance
				into @id
									
				while @@fetch_status = 0
				begin
					
					insert into @maintenance_schedule
					    (Location
					    ,Asset
					    ,Barcode
					    ,Purchase_Date
					    ,Maintenance_Date
					    ,Office_Name
					    ,Division
					    ,Department
					    )
					select	a.location_name
							,a.item_name
							,a.barcode
							,a.purchase_date
							,ams.maintenance_date
							,a.branch_name
							,a.division_name
							,a.department_name
					from	asset_maintenance_schedule ams
						inner join dbo.asset a on a.code = ams.asset_code
					where	ams.id = @id
						
										
					fetch next from c_maintenance
					into @id
									
				end
									
				close c_maintenance
				deallocate c_maintenance

			end
		end
		else if @p_mail_file_name like '%reminderdataexpiredrental%' and @reminder_type = 'EXPDOC' -- expired document
		begin

			if exists (select 1
						from	dbo.asset_property
						where	datediff(day,cast(end_rental_date as date),cast(@eod as date)) between @start_days and @end_days
					)
			begin
					
				declare c_expired cursor fast_forward read_only for
				select	asset_code
				from	dbo.asset_property
				where	datediff(day,cast(end_rental_date as date),cast(@eod as date)) between @start_days and @end_days
										
				open c_expired
				fetch next from c_expired
				into @asset_code
									
				while @@fetch_status = 0
				begin

					insert into @expired_rental_building
						(Location,
						 Starting_Rental_Date,
						 Expired_Rental_Date,
						 Total_Rental_Price
						)
					select	a.LOCATION_NAME
							,convert(nvarchar(max),start_rental_date,106)
							,convert(nvarchar(max),end_rental_date,106)
							,ap.total_rental_price
					from	dbo.asset_property ap
						inner join dbo.asset a on a.code = ap.asset_code
					where	ap.asset_code = @asset_code
			
					fetch next from c_expired
					into @asset_code
									
				end
									
				close c_expired
				deallocate c_expired

			end
		end
					
				
		fetch next from c_email_notif
		into @reminder_type, @start_days, @end_days
								
	end
								
	close c_email_notif
	deallocate c_email_notif
	
	if @p_mail_file_name like '%reminderdatamaintenanceasset%' -- maintenance
	begin
		select Location,
               Asset,
               Barcode,
               Purchase_Date,
               Maintenance_Date,
			   Office_Name,
			   Division,
			   Department
		from @maintenance_schedule
	end
	else if @p_mail_file_name like '%reminderdataexpiredrental%'-- expired document
	begin
		select Location,
               Starting_Rental_Date,
               Expired_Rental_Date,
               Total_Rental_Price
		from @expired_rental_building
	end

end
