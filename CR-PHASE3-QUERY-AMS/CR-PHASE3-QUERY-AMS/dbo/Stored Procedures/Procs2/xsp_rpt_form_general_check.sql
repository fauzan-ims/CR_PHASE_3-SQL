--Created, Aliv at 26-05-2023
CREATE PROCEDURE dbo.xsp_rpt_form_general_check
(
	@p_code				nvarchar(50)
	,@p_user_id			nvarchar(50)
	,@p_cre_date		datetime
)
as
BEGIN

	delete dbo.rpt_form_general_check
	where	user_id = @p_user_id ;

	delete dbo.rpt_form_general_check
	where	user_id = @p_user_id ;

	declare @msg				nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_title		nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_address	nvarchar(250)
			,@report_phone		nvarchar(50)
			,@report_fax		nvarchar(50)
			,@req_code_before	nvarchar(50) = '' 
			,@req_code			nvarchar(50)

	begin TRY
											
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

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


		insert into dbo.rpt_form_general_check
		(
			user_id
			,report_company
			,report_title
			,report_image
			,report_address
			,fa_code
			,phone_no
			,fax_no
			,plat_no
			,type_vehicle
			,year
			,colour
			,chassis_no
			,engine_no
			,stnk_date
			,implementation_date
			,km
			,fuel
			,surveyor
			,place
			,cre_date
		)
		select	@p_user_id
				,@report_company
				,@report_title	
				,@report_image	
				,@report_address
				,av.asset_code	
				,@report_phone	
				,@report_fax
				,av.plat_no
				,ass.item_name
				,av.built_year
				,av.COLOUR
				,av.chassis_no
				,av.engine_no
				,av.stnk_date
				,od.date
				,od.km
				,''
				,op.pic_name
				,od.LOCATION_NAME
				,@p_cre_date
	from		opname op
				left join opname_detail od on (op.code = od.opname_code)
				left join dbo.asset ass on (ass.code = od.asset_code)
				left join dbo.asset_vehicle av on(av.asset_code = ass.code)
	where		od.opname_code = @p_code
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

