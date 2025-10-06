--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_monitoring_payment
(
	@p_user_id			nvarchar(50)
	,@p_from_date		datetime	
	,@p_to_date			DATETIME	
	,@p_is_condition	NVARCHAR(1) 
)
AS
BEGIN

	delete dbo.RPT_MONITORING_PAYMENT
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@vendor_name					nvarchar(50)	
			,@payment_date					datetime		
			,@no_kwitansi					nvarchar(50)	
			,@plat_no						nvarchar(50)	
			,@customer						nvarchar(50)	
			,@agreement_no					nvarchar(50)
			,@brand							nvarchar(250)	
			,@object_lease					nvarchar(50)
			,@tahun							nvarchar(4)
			,@chasiss_number				nvarchar(50)
			,@engine_number					nvarchar(50)
			,@actual_km						nvarchar(15)	
			,@category_asset				nvarchar(50)	
			,@jasa							decimal(18, 2)	
			,@pph							decimal(18, 2)	
			,@spare_part					decimal(18, 2)
			,@sub_material					nvarchar(50)	
			,@ppn							decimal(18, 2)	
			,@material						int	
			,@other							int	
			,@total							decimal(18, 2)

	begin try
	
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'Report Payment Approval Maintenance';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

	begin

			--insert into rpt_monitoring_payment
			--(
			--	user_id
			--	,report_company
			--	,report_title
			--	,report_image
			--	,from_date	
			--	,to_date		
			--	,vendor_name	
			--	,payment_no
			--	,payment_date	
			--	,no_kwitansi	
			--	,plat_no		
			--	,customer		
			--	,agreement_no
			--	,brand	
			--	,object_lease
			--	,tahun	
			--	,chasiss_number
			--	,engine_number
			--	,actual_km
			--	,spk_date
			--	,category_asset
			--	,jasa			
			--	,pph
			--	,spare_part			
			--	,sub_material	
			--	,ppn			
			--	,material		
			--	,other			
			--	,total			
			--	,is_condition
			--)
			--select  @p_user_id
			--		,@report_company
			--		,@report_title
			--		,@report_image
			--		,@p_from_date
			--		,@p_to_date
			--		,mnt.vendor_name
			--		,payment_transaction_detail.payment_transaction_code --ptd.payment_transaction_code
			--		,payment_transaction.payment_transaction_date  --ptr.payment_transaction_date
			--		,wor.invoice_no--no_kwitansi
			--		,avi.plat_no
			--		,ast.client_name--agm.client_name
			--		,ast.agreement_external_no--agm.agreement_no
			--		,isnull(ast.merk_name,mme.description)
			--		,ast.item_name --object_lease
			--		,avi.built_year
			--		,avi.chassis_no
			--		,avi.engine_no
			--		,mnt.actual_km --ast.last_meter
			--		,mnt.transaction_date
			--		,sgs4.description --category_asset
			--		,isnull(jasa.jasa_fee,0)		--@jasa			
			--		,isnull(wor.total_pph_amount,0)		--,@pph		
			--		,isnull(spare_part.spare_part_fee,0)		--,@spare_part	
			--		,0		--,@sub_material	
			--		,isnull(wor.total_ppn_amount,0)		--,@ppn			
			--		,0		--,@material		
			--		,0		--,@other			
			--		,isnull(wor.payment_amount,0)		--,@total	
			--		,@p_is_condition
			--from	ifinams.dbo.work_order wor with (nolock)
			--		inner join ifinams.dbo.maintenance mnt with (nolock) on (mnt.code = wor.maintenance_code)
			--		inner join ifinams.dbo.asset ast with (nolock) on (wor.asset_code = ast.code)
			--		left join ifinopl.dbo.agreement_main agm with (nolock) on (agm.agreement_no = ast.agreement_no)
			--		left join ifinams.dbo.asset_vehicle avi with (nolock) on (avi.asset_code = ast.code) 
			--		left join ifinbam.dbo.master_item mim with (nolock) on (mim.code = ast.item_code)
			--		left join ifinbam.dbo.sys_general_subcode sgs4 with (nolock) on (sgs4.code = mim.registration_class_type) 
			--		left join ifinams.dbo.payment_request prq with (nolock) on (prq.payment_source_no=wor.code)
			--		outer apply (select payment_transaction_code from dbo.payment_transaction_detail ptd where ptd.payment_request_code = prq.code) payment_transaction_detail
			--		--inner join ifinams.dbo.payment_transaction_detail ptd with (nolock) on (ptd.payment_request_code = prq.code)
			--		outer apply (select pt.payment_transaction_date from dbo.payment_transaction pt where pt.code = payment_transaction_detail.payment_transaction_code) payment_transaction
			--		--inner join ifinams.dbo.payment_transaction ptr with (nolock) on (ptr.code = ptd.payment_transaction_code)
			--		left join ifinbam.dbo.master_item mit with (nolock) on (mit.code = ast.item_code)
			--		left join ifinbam.dbo.master_merk mme with (nolock) on (mme.code = mit.merk_code)
			--		outer apply (
			--						select	wod2.work_order_code
			--								,sum(wod2.total_amount) 'spare_part_fee' 
			--						from	dbo.work_order_detail wod2 with (nolock)
			--						where	wod2.service_type = 'ITEM' 
			--						and		wod2.work_order_code = wor.code
			--						group by wod2.work_order_code				
			--					) spare_part 
			--		outer apply (
			--						select	wod3.work_order_code
			--								,sum(wod3.total_amount) 'jasa_fee' 
			--						from	dbo.work_order_detail wod3 with (nolock)
			--						where	wod3.service_type = 'JASA' 
			--						and		wod3.work_order_code = wor.code
			--						group by wod3.work_order_code				
			--					) jasa 
			--where	cast(mnt.work_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
			--and wor.STATUS='PAID';

			insert into dbo.rpt_monitoring_payment
			(
				user_id
				,report_company
				,report_title
				,report_image
				,from_date
				,to_date
				,vendor_name
				,payment_date
				,no_kwitansi
				,plat_no
				,customer
				,agreement_no
				,object_lease
				,category_asset
				,jasa
				,pph
				,spare_part
				,sub_material
				,ppn
				,material
				,other
				,total
				,is_condition
				,payment_no
				,brand
				,tahun
				,chasiss_number
				,engine_number
				,actual_km
				,spk_date
			)
			SELECT	 @p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_from_date
					,@p_to_date
					,maintenance.vendor_name
					,isnull(fin.payment_value_date, payment_transaction.payment_transaction_date)
					,wo.invoice_no
					,vehicle.plat_no
					,vehicle.client_name
					,vehicle.agreement_external_no
					,vehicle.item_name
					,vehicle.description
					,jasa.total_amount
					,wo.total_pph_amount
					,item.total_amount
					,0
					,wo.total_ppn_amount
					,0
					,0
					,wo.payment_amount
					,@p_is_condition
					,payment_transaction.payment_transaction_code
					,vehicle.merk_name
					,vehicle.built_year
					,vehicle.chassis_no
					,vehicle.engine_no
					,maintenance.actual_km
					,maintenance.transaction_date
			FROM dbo.work_order wo WITH (NOLOCK)
			OUTER APPLY (SELECT mnt.work_date, mnt.vendor_name, mnt.asset_code, mnt.actual_km, mnt.transaction_date FROM dbo.maintenance mnt WITH (NOLOCK) WHERE mnt.code = wo.maintenance_code) maintenance
			OUTER APPLY (	SELECT ptd.payment_transaction_code, pt.payment_transaction_date 
							FROM	dbo.payment_request pr WITH (NOLOCK)
							LEFT JOIN dbo.payment_transaction_detail ptd WITH (NOLOCK) ON ptd.payment_request_code = pr.code 
							LEFT JOIN dbo.payment_transaction pt WITH (NOLOCK) ON (pt.code = ptd.payment_transaction_code)
							WHERE pr.payment_source_no = wo.code AND pt.payment_status NOT IN ('CANCEL','REJECT')
						) payment_transaction
			OUTER APPLY (
							SELECT avh.plat_no, ass.client_name, ass.agreement_external_no, ass.item_name, avh.merk_name, avh.built_year, avh.chassis_no, avh.engine_no, sgs.description
							FROM dbo.asset_vehicle avh WITH (NOLOCK)
							LEFT JOIN dbo.asset ass WITH (NOLOCK) ON (ass.code = avh.asset_code)
							LEFT JOIN ifinbam.dbo.master_item mi WITH (NOLOCK) ON (mi.code = ass.item_code)
							LEFT JOIN ifinbam.dbo.sys_general_subcode sgs WITH (NOLOCK) ON (sgs.code = mi.class_type_code)
							WHERE avh.asset_code = maintenance.asset_code
						) vehicle
			OUTER APPLY ( 
							SELECT	fin.payment_value_date 'payment_value_date'
							FROM	dbo.payment_request pr
							INNER JOIN  dbo.payment_transaction_detail ptd ON ptd.payment_request_code = pr.code
							INNER JOIN dbo.payment_transaction pt ON pt.code = ptd.payment_transaction_code
							INNER JOIN ifinfin.dbo.payment_request finpr ON finpr.payment_source_no = pt.code
							INNER JOIN ifinfin.dbo.payment_transaction_detail finptd ON finptd.payment_request_code = finpr.code
							INNER JOIN ifinfin.dbo.payment_transaction fin ON fin.code = finptd.payment_transaction_code
							WHERE pr.payment_source_no = wo.code							
							AND ISNULL(fin.payment_value_date,'')<>''
							and	fin.payment_status <> 'cancel'
						) fin
			OUTER APPLY (SELECT SUM(wod.total_amount) 'total_amount' FROM dbo.work_order_detail wod WITH (NOLOCK) WHERE wod.work_order_code = wo.code AND wod.service_type = 'item') item
			OUTER APPLY (SELECT SUM(wod.total_amount) 'total_amount' FROM dbo.work_order_detail wod WITH (NOLOCK) WHERE wod.work_order_code = wo.code AND wod.service_type = 'jasa') jasa
			WHERE CAST(maintenance.work_date AS DATE) BETWEEN @p_from_date AND @p_to_date
			AND wo.status = 'PAID'
	END
    
	--select	vendor_name							'Vendor Name'
	--		,convert(varchar, payment_date, 6)	'Payment Date'
	--		,no_kwitansi						'No Kwitansi'
	--		,plat_no							'Plat No'
	--		,customer							'Customer'
	--		,agreement_no						'Agreement No'
	--		,brand								'Brand'
	--		,object_lease						'Object Lease'
	--		,tahun								'Tahun'
	--		,chasiss_number						'chasiss_number'
	--		,engine_number						'engine_number'
	--		,actual_km							'actual_km'
	--		,spk_date							'spk_date'
	--		,category_asset						'Category Asset'
	--		,jasa								'Jasa'
	--		,pph								'PPH'
	--		,spare_part							'Spare Part'
	--		,sub_material						'Sub Material'
	--		,ppn								'PPN'	
	--		,material							'Meterai'
	--		,other								'Other'
	--		,total								'Total'
	--from	dbo.rpt_monitoring_payment with (nolock)
	--where	user_id = @p_user_id


	if not exists (select 1 from dbo.rpt_monitoring_payment where user_id = @p_user_id)
	begin
			insert into dbo.rpt_monitoring_payment
			(
				user_id
				,report_company
				,report_title
				,report_image
				,from_date
				,to_date
				,vendor_name
				,payment_date
				,no_kwitansi
				,plat_no
				,customer
				,AGREEMENT_NO
				,brand
				,object_lease
				,tahun
				,chasiss_number
				,engine_number
				,actual_km
				,spk_date
				,category_asset
				,jasa
				,pph
				,spare_part
				,sub_material
				,ppn
				,material
				,other
				,total
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
				,null
				,NULL
                ,null
				,null
				,null
				,null
				,null
				,null
				,null
                ,null
				,@p_is_condition
			)
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

