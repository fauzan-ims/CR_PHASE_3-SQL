--Created by, bilal at 12/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_purchase_order_karoseri
(
	@p_user_id				nvarchar(50)
	,@p_po_no				nvarchar(50)
	,@p_is_mobilisasi		NVARCHAR(1)
)
as
begin
	
	delete dbo.rpt_purchase_order_karoseri
	where user_id = @p_user_id

	delete dbo.rpt_purchase_order_karoseri_detail
	where user_id = @p_user_id

	declare	@msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_address			nvarchar(4000)
		    ,@tanggal_terbit			datetime
		    ,@nama_supplier				nvarchar(50)
		    ,@alamat_supplier			nvarchar(4000)
		    ,@up_name					nvarchar(50)
		    ,@employee_name				nvarchar(50)
		    ,@tanggal_penawaran			datetime
		    ,@npwp_no					nvarchar(4000)
		    ,@head_name					nvarchar(50)
		    ,@position_name				nvarchar(50)
			,@depthead					nvarchar(250)
			,@branch_code				nvarchar(250)
		    ,@terbilang					nvarchar(4000)
			,@report_area_phone			nvarchar(4)
			,@report_phone_no			nvarchar(15)
			,@report_fax				nvarchar(15)
			,@report_fax_area			nvarchar(4)
			,@report_address2			nvarchar(4000)
			,@ppn						nvarchar(250)
			,@max_date					datetime

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

		set	@report_title = 'Purchase Order'

		select @max_date =  max(qrd.quotation_review_date) 
		from dbo.purchase_order po
		inner join dbo.purchase_order_detail pod on (pod.po_code = po.code)
		inner join dbo.supplier_selection_detail ssd on (ssd.id = pod.supplier_selection_detail_id)
		inner join dbo.quotation_review_detail qrd on (ssd.supplier_code collate Latin1_General_CI_AS = qrd.supplier_code)
		where po.CODE = @p_po_no;

		insert into dbo.rpt_purchase_order_karoseri
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
		    ,tanggal_terbit
		    ,nama_supplier
		    ,alamat_supplier
			,nama_penerima
			,alamat_penerima
		    ,up_name
		    ,employee_name
		    ,tanggal_penawaran
		    ,npwp_no
		    ,head_name
		    ,position_name
			,ppn
			,IS_MOBILISASI
			--,quotation_date
			--,spaf_amount
			--,subvention_amount
		)
		select	@p_user_id
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
				,dbo.xfn_get_system_date()
				,po.supplier_name
				,po.supplier_address
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
				--,case
				--	 when mv.address = '' then '-'
				--	 when mv.address is null then isnull(mv.address, '-')
				--	 else mv.address
				-- end
				,isnull(mv.contact_name, '-')
				,''
				,@max_date --po.order_date
				,@npwp_no
				,@depthead
				,@position_name
				,case
					 when po.ppn_amount <> 0 then 'Harga sudah termasuk PPN 11 %.'
					 else 'Harga Non PPN'
				 end
				,@p_is_mobilisasi --@is_mobilisasi
		--,qr.quotation_review_date
		--,prc.spaf_amount
		--,prc.subvention_amount
		from	dbo.purchase_order_detail pod
				inner join dbo.purchase_order po on (po.code							   = pod.po_code)
				inner join dbo.supplier_selection_detail ssd on (ssd.id					   = pod.supplier_selection_detail_id)
				left join dbo.quotation_review_detail qrd on (qrd.id					   = ssd.quotation_detail_id)
				left join dbo.quotation_review qr on (qr.code collate Latin1_General_CI_AS = qrd.quotation_review_code)
				left join ifinbam.dbo.master_vendor mv on (mv.code		   = po.supplier_code)
		--left join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS							 = qrd.reff_no)
		--left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
		--left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
		--left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
		--left join ifinopl.dbo.application_asset aas on (aas.asset_no = isnull(pr.asset_no, pr2.asset_no))
		--left join ifinopl.dbo.application_main aam on (aam.application_no = aas.application_no)
		where	po.code = @p_po_no ;
		
		select  @terbilang = dbo.Terbilang(sum(((price_amount - discount_amount) * order_quantity) + ppn_amount))
		from dbo.purchase_order_detail
		where po_code = @p_po_no

		insert into dbo.rpt_purchase_order_karoseri_detail
		(
			user_id
			,deskirpsi_item
			,jumlah
			,harga
			,total
			,terbilang
		)
		select	distinct @p_user_id
				,case
					 when @p_is_mobilisasi = '0' then pod.item_name + ', ' + case
																			   when isnull(pod.spesification, '') = '' then ''
																			   else isnull(pod.spesification,'')
																		   END	--+ ', ' + am.application_remarks 
																				+ ', Plat Colour : ' + isnull(aas.plat_colour ,'-')
																				+ ' - ETA Date: ' + convert(nvarchar(10), pod.eta_date, 103)
					 else isnull(pod.item_name,'') + ', ' + isnull((pri.fa_name),'') + ', ' + isnull(avi.plat_no,'') + ', ' + case
																													  when isnull(pod.SPESIFICATION, '') = '' then ''
																													  else isnull(pod.SPESIFICATION,'')
																												  end	--+ ', rute : jakarta - bali, '  -- (+) Ari 2023-12-19 ket : dicomment karena knp di hardcode ?
																														+ isnull(pod.offering, '-') 
																														--+ am.application_remarks 
																														+ ', Plat Colour : ' + isnull(aas.plat_colour,'')
				 end
				,pod.order_quantity--det.qty
				,case
					when @p_is_mobilisasi = '0' then case
															when po.ppn_amount <> 0 then qrd.nett_price
															else pod.price_amount - pod.discount_amount
														end	
					else pod.price_amount - pod.discount_amount
				end
				,((pod.price_amount - pod.discount_amount) * pod.order_quantity) + pod.ppn_amount
				,@terbilang --+ 'Rupiah'
		from	dbo.purchase_order_detail pod
				inner join dbo.purchase_order po on (po.code = pod.po_code)
				inner join dbo.supplier_selection_detail ssd on (ssd.id						  = pod.supplier_selection_detail_id)
				left join dbo.quotation_review_detail qrd on (qrd.id						  = ssd.quotation_detail_id)
				left join dbo.quotation_review qr on (qr.code collate Latin1_General_CI_AS	  = qrd.quotation_review_code)
				inner join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS		  = isnull(qrd.reff_no,ssd.reff_no))
				inner join dbo.procurement_request pr on (pr.code			  = prc.procurement_request_code)
				inner join dbo.procurement_request_item pri on (pri.ID	  = prc.PROCUREMENT_REQUEST_ITEM_ID)
				left join ifinams.dbo.asset ast on (pri.fa_code			  = ast.code)
				left join ifinams.dbo.ASSET_VEHICLE avi on (avi.asset_code = ast.code)
				OUTER APPLY (
								SELECT  SUM(pode.ORDER_QUANTITY)'qty'
								FROM	dbo.PURCHASE_ORDER_DETAIL pode
								WHERE	pode.PO_CODE = pod.PO_CODE
								AND		pode.PO_CODE = po.CODE						

							)det
				--outer apply 
				--(
				--	select	pri.fa_name 'fa_name'
				--			,avi.plat_no 'plat_no'
				--	from	ifinproc.dbo.procurement_request_item pri
				--			left join ifinams.dbo.asset ast on (pri.fa_code			   = ast.code)
				--			left join ifinams.dbo.asset_vehicle avi on (avi.asset_code = ast.code)
				--	where	pri.procurement_request_code = pr.code
				--) a
				left join ifinopl.dbo.application_asset aas on (aas.asset_no = pr.asset_no)
				left join ifinopl.dbo.application_main am on (am.application_no = aas.application_no)
		where	pod.po_code = @p_po_no ;

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
