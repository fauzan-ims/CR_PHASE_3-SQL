--Created by, bilal at 12/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_purchase_order_unit
(
	@p_user_id			nvarchar(50)
	,@p_po_no			nvarchar(50)
)
as
begin
	
	delete dbo.rpt_purchase_order_unit
	where user_id = @p_user_id

	delete dbo.rpt_purchase_order_unit_detail
	where user_id = @p_user_id

	declare	@msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_address			nvarchar(4000)
			,@depthead					nvarchar(250)
			,@branch_code				nvarchar(250)
			,@npwp_no					nvarchar(4000)
		    ,@terbilang					nvarchar(4000)
			,@report_area_phone			nvarchar(4)
			,@report_phone_no			nvarchar(15)
			,@report_fax				nvarchar(15)
			,@report_fax_area			nvarchar(4)
			,@report_address2			nvarchar(4000)
			,@max_date					datetime
			,@position_name				nvarchar(250)
			,@nama_pic					nvarchar(50)
			,@no_telp_pic				nvarchar(20)
	begin try
		
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param 
		where	code = 'COMP2';

		-- select company addrss
		select	@report_address = value
		from	dbo.sys_global_param
		where	code = 'COMPADD' ;

		-- select company addrss
		select	@report_address2 = value
		from	dbo.sys_global_param
		where	code = 'COMPADD2' ;

		-- select company addrss
		--select	@report_city = value
		--from	dbo.sys_global_param
		--where	code = 'COMCITY' ;

		-- select company area phone
		select	@report_phone_no = value
		from	dbo.sys_global_param
		where	code = 'TELP' ;

		-- select company phone
		select	@report_area_phone = value
		from	dbo.sys_global_param
		where	code = 'TELPAREA' ;

		-- select company fax
		select	@report_fax = value
		from	dbo.sys_global_param
		where	code = 'FAX' ;

		-- select company fax area
		select	@report_fax_area = value
		from	dbo.sys_global_param
		where	code = 'FAXAREA' ;

		select	@branch_code = branch_code
		from	dbo.purchase_order
		where	CODE = @p_po_no ;

		select	@nama_pic = value
		from	dbo.sys_global_param
		where	code = 'PICPORENT' ;

		select	@no_telp_pic = value
		from	dbo.sys_global_param
		where	code = 'PICNOPORENT' ;

		select	@depthead = sbs.signer_name 
				,@position_name = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		select	@npwp_no = value
		from	ifinopl.dbo.sys_global_param
		where	code = 'INVNPWP' ;

		select @max_date =  max(qrd.quotation_review_date) 
		from dbo.purchase_order po
		inner join dbo.purchase_order_detail pod on (pod.po_code = po.code)
		inner join dbo.supplier_selection_detail ssd on (ssd.id = pod.supplier_selection_detail_id)
		--inner join dbo.quotation_review_detail qrd on (ssd.supplier_code collate Latin1_General_CI_AS = qrd.supplier_code)
		inner join dbo.quotation_review_detail qrd on (ssd.supplier_code collate Latin1_General_CI_AS = qrd.supplier_code and qrd.id = ssd.quotation_detail_id)
		where po.CODE = @p_po_no

		set	@report_title = 'Purchase Order'

		-- (+) Ari 2023-11-27 ket : add table detail 
		declare @table_temp	table
		(
			user_id				nvarchar(50)
			,deskripsi_item		nvarchar(4000)
			,jumlah				int
			,harga				decimal(18,2)
			,total				decimal(18,2)
			,terbilang			nvarchar(250)
		)

		insert into dbo.rpt_purchase_order_unit
		(
		    user_id
		    ,po_no
		    ,report_company
		    ,report_title
		    ,report_image
		    ,report_address
			,report_area_phone
			,report_phone_no
			,report_fax_area
			,report_fax
			,report_address2
			,purchase_type
			,PPN_PCT
		    ,tanggal_terbit
		    ,nama_supplier
		    ,alamat_supplier
		    ,up_name
		    ,nama_klien
		    ,alamat_klien
			,DIKIRIM_KEPADA
			,ALAMAT_KEPADA
			,PIC
			,NO_TELP_PIC
		    ,tanggal_penawaran
		    ,npwp_no
		    ,nama_head
		    ,position_name
			,bbn_name
			,bbn_address
			,spaf_amount
			,subvention_amount
			,is_spesific_address
			,delivery_name
			,delivery_address
			,max_date
		)
		select	distinct
				@p_user_id
				,@p_po_no
				,@report_company
				,@report_title
				,@report_image
				,@report_address
				,@report_area_phone
				,@report_phone_no
				,@report_fax_area
				,@report_fax
				,@report_address2
				,po.unit_from
				,isnull(ppn.pct,0)
				,dbo.xfn_get_system_date()
				,po.supplier_name
				,isnull(po.supplier_address, '-')
				--,case
				--	 when mv.address = '' then '-'
				--	 when mv.address is null then isnull(mv.address, '-')
				--	 else mv.address
				-- end
				,isnull(mv.contact_name, '-')
				,case
					 when po.is_spesific_address = '0' then @report_company -- karena no info address supplier karoserinya. maka selalu me main supplier
					 when po.is_spesific_address = '1' then po.delivery_name
					 else ''
				 end
				,case
					 when po.is_spesific_address = '0' then @report_address -- karena no info address supplier karoserinya. maka selalu me main supplier
					 when po.is_spesific_address = '1' then po.delivery_address
					 else ''
				 end
				,@report_company
				,@report_address2
				,@nama_pic
				,@no_telp_pic
				,qrd.quotation_review_date
				,@npwp_no
				,@depthead
				,@position_name
				--,case
				--	when isnull(pri.is_bbn,pri2.is_bbn)='1' then isnull(pri.bbn_name,pri2.bbn_name)
				--	else @report_company
				--end
				,case
					when aas.plat_colour = 'KUNING' -- (+) Ari 2023-11-24 ket : jika plat kuning ambil bbn dari application
					then aas.client_bbn_name		
					else case
							when isnull(pri.is_bbn,pri2.is_bbn)='1' 
							then isnull(pri.bbn_name,pri2.bbn_name)
							else @report_company
						 end							
				end
				--,case
				--	when isnull(pri.is_bbn,pri2.is_bbn)='1' then isnull(pri.bbn_address,pri2.bbn_address)
				--	else @report_address
				--end
				,case
					when aas.plat_colour = 'KUNING' -- (+) Ari 2023-11-24 ket : jika plat kuning ambil bbn dari application
					then aas.client_bbn_address
					else case
							when isnull(pri.is_bbn,pri2.is_bbn)='1'
							then isnull(pri.bbn_address,pri2.bbn_address)
							else @report_address
						end	
				end
				,isnull(prc.spaf_amount, 0)
				,isnull(prc.subvention_amount, 0)
				,isnull(po.is_spesific_address, 0)
				,po.delivery_name
				,po.delivery_address
				,@max_date
		from	dbo.purchase_order po
				left join ifinbam.dbo.master_vendor mv with (nolock) on (mv.code							  = po.supplier_code)
				left join dbo.purchase_order_detail pod with (nolock) on (pod.po_code						  = po.code)
				left join dbo.supplier_selection_detail ssd with (nolock) on (ssd.id						  = pod.supplier_selection_detail_id)
				left join dbo.quotation_review_detail qrd with (nolock) on (qrd.id						  = ssd.quotation_detail_id)
				left join dbo.quotation_review qr with (nolock) on (qr.code collate latin1_general_ci_as	  = qrd.quotation_review_code)
				left join dbo.procurement prc with (nolock) on (prc.code collate latin1_general_ci_as		  = qrd.reff_no)
				left join dbo.procurement prc2 with (nolock) on (prc2.code								  = ssd.reff_no)
				left join dbo.procurement_request pr with (nolock) on (pr.code							  = prc.procurement_request_code)
				left join dbo.procurement_request pr2 with (nolock) on (pr2.code							  = prc2.procurement_request_code)
				left join dbo.procurement_request_item pri with (nolock) on (pri.procurement_request_code	  = pr.code)
				left join dbo.procurement_request_item pri2 with (nolock) on (pri2.procurement_request_code = pr2.code)
				left join ifinopl.dbo.application_asset aas with (nolock)on (aas.asset_no				  = isnull(pr.asset_no, pr2.asset_no))
				left join ifinopl.dbo.application_main aam with (nolock) on (aam.application_no			  = aas.application_no)
				outer apply (
					select	top 1
							ppn_pct 'pct'
					from	dbo.purchase_order_detail
					where	po_code = @p_po_no
							and ppn_pct is not null 
				)ppn
		where	po.code = @p_po_no ;

		select  @terbilang = dbo.Terbilang((sum(((price_amount - discount_amount) * order_quantity)+ ppn_amount)))
		from dbo.purchase_order_detail
		where po_code = @p_po_no

		insert into dbo.rpt_purchase_order_unit_detail
		(
			user_id
			,deskripsi_item
			,jumlah
			,harga
			,total
			,terbilang
		)
		select @p_user_id 
			--,pod.item_name+ ', ' +
			--case
			--	when isnull(pod.SPESIFICATION,'')='' then ''
			--	else pod.SPESIFICATION
			--end
			--+ ', ' + isnull(pod.offering,'-') +' - ETA Date: '+convert(nvarchar(10), pod.eta_date, 103)
			,case
			when po.unit_from='RENT' then	pod.item_name+ ', ' +
											case
												when isnull(pod.spesification,'')='' then ''
												else pod.spesification
											end
											+ ', ' + isnull(lower(pod.offering),'-') --
											+ isnull(am.application_remarks,'') + ' Plat Colour : ' + isnull(aas.plat_colour,'')
			else
											pod.item_name+ ', ' +
											case
												when isnull(pod.SPESIFICATION,'')='' then ''
												else pod.SPESIFICATION
											end
											+ ', ' + isnull(lower(pod.offering),'-') + ', ' + isnull(am.application_remarks,'') 
											+ case
												when isnull(aas.plat_colour,'') = '' then ''
												else ' Plat Colour : ' + isnull(aas.plat_colour,'') 
											  end
											+ ' - eta date: '+convert(nvarchar(10), pod.eta_date, 103) 
											end
			,sum(pod.order_quantity)
			,(pod.price_amount - pod.discount_amount)
			,((pod.price_amount - pod.discount_amount) * pod.order_quantity) + pod.ppn_amount
			,@terbilang 
		from dbo.purchase_order_detail pod
		INNER join dbo.purchase_order po on po.code = pod.po_code
		-- (+) Ari 2023-11-24 ket : get remarks from applicationmain'
		left	join dbo.supplier_selection_detail ssd on (ssd.id = pod.supplier_selection_detail_id)
		left	join quotation_review_detail qrd on (qrd.id = ssd.quotation_detail_id)
		left	join dbo.procurement pro on (pro.code collate latin1_general_ci_as = qrd.reff_no)
		left	join dbo.procurement_request pr on (pr.code = pro.procurement_request_code)
		left	join ifinopl.dbo.application_asset aas on (aas.asset_no = pr.asset_no)
		left	join ifinopl.dbo.application_main am on (am.application_no = aas.application_no)
		where	po_code = @p_po_no
		group	by	pod.item_name
					,po.unit_from
					,pod.spesification
					,pod.offering
					,am.application_remarks
					,aas.plat_colour
					,pod.eta_date
					,pod.price_amount
					,pod.discount_amount
					,pod.order_quantity
					,pod.ppn_amount

		-- (+) Ari 2023-11-27 ket : summary per item
		begin
			update	rpt_purchase_order_unit_detail
			set		deskripsi_item = replace(deskripsi_item,substring(deskripsi_item,26,35),'')
			where	user_id = @p_user_id

			insert into @table_temp
			(
				user_id
				,deskripsi_item
				,jumlah
				,harga
				,total
				,terbilang
			)
			select	distinct
					user_id
					,deskripsi_item
					,sum(jumlah)
					,harga
					,sum(total)
					,terbilang
			from	dbo.rpt_purchase_order_unit_detail 
			where	user_id = @p_user_id
			group	by user_id
					,deskripsi_item
					,jumlah
					,harga
					,total
					,terbilang

			delete	rpt_purchase_order_unit_detail 
			where	user_id = @p_user_id

			insert into dbo.rpt_purchase_order_unit_detail
			(
				user_id
				,deskripsi_item
				,jumlah
				,harga
				,total
				,terbilang
			)
			select	user_id
					,deskripsi_item
					,jumlah
					,harga
					,total
					,terbilang
			from	@table_temp

		end
		-- (+) Ari 2023-11-27

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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
END
