--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_delivery_unit]
(
	@p_user_id		 nvarchar(50)
	,@p_branch_code	 nvarchar(50)
	,@p_branch_name	 nvarchar(50)
	,@p_from_date	 datetime
	,@p_to_date		 datetime
	,@p_is_condition nvarchar(1)
)
as
begin
	delete	dbo.rpt_delivery_unit
	where	user_id = @p_user_id ;

	declare @msg					 nvarchar(max)
			,@report_company		 nvarchar(250)
			,@report_title			 nvarchar(250)
			,@report_image			 nvarchar(250)
			,@branch_code			 nvarchar(50)
			,@branch_name			 nvarchar(50)
			,@delivery_or_collect	 nvarchar(50)
			,@unit_condition		 nvarchar(50)
			,@status_pengiriman		 nvarchar(50)
			,@agreement_no			 nvarchar(50)
			,@lessee				 nvarchar(50)
			,@lessee_address		 nvarchar(50)
			,@pic_lesse				 nvarchar(150)
			,@lessee_contact_number	 nvarchar(50)
			,@description_unit_utama nvarchar(50)
			,@year					 nvarchar(4)
			,@plat_no				 nvarchar(50)
			,@chassis_no			 nvarchar(50)
			,@engine_no				 nvarchar(50)
			,@color					 nvarchar(50)
			,@delivery_date			 datetime
			,@bast_date				 datetime
			,@upload_bast_date		 datetime ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Delivery & Pick Up' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into rpt_delivery_unit
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,from_date
				,to_date
				,delivery_or_collect
				,unit_condition
				,status_pengiriman
				,agreement_no
				,lessee
				,lessee_address
				,pic_lesse
				,lessee_contact_number
				,description_unit_utama
				,year
				,plat_no
				,chassis_no
				,engine_no
				,color
				,delivery_date
				,bast_date
				,upload_bast_date
				,is_condition
			)
			select	distinct
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,@p_branch_name
					,@p_from_date
					,@p_to_date
					,hast.type
					,hast.unit_condition
					,hast.status
					,ast.agreement_external_no
					,hast.handover_to
					,hast.handover_address
					,ast.pic_name
					,isnull(hast.handover_phone_area, '') + isnull(hast.handover_phone_no, '') 'handover_phone'
					,ast.item_name
					,case
						 when avi.built_year = '' then null
						 else avi.built_year
					 end
					,avi.plat_no
					,avi.chassis_no
					,avi.engine_no
					,avi.colour
					,hast.plan_date
					,hast.handover_date
					,had.upload_bast_date
					,@p_is_condition
			from	ifinams.dbo.handover_asset hast
					outer apply
			(
				select	had.mod_date 'upload_bast_date'
				from	dbo.handover_asset_doc had
				where	had.handover_code			  = hast.code
						and had.document_code		  = 'SGD02305000001'
						and isnull(had.file_name, '') <> ''
			) had
					left join ifinams.dbo.asset ast on ast.code				  = hast.fa_code
					left join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
			--inner join ifinams.dbo.register_main rmain on rmain.fa_code = ast.code
			where	hast.type in
			(
				'DELIVERY', 'PICK UP'
			)
					and hast.STATUS in
			(
				'POST', 'HOLD'
			)
					and hast.branch_code = case @p_branch_code
											   when 'ALL' then hast.branch_code
											   else @p_branch_code
										   end
					and cast(hast.transaction_date as date)
					between cast(@p_from_date as date) and cast(@p_to_date as date) ;

			if not exists
			(
				select	*
				from	dbo.rpt_delivery_unit
				where	user_id = @p_user_id
			)
			begin
				insert into dbo.rpt_delivery_unit
				(
					user_id
					,report_company
					,report_title
					,report_image
					,branch_code
					,branch_name
					,from_date
					,to_date
					,delivery_or_collect
					,unit_condition
					,status_pengiriman
					,agreement_no
					,lessee
					,lessee_address
					,pic_lesse
					,lessee_contact_number
					,description_unit_utama
					,year
					,plat_no
					,chassis_no
					,engine_no
					,color
					,delivery_date
					,bast_date
					,upload_bast_date
					,is_condition
				)
				values
				(
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,@p_branch_name
					,@p_from_date
					,@p_to_date
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
