--created by, Rian at 15/02/2023 

CREATE PROCEDURE dbo.xsp_rpt_document_receive
(
	@p_user_id		   nvarchar(50)
	,@p_code		   nvarchar(50)
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@report_company nvarchar(50)
			,@report_title	 nvarchar(50)
			,@report_image	 nvarchar(50) ;

	begin try

		--delete terlebih dahulu table report
		delete	dbo.rpt_document_receive
		where	user_id = @p_user_id

		--set report company
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		--set report image
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		--set report title
		set	@report_title = 'DOCUMENT RECEIVE'

		insert into dbo.rpt_document_receive
		(
			user_id
			,report_company
			,report_title
			,report_image
			,date
			,receive_no
			,employee
			,branch
			,movement_to
			,location
			,courier
			,receive_date
			,remark
			,receive_remark
			,document_type
			,document_no
			,document_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,dm.movement_date
				,@p_code
				,dm.movement_by_emp_name
				,dm.branch_name
				,isnull(   dm.movement_to_branch_name, isnull(dm.movement_to_dept_name, isnull(dm.movement_to_client_name, case
																												 when dm.movement_to_thirdparty_type = 'C' then 'Client'
																												 when dm.movement_to_thirdparty_type = 'TPTTP2' then 'BIRO JASA'
																												 when dm.movement_to_thirdparty_type = 'TPTTP3' then 'NOTARIS'
																												 else 'Other'
																											 end))
					   )
				,dm.movement_location
				,case	when dm.movement_courier_code = 'ANJ' then 'ANTERIN AJA'
						when dm.movement_courier_code = 'JNE' then 'JNE'
						when dm.movement_courier_code = 'JNT' then 'JNT'
						when dm.movement_courier_code = 'POS' then 'POS INDONESIA'
						when dm.movement_courier_code = 'TKI' then 'TIKI'
						else ''
					end
				,dm.receive_date
				,dm.movement_remarks
				,dm.receive_remark
				,isnull(dom.document_type, dp.document_type)
				,case
					 when dmd.document_code is null then dp.asset_no
					 else dom.asset_no
				 end 
				,case
					 when dmd.document_code is null then dp.asset_name
					 else dom.asset_name
				 end 
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.document_movement dm
				left join dbo.document_movement_detail dmd on (dmd.movement_code = dm.code)
				left join dbo.document_main dom on (dom.code					  = dmd.document_code)
				left join dbo.document_pending dp on (dmd.document_pending_code = dp.code)
		where	dm.code = @p_code ;
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
