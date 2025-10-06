CREATE PROCEDURE [dbo].[xsp_rpt_document_and_status]
(
	@p_user_id			  nvarchar(50)
	,@p_branch_code		  nvarchar(50)
	,@p_status_posisi_doc nvarchar(50)
	,@p_locker			  nvarchar(50) = ''
	,@p_is_condition	  nvarchar(1) --(+) Untuk Kondisi Excel Data Only
	--
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	delete dbo.rpt_document_and_status
	where	user_id = @p_user_id ;

	declare @report_company		 nvarchar(250)
			,@report_title		 nvarchar(250)
			,@report_image		 nvarchar(250)
			--
			,@filter_locker_name nvarchar(250)
			,@branch_code		 nvarchar(50)
			,@branch_name		 nvarchar(250)
			,@asset_no			 nvarchar(50)
			,@asset_name		 nvarchar(250)
			,@document_code		 nvarchar(50)
			,@document_name		 nvarchar(250)
			,@document_no		 nvarchar(50)
			,@document_type		 nvarchar(250)
			,@expired_date		 datetime
			,@location			 nvarchar(250)
			,@locker			 nvarchar(250)
			,@drawer			 nvarchar(250)
			,@row				 nvarchar(250)
			,@plat_no			nvarchar(20)
			,@chassis_no		nvarchar(50)
			,@engine_no			nvarchar(50)
			--
			,@datetimenow		 datetime
			,@report_code		 nvarchar(50) ;

	set @report_title = 'Report Document & Status List' ;
	set @datetimeNow = getdate() ;

	select	@report_company = value
	from	dbo.sys_global_param
	where	code = 'COMP2' ;

	select	@report_image = value
	from	dbo.sys_global_param
	where	code = 'IMGDSF' ;

	/* declare main cursor */
	declare c_on_hand cursor local fast_forward read_only for
	select	isnull(dm.locker_position, '-')
			,isnull(dm.branch_code, '-')
			,isnull(dm.branch_name, '-')
			,isnull(dm.asset_no, '-')
			,isnull(dm.asset_name, '-')
			,isnull(dcd.document_code, '-')
			,isnull(dcd.document_name, '-')
			,''
			,isnull(dcd.document_type, '-')
			,isnull(dcd.expired_date, '1900-01-01')
			,isnull(dm.document_status, '-')
			,isnull(dm.locker_code, '-')
			,isnull(dm.drawer_code, '-')
			,isnull(dm.row_code, '-')
			,isnull(av.chassis_no,'')
			,isnull(av.plat_no,'')
			,isnull(av.engine_no,'')
	from	dbo.document_main dm with (nolock)
			left join dbo.document_detail dcd with (nolock) on (dcd.document_code = dm.code)
			left join ifinams.dbo.asset_vehicle av on (dm.asset_no = av.asset_code)
	where	(
				dm.branch_code		= @p_branch_code
				or	@p_branch_code	= 'ALL'
			)
			and (
					dm.locker_code	= @p_locker
					or	@p_locker	= 'ALL'
				)
			and (dm.document_status = @p_status_posisi_doc) ;

	/* fetch record */
	open c_on_hand ;

	fetch c_on_hand
	into @filter_locker_name
		 ,@branch_code
		 ,@branch_name
		 ,@asset_no
		 ,@asset_name
		 ,@document_code
		 ,@document_name
		 ,@document_no
		 ,@document_type
		 ,@expired_date
		 ,@location
		 ,@locker
		 ,@drawer
		 ,@row
		 ,@chassis_no
		 ,@plat_no
		 ,@engine_no ;

	while @@fetch_status = 0
	begin

		/* insert into table report */
		insert into dbo.rpt_document_and_status
		(
			user_id
			,report_company
			,report_title
			,report_image
			,filter_branch_code
			,filter_locker_code
			,filter_locker_name
			,branch_code
			,branch_name
			,asset_no
			,asset_name
			,document_code
			,document_name
			,document_no
			,document_type
			,expired_date
			,location
			,locker
			,drawer
			,row
			,is_condition
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			--
			,plat_no
			,chassis_no
			,engine_no
		)
		values
		(	@p_user_id
			,@report_company
			,@report_title
			,@report_image
			,@p_branch_code
			,@p_locker
			,@filter_locker_name
			,@branch_code
			,@branch_name
			,@asset_no
			,@asset_name
			,@document_code
			,@document_name
			,@document_no
			,@document_type
			,@expired_date
			,@location
			,@locker
			,@drawer
			,@row
			,@p_is_condition
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			--
			,@plat_no
			,@chassis_no
			,@engine_no
		) ;

		/* fetch record berikutnya */
		fetch c_on_hand
		into @filter_locker_name
			 ,@branch_code
			 ,@branch_name
			 ,@asset_no
			 ,@asset_name
			 ,@document_code
			 ,@document_name
			 ,@document_no
			 ,@document_type
			 ,@expired_date
			 ,@location
			 ,@locker
			 ,@drawer
			 ,@row
			 ,@chassis_no
			 ,@plat_no
			 ,@engine_no ;
	end ;

	/* tutup cursor */
	close c_on_hand ;
	deallocate c_on_hand ;

	if not exists
	(
		select	*
		from	dbo.rpt_document_and_status
		where	user_id = @p_user_id
	)
	begin
		insert into dbo.rpt_document_and_status
		(
			user_id
			,report_company
			,report_title
			,report_image
			,filter_branch_code
			,filter_locker_code
			,filter_locker_name
			,branch_code
			,branch_name
			,asset_no
			,asset_name
			,document_code
			,document_name
			,document_no
			,document_type
			,expired_date
			,location
			,locker
			,drawer
			,row
			,is_condition
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_user_id
			,@report_company
			,@report_title
			,@report_image
			,@p_branch_code
			,@p_locker
			,''
			,''
			,'none'
			,''
			,''
			,''
			,''
			,''
			,''
			,isnull(@expired_date, '1900-01-01')
			,''
			,''
			,''
			,''
			,@p_is_condition
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end ;
end ;
