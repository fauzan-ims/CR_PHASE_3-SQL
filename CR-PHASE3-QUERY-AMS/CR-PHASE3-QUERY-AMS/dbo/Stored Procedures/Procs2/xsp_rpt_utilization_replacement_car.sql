--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_utilization_replacement_car]
(
	@p_user_id		 nvarchar(50)
	,@p_from_date	 datetime
	,@p_to_date		 datetime
	,@p_is_condition nvarchar(1)	--(+) Untuk Kondisi Excel Data Only
)
as
begin
	delete	rpt_utilization_replacement_car
	where	user_id = @p_user_id ;

	declare @msg			   nvarchar(max)
			,@report_company   nvarchar(250)
			,@report_title	   nvarchar(250)
			,@report_image	   nvarchar(250)
			,@dateout		   datetime
			,@incoming_status  nvarchar(50)
			,@agreement_no	   nvarchar(50)
			,@status_unit	   nvarchar(50)
			,@status_pemakaian nvarchar(50)
			,@ex_customer	   nvarchar(50)
			,@leased_object	   nvarchar(50)
			,@year			   int
			,@chassis_no	   nvarchar(50)
			,@engine_no		   nvarchar(50)
			,@plat_no		   nvarchar(50)
			,@customer_name	   nvarchar(50) ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Utilization Replacement Car' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into rpt_utilization_replacement_car
			(
				user_id
				,report_company
				,report_title
				,report_image
				,from_date
				,to_date
				,dateout
				,incoming_status
				,agreement_no
				,status_unit
				,status_pemakaian
				,ex_customer
				,leased_object
				,year
				,chassis_no
				,engine_no
				,plat_no
				,customer_name
				,replacement_reason
				,date_in
				,aging
				,UNIT_UTAMA_LEASED_OBJECT
				,UNIT_UTAMA_YEAR
				,UNIT_UTAMA_CHASSIS_NO
				,UNIT_UTAMA_ENGINE_NO
				,UNIT_UTAMA_PLAT_NO
				,nama_bengkel
				,alamat_bengkel
				,pic_bengkel
				,phone_no_bengkel
				,remarks
				,is_condition
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_from_date
					,@p_to_date
					,hast.handover_date
					,ast.process_status
					,ast.agreement_external_no
					,ast.status
					,ast.rental_status + case
											when ast.ASSET_FROM='RENT' then ' - Rent'
											else ''
										 end
					,hast.handover_from
					,ast.item_name
					,avi.built_year
					,avi.chassis_no
					,avi.engine_no
					,avi.plat_no
					,ast.client_name
					,sgc.description
					,ard.new_handover_in_date
					,case
						when arp.status='DONE' then datediff(day,ard.new_handover_out_date,ard.new_handover_in_date)
						else datediff(day,dbo.xfn_get_system_date(),ard.new_handover_in_date)
					end
					,replacement.item_name
					,replacement.built_year
					,replacement.chassis_no
					,replacement.engine_no
					,replacement.plat_no
					,mnc.vendor_name
					,mnc.vendor_address
					,mnc.sa_vendor_name --pic bengkel
					,mnc.sa_vendor_area_phone + ' - ' + mnc.sa_vendor_phone_no
					,wo.remark
					,@p_is_condition
			from	ifinams.dbo.handover_asset			 hast
					inner join ifinams.dbo.asset		 ast on hast.fa_code = ast.code
					left join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
					left join ifinopl.dbo.application_asset aast on aast.replacement_fa_code = ast.code
					left join ifinopl.dbo.asset_replacement_detail ard on ard.new_fa_code = ast.code
					left join ifinopl.dbo.asset_replacement arp on arp.code = ard.replacement_code
					left join ifinopl.dbo.sys_general_subcode sgc on sgc.code = ard.reason_code
					outer apply (
						select ast1.item_name,avi1.built_year,avi1.chassis_no,avi1.engine_no,avi1.plat_no
						from asset ast1
						left join ifinams.dbo.asset_vehicle avi1 on avi1.asset_code = ast1.code
						where ast1.code = aast.replacement_fa_code
					) replacement
					left join ifinams.dbo.work_order wo on wo.asset_code = ast.code
					left join ifinams.dbo.maintenance mnc on mnc.asset_code = ast.code
			where	hast.TYPE like 'REPLACE%'
					and ast.status = 'REPLACEMENT'
					and ast.RENTAL_STATUS in ('REPLACEMENT','GTS')
					and cast(hast.HANDOVER_DATE as date)
					between cast(@p_from_date as date) and cast(@p_to_date as date) ;

			if not exists
			(
				select	*
				from	dbo.rpt_utilization_replacement_car
				where	user_id = @p_user_id
			)
			begin
				insert into dbo.rpt_utilization_replacement_car
				(
					user_id
					,report_company
					,report_title
					,report_image
					,from_date
					,to_date
					,dateout
					,incoming_status
					,agreement_no
					,status_unit
					,status_pemakaian
					,ex_customer
					,leased_object
					,year
					,chassis_no
					,engine_no
					,plat_no
					,customer_name
					,is_condition
				)
				values
				(
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
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
