--Created, Rian at 27-12-2022

CREATE PROCEDURE dbo.xsp_rpt_berita_acara_serah_terima
(
	@p_code				nvarchar(50)
	,@p_user_id			nvarchar(50)
	,@p_bast_type		nvarchar(50)
	,@p_in_or_out		nvarchar(10)
)
as
begin
	delete dbo.rpt_berita_acara_serah_terima
	where	user_id = @p_user_id ;

	delete dbo.rpt_berita_acara_serah_terima_document
	where	user_id = @p_user_id ;

	declare @msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_image				nvarchar(250)
			,@pihak_pertama				nvarchar(250)	= ''
			,@alamat_pihak_pertama		nvarchar(250)	= ''
			,@no_tlp_pihak_pertama		nvarchar(15)	= ''
			,@pihak_kedua				nvarchar(250)	= ''
			,@alamat_pihak_kedua		nvarchar(250)	= ''
			,@no_tlp_pihak_kedua		nvarchar(15)	= ''
			,@doc_b						nvarchar(1)		= ''
			,@doc_r						nvarchar(1)		= ''
			,@doc_h						nvarchar(1)		= ''
			,@doc_t						nvarchar(1)		= ''
			,@status					nvarchar(10) 
			,@company_address			nvarchar(400)
			,@company_area_phone_no		nvarchar(5)
			,@company_phone_no			nvarchar(15)
			,@handover_from				nvarchar(50)
			,@keluar_masuk				nvarchar(50)
			,@image_asset				nvarchar(50)
			,@path_img_asset			nvarchar(50)
			,@type_asset				nvarchar(50)
			,@type_handover				nvarchar(50)
			,@asset_code				nvarchar(50)
			,@report_area_phone			nvarchar(4)
			,@report_phone_no			nvarchar(15)
			,@report_fax				nvarchar(15)
			,@report_fax_area			nvarchar(4)
			,@report_address2			nvarchar(4000)

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'BERITA ACARA SERAH TERIMA KENDARAAN';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		select @company_address = value 
		from	dbo.sys_global_param
		where	code = 'COMADD2'

		select	@company_area_phone_no 
		from	dbo.sys_global_param
		where	code = 'TELPAREA'

		SELECT	@company_phone_no = value
		from	dbo.sys_global_param
		where	code = 'TELP'

		select	@handover_from = handover_from
		from	dbo.handover_asset
		where	code = @p_code

		if	(@p_in_or_out = 'TERIMA')
		begin
			set	@keluar_masuk = 'MASUK (IN)'
		end
		else if (@p_in_or_out = 'KEMBALI')
		begin
			set	@keluar_masuk = 'KELUAR (OUT)'
		end

		if (@handover_from = 'INTERNAL')
		begin
			select	@pihak_kedua			= handover_to
					,@alamat_pihak_kedua	= handover_address
					,@no_tlp_pihak_kedua	= handover_phone_area + handover_phone_no
			from	dbo.handover_asset
			where	code = @p_code
		end
		else
		begin
			select	@pihak_pertama			= handover_to
					,@alamat_pihak_pertama	= handover_address
					,@no_tlp_pihak_pertama	= handover_phone_area + handover_phone_no
			from	dbo.handover_asset
			where	code = @p_code
		end

		select	@image_asset = value
		from	dbo.sys_global_param
		where	code = 'IMGASS'

		select	@asset_code = fa_code
		from	dbo.handover_asset
		where	code = @p_code ;

		select	@type_asset = case
					when mit.class_type_code = '11' then 'passenger'
					when mit.class_type_code = '12' then 'passenger'
					when mit.class_type_code = '13' then 'passenger'
					when mit.class_type_code = '14' then 'passenger'
					when mit.class_type_code = '24-TR' then 'box'
					when mit.class_type_code = '24-NTR' then 'doubleCabin'
					when mit.class_type_code = '21' then 'box'
					when mit.class_type_code = '22' then 'box'
					--when mit.class_type_code = 'COMM' then 'passenger'
					--when mit.class_type_code = 'COMMT' then 'passenger'
				end
		from	ifinbam.dbo.master_item mit
				inner join ifinams.dbo.asset ass on ass.ITEM_CODE = mit.CODE
		where	ass.code = @asset_code ;

		select @type_asset

		--set	@type_asset = 'doubleCabin'
		set	@path_img_asset = @image_asset + @type_asset + '.png'
		
		select @type_handover = type
		from dbo.handover_asset
		where fa_code = @p_code;

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
		
		insert into dbo.rpt_berita_acara_serah_terima
		(
			user_id
			,report_company
			,report_title
			,report_image
			,agreement_no
			,leesee
			,address
			,used_by
			,used_by_contact
			,user_by_phone
			,in_or_out
			,bast_type
			,bast_no
			,pihak_pertama
			,alamat_pihak_pertama
			,no_tlp_pihak_pertama
			,pihak_kedua
			,alamat_pihak_kedua
			,no_tlp_pihak_kedua
			,plat_no
			,merk_name
			,type_item_name
			,colour
			,chassis_no
			,engine_no
			,built_year
			,unit_condition
			,keluar_masuk
			,image_asset
			,company_address
			,stnk_date
			,area_phone
			,phone_no
			,fax
			,fax_area
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,hr.agreement_external_no
				,hr.client_name
				,ha.handover_address
				,case
					 when @type_handover = 'DELIVERY'
						  or @type_handover = 'MAINTENANCE OUT'
						  or @type_handover = 'RETURN OUT'
						  or @type_handover = 'REPLACE OUT' then ha.HANDOVER_TO
					 else ha.HANDOVER_FROM
				 end 'penerima'
				,ha.handover_to
				,ha.handover_phone_area + ha.handover_phone_no
				,@p_in_or_out
				,@p_bast_type
				,@p_code
				,ha.handover_from
				,isnull(@alamat_pihak_pertama, '')
				,isnull(@no_tlp_pihak_pertama, '')
				,isnull(ha.handover_to, '')
				,isnull(@alamat_pihak_kedua, '')
				,isnull(@no_tlp_pihak_kedua, '')
				,isnull(av.plat_no, isnull(ae.serial_no, isnull(ah.serial_no, isnull(am.serial_no, ''))))
				,isnull(av.merk_name, isnull(ae.merk_name, isnull(ah.merk_name, isnull(am.merk_name, ''))))
				,isnull(av.type_item_name, isnull(ae.type_item_name, isnull(ah.type_item_name, isnull(am.type_item_name, ''))))
				,isnull(av.colour, isnull(ah.colour, isnull(am.colour, '')))
				,isnull(av.chassis_no, isnull(ah.chassis_no, isnull(am.chassis_no, isnull(ae.serial_no, ''))))
				,isnull(av.engine_no, isnull(ah.engine_no, isnull(am.engine_no, isnull(ae.imei, ''))))
				,isnull(av.built_year, isnull(am.built_year, isnull(ah.built_year, '')))
				,isnull(ha.unit_condition, '')
				,@keluar_masuk
				,@path_img_asset
				,@company_address
				,isnull(av.stnk_date, av.keur_date)
				,@report_area_phone
				,@report_phone_no
				,@report_fax
				,@report_fax_area
		from	dbo.asset ass
				left join dbo.asset_vehicle av on (av.asset_code	= ass.code)
				left join dbo.asset_electronic ae on (ae.asset_code = ass.code)
				left join dbo.asset_he ah on (ah.asset_code			= ae.asset_code)
				left join dbo.asset_machine am on (am.asset_code	= ass.code)
				left join dbo.handover_asset ha on (ha.fa_code		= ass.code)
				left join dbo.handover_request hr on (hr.handover_code = ha.code)
		where	ha.code = @p_code ;

	
		insert into dbo.rpt_berita_acara_serah_terima_document
		(
			user_id
			,bast_no
			,doc_name
			,doc_b
			,doc_r
			,doc_h
			,doc_t
			,remark
		)
		select	@p_user_id
				,@p_code
				,bca.checklist_name
				,case checklist_status when 'BAIK' then 'v' else '' end
				,case checklist_status when 'RUSAK' then 'v' else '' end
				,case checklist_status when 'HILANG' then 'v' else '' end
				,case checklist_status when 'TIDAK ADA' then 'v' else '' end
				,hac.checklist_remark
		from	dbo.handover_asset_checklist hac
		left join dbo.master_bast_checklist_asset bca on (bca.code = hac.checklist_code)
		where	handover_code = @p_code ;
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

