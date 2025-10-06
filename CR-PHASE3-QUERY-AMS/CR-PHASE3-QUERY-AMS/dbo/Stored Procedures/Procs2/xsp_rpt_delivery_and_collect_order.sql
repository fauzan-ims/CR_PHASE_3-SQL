--Created, JEFF at 08/08/2023
CREATE procedure [dbo].[xsp_rpt_delivery_and_collect_order]
(
	@p_user_id			nvarchar(50)
	,@p_code			nvarchar(50)
)
as
BEGIN
	
	delete	dbo.rpt_delivery_and_collect_order
	where	user_id = @p_user_id ;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@branch_code					nvarchar(50)	
			,@branch_name					nvarchar(50)	
			,@delivery_or_collect			nvarchar(50)	
			,@unit_condition				nvarchar(50)	
			,@status_pengiriman				nvarchar(50)	
			,@agreement_no					nvarchar(50)	
			,@lessee						nvarchar(50)	
			,@lessee_address				nvarchar(50)	
			,@pic_lesse						nvarchar(150)	
			,@lessee_contact_number			nvarchar(50)	
			,@description_unit_utama		nvarchar(50)	
			,@year							int
			,@plat_no						nvarchar(50)	
			,@chassis_no					nvarchar(50)	
			,@engine_no						nvarchar(50)	
			,@color							nvarchar(50)	
			,@delivery_date					datetime		
			,@bast_date						datetime		
			,@upload_bast_date				datetime		

	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'DELIVERY AND COLLECT ORDER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into dbo.rpt_delivery_and_collect_order
			(
				user_id
				,report_title
				,report_image
				,report_company
				,requirement
				,delivery_collect_no
				,delivery_collect_date
				,start_time
				,finish_time
				,customer_supplier
				,agreement_no
				,delivery_address
				,pic_name
				,contact_number
				,police_number
				,tipe_unit
				,status_unit
				,year
				,color
				,delivery_purpose_collect_reason
				,collect_delivery_by
				,bbm_charge
				,toll_charge
				,parking_charge
				,transport_charge
				,other_cost
				,catatan
				,type
			)
			select	@p_user_id
					,@report_title
					,@report_image
					,@report_company
					,hast.remark
					,hast.code
					,hrq.eta_date
					,null
					,null
					,ast.client_name
					,ast.agreement_external_no
					,hast.handover_address
					,hast.handover_to
					,hast.handover_phone_area + ' - ' + hast.handover_phone_no
					,avi.plat_no
					,ast.item_name
					,ast.status
					,avi.built_year
					,avi.colour
					,hrq.reff_name
					,hast.handover_from
					,null
					,null
					,null
					,null
					,null
					,null
					,case
						 when hast.type = 'DELIVERY'
							  or hast.type = 'REPLACE OUT'
							  or hast.type = 'MAINTENANCE OUT'
							  or hast.type = 'SELL OUT'
							  or hast.type = 'REPLACE GTS OUT'
							  or hast.type = 'RETURN OUT' then 'OUT'
						 else 'IN'
					 end
			from	ifinams.dbo.handover_asset hast
					left join ifinams.dbo.handover_request hrq on hrq.handover_code = hast.code
					left join ifinams.dbo.asset ast on hast.fa_code					= ast.code
					left join ifinams.dbo.asset_vehicle avi on avi.asset_code		= ast.code
			where	hast.code = @p_code ;
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

