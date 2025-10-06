--created by, Rian at 26/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_surat_peringatan_ii
(
	@p_user_id				nvarchar(50)
	,@p_letter_no			nvarchar(50)
	--
	,@p_cre_by				nvarchar(15)
	,@p_cre_date			datetime
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_by				nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg					nvarchar(max)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_comany_name	nvarchar(250)
			,@report_company_city	nvarchar(250)
			,@bank_name				nvarchar(50)
			,@bank_account_name		nvarchar(250)
			,@bank_account_no		nvarchar(50)
			,@nomor_surat			nvarchar(50)
			,@tanggal_surat			datetime
			,@client_name			nvarchar(250)
			,@client_address		nvarchar(4000)
			,@direkrtur_lessee		nvarchar(250)
			,@agreement_no			nvarchar(50)
			,@agreement_date		datetime
			,@invoice_no			nvarchar(50)
			,@jumlah_unit			int
			,@nama_object_lease		nvarchar(250)
			,@tahun_object_lease	nvarchar(4)
			,@periode_pemakaian		nvarchar(250)
			,@nilai_sewa			decimal(18,2)
			,@denda_keterlambatan	decimal(18,2)
			,@tanggal_jatuh_tempo	datetime
			,@tanggal_pelunasan		datetime
			,@dept_head_opl			nvarchar(250)
			,@penasihat_hukum		nvarchar(250)
			,@merk					nvarchar(250)
			,@asset_year			nvarchar(4)
			,@chassis_no			nvarchar(50)
			,@engine_no				nvarchar(50)
			,@year					nvarchar(4)
			,@month					nvarchar(2)
			,@nomor_surat_sp_1		nvarchar(50)
			,@tanggal_surat_sp_1	nvarchar(50)
			,@letter_no				nvarchar(50)
			,@agreement_no_find		nvarchar(50)
			,@depthead				nvarchar(50)
			,@branch_code_dept		nvarchar(50)
			,@nama					nvarchar(50)
			,@jabatan				nvarchar(250)
			,@count_unit			int
			,@sp					int

	begin try

		delete	dbo.rpt_surat_peringatan_ii
		where	user_id = @p_user_id

		delete	dbo.rpt_surat_peringatan_ii_lampiran_i
		where	user_id = @p_user_id

		select	@report_comany_name = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set @report_title = 'Peringatan Kelalaian Pembayaran Uang Sewa Operasi (Operating Lease)' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@bank_name = value
		from	dbo.sys_global_param
		where	code = 'BANK' ;

		select	@bank_account_name = value
		from	dbo.sys_global_param
		where	code = 'BANKNAME' ;

		select	@bank_account_no = value
		from	dbo.sys_global_param
		where	code = 'BANKNO' ;

		select	@report_company_city = value
		from	dbo.sys_global_param
		where	code = 'COMCITY' ;

		select	@agreement_no_find = wl.agreement_no
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
		where	wl.letter_no = @p_letter_no ;

		SELECT	TOP 1 @nomor_surat_sp_1 = letter_no
				,@tanggal_surat_sp_1 = letter_date
		FROM	dbo.warning_letter
		WHERE	letter_type		 = 'SP1'
				AND letter_status <> 'CANCEL'
				AND letter_status <> 'HOLD'
				AND agreement_no = @agreement_no_find 
		ORDER BY LETTER_DATE desc;

		select	@branch_code_dept = am.branch_code
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
				left join dbo.agreement_invoice ai on (ai.agreement_no = wl.agreement_no)
				left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
		where	wl.letter_no = @p_letter_no ;

		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code_dept ;

		select	@penasihat_hukum = value
		from	dbo.sys_global_param
		where	code = 'PNSHTHKM' ;

		
		-- (+) Ari 2023-12-28 ket : get from global param, infonya pakai yg somasi
		select	@sp = value 
		from	dbo.sys_global_param
		where	code = 'DKPAS'
		
		insert into dbo.rpt_surat_peringatan_ii
		(
			user_id
			,report_image
			,report_title
			,report_comany_name
			,report_company_city
			,bank_name
			,bank_account_name
			,bank_account_no
			,nomor_surat
			,tanggal_surat
			,client_name
			,client_address
			,direkrtur_lessee
			,agreement_no
			,agreement_date
			,invoice_no
			,periode_pemakaian
			,NO_PERIODE
			,nilai_sewa
			,denda_keterlambatan
			,tanggal_jatuh_tempo
			,tanggal_pelunasan
			,dept_head_opl
			,jabatan
			,penasihat_hukum
			,nomor_surat_sp_1
			,tanggal_surat_pertama
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct @p_user_id
				,@report_image
				,@report_title
				,@report_comany_name
				,@report_company_city
				,@bank_name
				,@bank_account_name
				,@bank_account_no
				,wldd.letter_code
				,wl.letter_date
				,am.client_name
				,agas.billing_to_address --cad.address
				,''--cci.full_name
				,am.agreement_external_no
				,am.agreement_date
				,inv.invoice_external_no
				,invd.description--'Billing ke ' + cast(period.billing_no as nvarchar(15)) + N' dari Periode '
                            --+ convert(varchar(30), period.period_date, 103) + N' Sampai dengan '
                            --+ convert(varchar(30), period.period_due_date, 103)
				,invd.billing_no
				,inv.total_billing_amount + inv.total_ppn_amount
				,ao.obligation_amount
				,inv.invoice_due_date
				,dateadd(day, @sp, wl.letter_date)
				,@nama
				,@jabatan
				,@penasihat_hukum
				,isnull(@nomor_surat_sp_1,'-')
				,@tanggal_surat_sp_1
				--
				,@p_cre_date	  
				,@p_cre_by		  
				,@p_cre_ip_address
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
				left join dbo.invoice_detail invd on (invd.agreement_no = wl.agreement_no)
				inner join dbo.invoice inv on (inv.invoice_no = invd.invoice_no and inv.invoice_status='POST' and inv.invoice_due_date <= dbo.xfn_get_system_date() and inv.invoice_type='RENTAL')
				left join dbo.agreement_main am on (am.agreement_no = invd.agreement_no)
				left join dbo.agreement_obligation ao on (ao.agreement_no = invd.agreement_no and ao.asset_no = invd.asset_no and ao.invoice_no = invd.invoice_no and ao.obligation_type = 'OVDP')
				--left join dbo.agreement_asset_amortization aaa on (aaa.agreement_no = invd.agreement_no and aaa.asset_no = invd.asset_no and aaa.billing_no = invd.billing_no)
				left join dbo.application_main apa on (apa.application_no = am.application_no)
				left join dbo.client_address cad on (cad.client_code = apa.client_code and cad.is_legal='1' and isnull(cad.address,'')<>'')
				left join dbo.client_relation cci on (
														 cci.client_code = am.client_no
														 and   cci.relation_type = 'SHAREHOLDER'
													 )
				--outer apply
				--	(
				--		select	aas.asset_name
				--				,aas.asset_year
				--		from	dbo.agreement_asset aas
				--		where	aas.agreement_no = wl.agreement_no
				--	) agas
				outer apply
				(
					select	aas.billing_to_address
					from	dbo.agreement_asset aas
					where	aas.agreement_no = wl.agreement_no
				) agas
				outer apply
					(
						select	count(aas.asset_no) 'jumlah_asset'
						from	dbo.agreement_asset aas
						where	aas.agreement_no = wl.agreement_no
					) agast
				--outer apply
				--	(
				--		select	asset_no
				--				,billing_no
				--				,period_date
				--				,period_due_date
				--		from	dbo.xfn_due_date_period(invd.asset_no,invd.billing_no) aa
				--		where	aa.billing_no = invd.billing_no
				--		and		aa.asset_no = invd.asset_no
				--	)period
		where	wldd.letter_code = @p_letter_no
		ORDER BY inv.INVOICE_DUE_DATE desc;

		if not exists (select * from dbo.RPT_SURAT_PERINGATAN_II where user_id = @p_user_id)
		begin
			insert into dbo.RPT_SURAT_PERINGATAN_II
			(
				user_id
				,report_image
				,report_title
				,report_comany_name
				,report_company_city
				,bank_name
				,bank_account_name
				,bank_account_no
				,nomor_surat
				,tanggal_surat
				,client_name
				,client_address
				,direkrtur_lessee
				,agreement_no
				,agreement_date
				,invoice_no
				,periode_pemakaian
				,NO_PERIODE
				,nilai_sewa
				,denda_keterlambatan
				,tanggal_jatuh_tempo
				,tanggal_pelunasan
				,dept_head_opl
				,jabatan
				,penasihat_hukum
				,nomor_surat_sp_1
				,tanggal_surat_pertama
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	distinct @p_user_id
				,@report_image
				,@report_title
				,@report_comany_name
				,@report_company_city
				,@bank_name
				,@bank_account_name
				,@bank_account_no
				,wldd.letter_code
				,wl.letter_date
				,am.client_name
				,agas.billing_to_address --cad.address
				,''--cci.full_name
				,am.agreement_external_no
				,am.agreement_date
				,null--inv.invoice_external_no
				,null--invd.description--'Billing ke ' + cast(period.billing_no as nvarchar(15)) + N' dari Periode '
                 --           --+ convert(varchar(30), period.period_date, 103) + N' Sampai dengan '
                 --           --+ convert(varchar(30), period.period_due_date, 103)
				,null--invd.billing_no
				,null--invd.billing_amount + invd.ppn_amount
				,null--ao.obligation_amount
				,null--inv.invoice_due_date
				,dateadd(day, @sp, wl.letter_date)
				,@nama
				,@jabatan
				,@penasihat_hukum
				,isnull(@nomor_surat_sp_1,'-')
				,@tanggal_surat_sp_1
				--
				,@p_cre_date	  
				,@p_cre_by		  
				,@p_cre_ip_address
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
				--left join dbo.invoice_detail invd on (invd.agreement_no = wl.agreement_no)
				--inner join dbo.invoice inv on (inv.invoice_no = invd.invoice_no)
				left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
				--left join dbo.agreement_obligation ao on (ao.agreement_no = invd.agreement_no and ao.asset_no = invd.asset_no and ao.invoice_no = invd.invoice_no and ao.obligation_type = 'OVDP')
				----left join dbo.agreement_asset_amortization aaa on (aaa.agreement_no = invd.agreement_no and aaa.asset_no = invd.asset_no and aaa.billing_no = invd.billing_no)
				left join application_main apa on (apa.application_no = am.application_no)
				left join dbo.client_address cad on (cad.client_code = apa.client_code and cad.is_legal='1' and isnull(cad.address,'')<>'')
				left join dbo.client_relation cci on (
														 cci.client_code = am.client_no
														 and   cci.relation_type = 'SHAREHOLDER'
													 )
				--outer apply
				--	(
				--		select	aas.asset_name
				--				,aas.asset_year
				--		from	dbo.agreement_asset aas
				--		where	aas.agreement_no = wl.agreement_no
				--	) agas
				outer apply
				(
					select	aas.billing_to_address
					from	dbo.agreement_asset aas
					where	aas.agreement_no = wl.agreement_no
				) agas
				outer apply
					(
						select	count(aas.asset_no) 'jumlah_asset'
						from	dbo.agreement_asset aas
						where	aas.agreement_no = wl.agreement_no
					) agast
				--outer apply
				--	(
				--		select	asset_no
				--				,billing_no
				--				,period_date
				--				,period_due_date
				--		from	dbo.xfn_due_date_period(invd.asset_no,invd.billing_no) aa
				--		where	aa.billing_no = invd.billing_no
				--		and		aa.asset_no = invd.asset_no
				--	)period
		where	wldd.letter_code = @p_letter_no;
		end

		insert into dbo.rpt_surat_peringatan_ii_lampiran_i
		(
			user_id
			,nomor_surat
			,tanggal_surat_peringatan
			,main_contract_no
			,agreement_no
			,agreement_date
			,asset_name
			,vehicle_type
			,brand
			,year
			,chassis_no
			,engine_no
			,plat_no
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct
				@p_user_id
				,wldd.letter_code
				,wl.letter_date
				,aext.main_contract_no
				,am.agreement_external_no
				,am.agreement_date
				,aas.asset_name
				,mvu.class_type_name
				,mvm.description
				,aas.asset_year
				,isnull(aas.replacement_fa_reff_no_02, aas.fa_reff_no_02)
				,isnull(aas.replacement_fa_reff_no_03, aas.fa_reff_no_03)
				,isnull(aas.replacement_fa_reff_no_01, aas.fa_reff_no_01)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no			 = wldd.letter_code)
				left join dbo.invoice_detail invd on (invd.agreement_no = wl.agreement_no)
				left join dbo.invoice inv on (inv.invoice_no = invd.invoice_no and inv.invoice_type='RENTAL')
				left join dbo.agreement_asset aas on (aas.agreement_no		 = wl.agreement_no)
				left join dbo.agreement_main am on (am.agreement_no			 = wl.agreement_no)
				left join dbo.agreement_asset_vehicle aav on (aav.asset_no	 = aas.asset_no)
				left join dbo.application_extention aext on (aext.application_no = am.application_no)
				left join dbo.master_vehicle_merk mvm on (mvm.code			 = aav.vehicle_merk_code)
				left join dbo.master_vehicle_unit mvu on (mvu.code			 = aav.vehicle_unit_code)
		where	wldd.letter_code = @p_letter_no;

		if not exists(SELECT * FROM dbo.RPT_SURAT_PERINGATAN_II_LAMPIRAN_I where user_id=@p_user_id)
		begin
				insert into dbo.rpt_surat_peringatan_ii_lampiran_i
		(
			user_id
			,nomor_surat
			,tanggal_surat_peringatan
			,main_contract_no
			,agreement_no
			,agreement_date
			,asset_name
			,vehicle_type
			,brand
			,year
			,chassis_no
			,engine_no
			,plat_no
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct
				@p_user_id
				,wldd.letter_code
				,wl.letter_date
				,null--aext.main_contract_no
				,null--am.agreement_external_no
				,null--am.agreement_date
				,null--aas.asset_name
				,null--mvu.class_type_name
				,null--mvm.description
				,null--aas.asset_year
				,null--isnull(aas.replacement_fa_reff_no_02, aas.fa_reff_no_02)
				,null--isnull(aas.replacement_fa_reff_no_03, aas.fa_reff_no_03)
				,null--isnull(aas.replacement_fa_reff_no_01, aas.fa_reff_no_01)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no			 = wldd.letter_code)
		where	wldd.letter_code = @p_letter_no;

		end;

		select	@count_unit = count(user_id)
		from	dbo.rpt_surat_peringatan_ii_lampiran_i
		where	user_id = @p_user_id ;

		update	dbo.rpt_surat_peringatan_ii
		set		jumlah_unit = @count_unit
		where	user_id = @p_user_id ;

		--update print count dan last print by untuk kebutuhan validasi
		update	dbo.warning_letter					
		set		last_print_by							= @p_user_id
				,print_count							= print_count +1
				--
				,mod_by									= @p_user_id
				,mod_date								= @p_mod_date
				,mod_ip_address							= @p_mod_ip_address
		where	letter_no								= @p_letter_no 

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
end


