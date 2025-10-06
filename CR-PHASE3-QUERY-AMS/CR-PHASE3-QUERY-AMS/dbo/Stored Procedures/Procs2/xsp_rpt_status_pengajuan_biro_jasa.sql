--Created, Aliv at 29-05-2023
create PROCEDURE dbo.xsp_rpt_status_pengajuan_biro_jasa
(
	@p_code				nvarchar(50)
	,@p_sale_code		NVARCHAR(50)
	,@p_user_id			nvarchar(50)
	,@p_cre_date		datetime
)
as
BEGIN

	delete dbo.rpt_profitability_asset
	where	user_id = @p_user_id ;

	delete dbo.rpt_profitability_asset
	where	user_id = @p_user_id ;



	declare @msg				nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_title		nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_address	nvarchar(250)
			,@report_phone		nvarchar(50)
			,@report_fax		nvarchar(50)
			,@tanggal_hari_ini	date = getdate()

	begin TRY
											
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'PHYSICAL UNIT CHECKING FORM';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		select @report_address = value 
		from	dbo.sys_global_param
		where	code = 'COMADD2'

		select @report_phone = value 
		from	dbo.sys_global_param
		where	code = 'TLP2'

		select @report_fax = value 
		from	dbo.sys_global_param
		where	code = 'FAX2'


		insert into dbo.rpt_profitability_asset
		(
			user_id
			,report_company
			,report_title
			,report_image
			,report_address
			,BRANCH_NAME
			,ASSET_NO
			,ASSET_DESCRIPTION
			,PLAT_NO
			,CHASSIS_NO
			,ENGINE_NO
			,DOCUMENT_TYPE
			,EXP_DATE
			,RENTAL_STATUS
			,AGING_DAYS
		)
		select	@p_user_id
				,@report_company
				,@report_title	
				,@report_image	
				,@report_address
				,ass.branch_name
				,ass.code
				,ass.item_name
				,av.plat_no
				,av.chassis_no
				,av.engine_no
				,''
				,''
				,ass.rental_status
				,datediff(day,@tanggal_hari_ini, ass.purchase_date)as aging_days
	from		sale_detail sd
				left join dbo.asset ass on (ass.code = sd.asset_code)
				left join dbo.sale s on (s.code = sd.sale_code)
				left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where		ass.code = @p_code
	and			sd.sale_code = @p_sale_code

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

