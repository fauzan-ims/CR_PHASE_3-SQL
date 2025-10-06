--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_bpkb_borrow_report
(
	@p_user_id		 nvarchar(50)
	,@p_branch_code	 nvarchar(50)
	,@p_as_of_date	 datetime
	,@p_branch_name	 nvarchar(50)
	,@p_is_condition nvarchar(1) = ''
)
as
begin
	delete	dbo.rpt_bpkb_borrow_report
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250)
			,@report_image	 nvarchar(250)
			,@branch_code	 nvarchar(50)
			,@branch_name	 nvarchar(50)
			,@agreement_no	 nvarchar(50)
			,@client_name	 nvarchar(50)
			,@merk			 nvarchar(50)
			,@model			 nvarchar(50)
			,@type			 nvarchar(50)
			,@chassis_no	 nvarchar(50)
			,@engine_no		 nvarchar(50)
			,@bpkb_no		 nvarchar(50)
			,@year			 int
			,@vendor		 nvarchar(50)
			,@borrowed_date	 datetime
			,@returned_date	 datetime ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Borrowed Document' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into rpt_bpkb_borrow_report
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,AS_OF_DATE
				,agreement_no
				,client_name
				,merk
				,model
				,type
				,chassis_no
				,engine_no
				,bpkb_no
				,year
				,vendor
				,borrowed_date
				,returned_date
				,is_condition
			)
			select	distinct
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,dma.branch_name
					,@p_as_of_date
					,ast.agreement_external_no
					,ast.client_name
					,ast.merk_name
					,ast.model_name
					,ast.type_name_asset
					,avi.chassis_no
					,avi.engine_no
					,avi.bpkb_no
					,fam.asset_year
					,fam.vendor_name
					,dht.movement_date
					,dht.movement_return_date
					,@p_is_condition
			from	ifindoc.dbo.document_history			dht
					inner join ifindoc.dbo.document_main	dma on dma.code		  = dht.document_code
					inner join ifindoc.dbo.fixed_asset_main fam on dma.asset_no	  = fam.asset_no
					inner join ifinams.dbo.asset_vehicle	avi on avi.asset_code = fam.asset_no
					inner join ifinams.dbo.asset			ast on ast.code		  = avi.asset_code
			where	dma.mutation_type					= 'BORROW'
					and dma.document_type				= 'BPKB'
					and dht.document_status				= 'ON BORROW'
					and cast(dht.movement_date as date) <= cast(@p_as_of_date as date)
					and dma.branch_code					= case @p_branch_code
															  when 'ALL' then dma.branch_code
															  else @p_branch_code
														  end ;

			if not exists
			(
				select	*
				from	dbo.rpt_bpkb_borrow_report
				where	user_id = @p_user_id
			)
			begin
				insert into dbo.rpt_bpkb_borrow_report
				(
					user_id
					,report_company
					,report_title
					,report_image
					,filter_branch_name
					,branch_code
					,branch_name
					,as_of_date
					,agreement_no
					,client_name
					,merk
					,model
					,type
					,chassis_no
					,engine_no
					,bpkb_no
					,year
					,vendor
					,borrowed_date
					,returned_date
					,is_condition
				)
				values
				(
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_name
					,@p_branch_code
					,null
					,@p_as_of_date
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,@p_is_condition
				) ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
