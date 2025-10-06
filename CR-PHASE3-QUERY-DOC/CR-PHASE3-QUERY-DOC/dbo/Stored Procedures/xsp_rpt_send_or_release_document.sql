--created by, Rian at 14/02/2023 

CREATE PROCEDURE dbo.xsp_rpt_send_or_release_document
(
	@p_user_id		   nvarchar(50)
	,@p_code		   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
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

		--delete terlebih dahulu tabel report
		delete dbo.rpt_send_or_release_document
		where	user_id = @p_user_id ;

		delete	dbo.rpt_send_or_release_document_detail
		where	user_id = @p_user_id

		--set report company
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP' ;

		--set report image
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		--set report title jika location nya client atau borrow client maka titel nya release document jika bukan maka titile nya send document
		if exists
		(
			select	1
			from	dbo.document_movement
			where	code				  = @p_code
					and (movement_location = 'CLIENT' or movement_location = 'BORROW CLIENT')
		)
		begin
			set @report_title = 'RELEASE DOCUMENT' ;
		end ;
		else
		begin
			set @report_title = 'SEND DOCUMENT' ;
		end ;

		--jika movement location nya borrow client maka input data ke tabel tabel detail juga
		if exists
		(
			select	1
			from	dbo.document_movement
			where	code				  = @p_code
					and movement_location = 'BORROW CLIENT'
		)
		begin
			insert into dbo.rpt_send_or_release_document_detail
			(
				user_id
				,movement_code
				,document_name
				,document_no
				,remarks
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@p_user_id
					,@p_code
					,document_name
					,document_no
					,remarks
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.document_movement_replacement
			where	movement_code = @p_code ;
		end ;

		--insert ke tabel report
		insert into dbo.rpt_send_or_release_document
		(
			user_id
			,report_company
			,report_title
			,report_image
			,date
			,send_no
			,employee
			,branch_name
			,location
			,movement_to
			,estimate_return_date
			,courier
			,receive_by
			,receive_by_name
			,receive_by_id
			,remark
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
				,dm.movement_location
				,isnull(dm.movement_to_branch_name, isnull(dm.movement_to_dept_name, isnull(   dm.movement_to_client_name, case
																															   when dm.movement_to_thirdparty_type = 'C' then 'CLIENT'
																															   when dm.movement_to_thirdparty_type = 'TPTTP2' then 'BIRO JASA'
																															   when dm.movement_to_thirdparty_type = 'TPTTP3' then 'NOTARIS'
																															   when dm.movement_to_thirdparty_type = 'O' then 'OTHER'
																															   else ''
																														   end
																						   )
														  )
					   )
				,dm.estimate_return_date
				,case
					 when dm.movement_courier_code = 'ANJ' then 'ANTERIN AJA'
					 when dm.movement_courier_code = 'JNE' then 'JNE'
					 when dm.movement_courier_code = 'JNT' then 'JNT'
					 when dm.movement_courier_code = 'POS' then 'POS INDONESIA'
					 when dm.movement_courier_code = 'TKI' then 'TIKI'
					 else ''
				 end
				,case
					 when dm.received_by = 'C' then 'CLIENT'
					 else 'OTHER'
				 end
				,dm.received_name
				,dm.received_id_no
				,dm.movement_remarks
				,dom.document_type
				,dom.ASSET_NO
				,dom.ASSET_NAME
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.document_movement dm
				left join dbo.document_movement_detail dmd on (dmd.movement_code = dm.code)
				left join dbo.document_main dom on (dom.code					 = dmd.document_code)
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
