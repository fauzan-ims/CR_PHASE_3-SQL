--Created by, Rian at 23/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_somasi
(
	@p_code		nvarchar(50)
	,@p_user_id	nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
AS
BEGIN
	declare	@msg						nvarchar(max)
			,@report_company_name		nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_company_city		nvarchar(4000)
			,@letter_no					nvarchar(50)
			,@client_name				nvarchar(250)
			,@client_address			nvarchar(4000)
			,@total_object_sewa			int
			,@tunggakan					decimal(18,2)
			,@denda						decimal(18,2)
			,@bank_name					nvarchar(250)
			,@bank_account_name			nvarchar(250)
			,@bank_account_no			nvarchar(50)
			,@petugas					nvarchar(250)
			,@nomor_perjanjian			nvarchar(50)
			,@tanggal_perjajian			datetime
			,@tipe_kendaraan			nvarchar(250)
			,@tahun_kendaraan			nvarchar(4)
			,@nomor_rangka				nvarchar(50)
			,@nomor_mesin				nvarchar(50)
			,@nomor_polisi				nvarchar(50)
			,@nominal_sewa				decimal(18,2)
			,@periode_sewa				nvarchar(250)
			,@nomor_invoice				nvarchar(50)
			,@nominal_invoice			decimal(18,2)
			,@tanggal_jatuh_tempo		datetime
			,@total_hari_keterlambatan	int
			,@denda_sewa				decimal(18,2)
			,@agreement_no				nvarchar(50)
			,@branch_code				nvarchar(50)
			,@nama_bank					nvarchar(250)
			,@rek_atas_nama				nvarchar(250)
			,@no_rek					nvarchar(50)
			,@add_days					int
			,@depthead					nvarchar(250) ; 

	begin try

		delete dbo.rpt_somasi
		where	user_id = @p_user_id;

		delete dbo.rpt_somasi_lampiran_i
		where	user_id = @p_user_id;

		delete dbo.rpt_somasi_lampiran_ii
		where	user_id = @p_user_id;

		delete dbo.rpt_somasi_lampiran_iii
		where	user_id = @p_user_id;

		select	@report_company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@branch_code = branch_code
		from	dbo.agreement_main
		where	agreement_no = @agreement_no ;

		select	@nama_bank = value
		from	dbo.sys_global_param
		where	code = 'BANK' ;

		select	@rek_atas_nama = value
		from	dbo.sys_global_param
		where	code = 'BANKNAME' ;

		select	@no_rek = value
		from	dbo.sys_global_param
		where	code = 'BANKNO' ;

		select	@add_days = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'DKPAS' ;

		select	@report_company_city = scy.description
		from	ifinsys.dbo.sys_branch sbh
				inner join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	sbh.code = @branch_code ;

		set	@report_title = 'Somasi Penyelesaian Kewajiban Kendaraan';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@agreement_no = agreement_no
		from	dbo.write_off_main 
		where	code = @p_code ;

		insert into dbo.rpt_somasi
		(
			user_id
			,report_company_name
			,report_image
			,report_title
			,report_company_city
			,letter_no
			,client_name
			,client_address
			,total_object_sewa
			,tunggakan
			,denda
			,bank_name
			,bank_account_name
			,bank_account_no
			,petugas
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company_name
				,@report_image
				,@report_title
				,@report_company_city
				,@p_code
				,am.client_name
				,ca.address
				,0
				,0
				,0
				,@nama_bank
				,@no_rek
				,@rek_atas_nama
				,@depthead
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main							 am
				left join dbo.client_main					 cm on cm.client_no = am.client_no
				left join dbo.agreement_information			 ai on ai.agreement_no = am.agreement_no
				left join dbo.client_address				 ca on ca.client_code = cm.code and ca.is_mailing='1'
				left join dbo.agreement_asset				 aa on aa.agreement_no = am.agreement_no
				left join dbo.client_corporate_info			 cci on (cci.client_code = am.client_no)
		where	am.agreement_no = @agreement_no ;

		insert into dbo.rpt_somasi_lampiran_i
		(
			user_id
			,letter_no
			,nomor_perjanjian
			,tanggal_perjajian
			,tipe_kendaraan
			,tahun_kendaraan
			,nomor_rangka
			,nomor_mesin
			,nomor_polisi
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@p_code
				,isnull(ama.agreement_external_no,'-')
				,ama.agreement_date
				,isnull(mht.description,'-')
				,aast.asset_year
				,isnull(aast.fa_reff_no_02,'-')
				,isnull(aast.fa_reff_no_03,'-')
				,isnull(aast.fa_reff_no_01,'-')
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main ama
				left join dbo.agreement_asset aast on aast.agreement_no		  = ama.agreement_no
				left join dbo.agreement_asset_vehicle aav on aav.asset_no	  = aast.ASSET_NO				
				left join dbo.master_vehicle_type mht on mht.code			  = aav.vehicle_type_code
				left join dbo.master_vehicle_model mvm on mvm.code			  = aav.vehicle_model_code
				left join dbo.master_vehicle_merk mmr on mmr.code			  = aav.vehicle_merk_code
				left join dbo.application_extention aex on aex.application_no = ama.application_no
		where	ama.agreement_no = @agreement_no ;


		insert into dbo.rpt_somasi_lampiran_ii
		(
			user_id
			,letter_no
			,nomor_perjanjian
			,nominal_sewa
			,periode_sewa
			,nomor_invoice
			,nominal_invoice
			,tanggal_jatuh_tempo
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@p_code
				,ama.agreement_external_no
				,isnull(xasset.rental,0)
				,isnull(convert(varchar(30), tabdue.period_date, 103)+' - '+convert(varchar(30), tabdue.period_due_date, 103),'-')
				,isnull(inc.invoice_external_no,'-')
				,SUM(inc.total_billing_amount - inc.total_discount_amount + inc.total_ppn_amount)
				,inc.invoice_due_date
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from dbo.invoice_detail ide
		inner join dbo.invoice inc
			on inc.invoice_no = ide.invoice_no
		inner join dbo.agreement_main ama
			on ama.agreement_no = ide.agreement_no
		outer apply
			(
				select sum(lease_rounded_amount) rental
				from dbo.agreement_asset
				where agreement_no = ama.agreement_no
			) xasset
		outer apply
			(
				select period_date,
						period_due_date
				from dbo.xfn_due_date_period((ide.asset_no), (ide.billing_no))
			) tabdue
		where ide.agreement_no =  ama.agreement_no
			and inc.invoice_status = 'post'
		group by inc.invoice_external_no,
				ama.agreement_external_no,
				xasset.rental,
				inc.invoice_external_no,
				inc.invoice_due_date,
				isnull(
						convert(varchar(30), tabdue.period_date, 103) + ' - '
						+ convert(varchar(30), tabdue.period_due_date, 103),
						'-'
					);

				

		insert into dbo.rpt_somasi_lampiran_iii
		(
			user_id
			,letter_no
			,nomor_perjanjian
			,nominal_sewa
			,total_hari_keterlambatan
			,denda_sewa
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@p_code
				,isnull(ama.agreement_external_no,'-')
				,isnull(ide.billing_amount,0)
				,isnull(aob.obligation_day,0)
				,0.25*isnull(ide.billing_amount,0)*isnull(aob.obligation_day,0)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main ama
				left join dbo.invoice_detail ide on ide.agreement_no	   = ama.agreement_no
				left join dbo.invoice inc on inc.invoice_no				   = ide.invoice_no
				left join dbo.agreement_obligation aob on aob.agreement_no = ama.agreement_no
		where	ama.agreement_no = @agreement_no ;
		
		select	@tunggakan = sum(nominal_invoice)
		from	dbo.RPT_SOMASI_LAMPIRAN_II
		where	user_id = @p_user_id ;

		select	@denda = sum(denda_sewa)
		from	dbo.RPT_SOMASI_LAMPIRAN_III
		where	user_id = @p_user_id ;

		update	dbo.rpt_somasi
		set		tunggakan = @tunggakan
				,denda = @denda
		where	user_id = @p_user_id ;

		update	dbo.warning_letter					
		set		last_print_by							= @p_user_id
				,print_count							= print_count +1
				--
				,mod_by									= @p_user_id
				,mod_date								= @p_mod_date
				,mod_ip_address							= @p_mod_ip_address
		where	letter_no								= @p_code ;

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
