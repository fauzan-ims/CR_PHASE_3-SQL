CREATE PROCEDURE dbo.xsp_reminder_opname
(
	@p_eod_date				datetime
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(50)
	,@p_cre_ip_address		nvarchar(50)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(50)
	,@p_mod_ip_address		nvarchar(50)
) 
as
begin
	
	declare	@item_code				nvarchar(10)
			,@email_notif_code		nvarchar(50)
			,@reminder_maintenance	int
			--,@eod					datetime = getdate()
			,@save_file_name		nvarchar(250)
			,@save_file_path		nvarchar(250)
			,@sql_script			nvarchar(max)
			,@values				nvarchar(max)
			,@id					int
			,@start_days			int
			,@end_days				int
			,@reminder_type			nvarchar(50)
			,@item_group_code		nvarchar(10)
			,@company_code			nvarchar(50) = 'WOM'
	
	declare @temp_tbl table
	(
		id     int identity(1, 1)
		,text_ nvarchar(max)
	) ;
	
	select	@save_file_path = value
	from	eprocbase.dbo.sys_global_param
	where	CODE = 'GFP'
	
	declare c_email_notif cursor fast_forward read_only for
	select	email_notification_type, start_days, end_days
	from	eprocbase.dbo.master_email_reminder_notification
	where	email_notification_type = 'OPNAME'-- Arga 03-Nov-2022 ket : split for wom (-/+) -- in ('EXPDOC','MNTANC','OPNAME')
	and		is_active = '1'
									
	open c_email_notif
	fetch next from c_email_notif
	into @reminder_type, @start_days, @end_days
								
	while @@fetch_status = 0
	begin
		
		-- Arga 03-Nov-2022 ket : for wom (+)
		--if @reminder_type = 'OPNAME'
		--begin
			--if (day(@p_eod_date) between @start_days and @end_days)
			--begin

				-- send mail attachment based on setting ================================================
				--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'OPNAME'
				--												,@p_doc_code		= ''
				--												,@p_attachment_flag = 0
				--												,@p_attachment_file = ''
				--												,@p_attachment_path = ''
				--												,@p_company_code	= @company_code
				--												,@p_trx_no			= ''
				--												,@p_trx_type		= 'OPNAME ASET'
				-- End of send mail attachment based on setting ================================================

			--end
		--end
		 						
		fetch next from c_email_notif
		into @reminder_type, @start_days, @end_days
								
	end
								
	close c_email_notif
	deallocate c_email_notif
		
end
