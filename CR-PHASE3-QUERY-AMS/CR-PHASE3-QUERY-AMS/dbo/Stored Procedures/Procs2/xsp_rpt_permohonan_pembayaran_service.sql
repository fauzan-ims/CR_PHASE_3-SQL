CREATE PROCEDURE dbo.xsp_rpt_permohonan_pembayaran_service
(
	@p_code				nvarchar(50)
	,@p_user_id			nvarchar(50)
)
as
BEGIN
	delete	dbo.rpt_permohonan_pembayaran_service
	where	user_id = @p_user_id ;

	delete	dbo.RPT_SURAT_PERMOHONAN_PEMBAYARAN_SERVICE_JASA
	where	user_id = @p_user_id ;

	delete	dbo.RPT_SURAT_PERMOHONAN_PEMBAYARAN_SERVICE_ITEM
	where	user_id = @p_user_id ;


	declare @msg				   nvarchar(max)
			,@report_company	   nvarchar(250)
			,@report_title		   nvarchar(250)
			,@report_image		   nvarchar(250)
			,@terbilang			   nvarchar(250)
			,@total_jasa		   decimal(18,2)
			,@total_item		   decimal(18,2)
			,@total_terbilang	   decimal(18,2)
			,@grand_total		   decimal(18,2)
			,@total_ppn				DECIMAL(18,2)
			,@total_pph				DECIMAL(18,2)
			,@total					DECIMAL(18,2)
			,@total_ppn_jasa		DECIMAL(18,2)
			,@total_pph_jasa		DECIMAL(18,2)
			,@total_ppn_item		DECIMAL(18,2)
			,@total_pph_item		DECIMAL(18,2)
			,@total_amount_item		DECIMAL(18,2)
			,@total_amount_jasa		DECIMAL(18,2)
			,@spk_no				NVARCHAR(50);
			

	BEGIN TRY
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'SURAT PERMOHONAN PEMBAYARAN SERVICE';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		--SELECT  @total_jasa = isnull(sum(wo.payment_amount),0)
		--from	dbo.work_order wo
		--		left join dbo.work_order_detail wod on (wod.work_order_code = wo.code)
		--where	wo.code = @p_code
		--		and wod.service_type = 'JASA'

		--SELECT  @total_item = isnull(sum(wo.payment_amount),0)
		--from	dbo.work_order wo
		--		left join dbo.work_order_detail wod on (wod.work_order_code = wo.code)
		--where	wo.code = @p_code
		--		and wod.service_type = 'ITEM'

		--set @total_terbilang = isnull(@total_jasa,0) + isnull(@total_item,0)

		--set @terbilang = dbo.Terbilang(@total_terbilang) 

		--SET @grand_total = isnull(@total_jasa,0) + isnull(@total_item,0)

		insert into dbo.rpt_permohonan_pembayaran_service
		(
			user_id
			,report_company
			,report_title
			,report_image
			,tanggal
			,kode_cabang
			,nama_cabang
			,nama_unit
			,no_rangka
			,no_mesin
			,actual_km
			,pekerjaan
			,terbilang
			,bank
			,nomor
			,rek_name
			,code_wo
			,plat_no
			,built_year
			,merk
			,spk_no
			,work_date
			,vendor_name
			,grand_total
			,TOTAL_PPN
			,TOTAL_PPH
			,TOTAL
			
		)
		select	top 1
				@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,mnt.transaction_date
				,mnt.branch_code
				,mnt.branch_name
				,ass.item_name
				,av.chassis_no
				,av.engine_no
				,wo.actual_km
				--,mnt.actual_km
				,mnt.remark
				,''
				,isnull(mnt.vendor_bank_name, '')
				,isnull(mnt.vendor_bank_account_no, '')
				,isnull(mnt.vendor_bank_account_name, '')
				,wo.code
				,av.plat_no
				,av.built_year
				,av.merk_name
				,mnt.spk_no'spk_no'
				,wo.work_date
				,case when mnt.vendor_code = 'v240800005' then left(mnt.vendor_name,87) else mnt.vendor_name end
				,0
				,0
				,0
				,0
		from	dbo.work_order wo
				left join dbo.maintenance_detail md on (md.maintenance_code = wo.maintenance_code)
				left join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
				left join dbo.asset ass on (ass.code = wo.asset_code)
				left join dbo.asset_vehicle av on (av.asset_code = ass.code)
		where	wo.code = @p_code

		insert into dbo.rpt_surat_permohonan_pembayaran_service_jasa
		(
			user_id
			,part
			,service_fee
			,quantity
			,total_amount
			,pph
			,ppn
			,total_payment
		)
		select	@p_user_id
				,wod.service_name
				,wod.service_fee
				,wod.quantity
				,wod.total_amount
				,wod.pph_amount
				,wod.ppn_amount
				,wod.payment_amount
				--,wo.total_amount
				--,wo.total_ppn_amount
				--,wo.total_pph_amount
				--,wo.payment_amount
		from dbo.work_order wo
		left join dbo.work_order_detail wod on (wod.work_order_code = wo.code)
		where wo.code = @p_code
		and wod.service_type = 'JASA'

		insert into dbo.rpt_surat_permohonan_pembayaran_service_item
		(
			user_id
			,part
			,service_fee
			,quantity
			,total_amount
			,pph
			,ppn
			,total_payment
		)
		select	@p_user_id
				,wod.service_name
				,wod.service_fee
				,wod.quantity
				,wod.total_amount
				,wod.pph_amount
				,wod.ppn_amount
				,wod.payment_amount
				--,wo.total_amount
				--,wo.total_pph_amount
				--,wo.total_ppn_amount
				--,wo.payment_amount
		from dbo.work_order wo
		left join dbo.work_order_detail wod on (wod.work_order_code = wo.code)
		where wo.code = @p_code
		and wod.service_type = 'ITEM'

		SELECT @total_item = SUM(total_payment),
		@total_pph_item = SUM(PPH),
		@total_ppn_item = SUM(ppn),
		@total_amount_item = sum(total_amount)
		FROM dbo.RPT_SURAT_PERMOHONAN_PEMBAYARAN_SERVICE_ITEM
		WHERE user_id = @p_user_id

		SELECT @total_jasa = SUM(total_payment),
		@total_pph_jasa = SUM(PPH),
		@total_ppn_jasa = SUM(ppn),
		@total_amount_jasa = sum(total_amount)
		FROM dbo.RPT_SURAT_PERMOHONAN_PEMBAYARAN_SERVICE_JASA
		WHERE user_id = @p_user_id

		set @total_terbilang = isnull(@total_jasa,0) + isnull(@total_item,0)
		set @terbilang = dbo.Terbilang(@total_terbilang) 

		set @total = isnull(@total_amount_jasa,0) + isnull(@total_amount_item,0)
		set @total_ppn = isnull(@total_ppn_item,0) + isnull(@total_ppn_jasa,0)
		set @total_pph = isnull(@total_pph_item,0) + isnull(@total_pph_jasa,0)
		set @grand_total = isnull(@total_jasa,0) + isnull(@total_item,0)

		update dbo.rpt_permohonan_pembayaran_service 
		set grand_total = isnull(@grand_total,0),
		terbilang = @terbilang,
		total = isnull(@total,0),
		total_ppn = isnull(@total_ppn,0),
		total_pph = isnull(@total_pph,0)
		where user_id = @p_user_id

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

