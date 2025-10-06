CREATE PROCEDURE [dbo].[xsp_rpt_surat_peringatan]
(
	@p_user_id		   NVARCHAR(50)
	,@p_letter_no	   NVARCHAR(50)
	--
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_date	   DATETIME
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_date	   DATETIME
	,@p_mod_ip_address NVARCHAR(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_comany_name	nvarchar(250)
			,@report_company_city	nvarchar(250)
			,@bank_name				nvarchar(50)
			,@bank_account_name		nvarchar(250)
			,@bank_account_no		nvarchar(50)
			,@penasihat_hukum		nvarchar(250)
			,@branch_code_dept		nvarchar(50)
			,@nama					nvarchar(50)
			,@jabatan				nvarchar(250)
			,@count_unit			int
			,@sp					int	-- (+) Ari 2023-12-28 ket : get from master

	begin try

		delete	dbo.rpt_surat_peringatan
		where	user_id = @p_user_id ;

		delete	dbo.rpt_surat_peringatan_lampiran
		where	user_id = @p_user_id ;

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

		select	@branch_code_dept = wld.branch_code
		from	dbo.warning_letter_delivery wld
		inner join dbo.warning_letter wl on wl.delivery_code = wld.code
		where	wld.code = @p_letter_no ;

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

		INSERT INTO dbo.RPT_SURAT_PERINGATAN
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
		    ,total_objek_sewa
		    ,total_kontrak_sewa
		    ,tunggakan_pembayaran_uang_sewa
		    ,denda_keterlambatan_pembayaran_uang_sewa
		    ,total
		    ,tanggal_pelunasan
		    ,dept_head_opl
		    ,penasihat_hukum
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		    ,no_period
		    ,jabatan
		)
		select	distinct
			@p_user_id
			,@report_image
			,@report_title
			,@report_comany_name
			,@report_company_city
			,@bank_name
			,@bank_account_name
			,@bank_account_no
		    ,wl.LETTER_NO				
		    ,@p_mod_date				
		    ,wld.CLIENT_NAME			
		    ,wld.DELIVERY_ADDRESS		
		    ,''							
		    ,wld.total_asset			
		    ,wld.total_agreement		
		    ,wld.total_overdue_amount	
		    ,wld.total_monthly_rental_amount 
		    ,(wld.total_overdue_amount + wld.total_monthly_rental_amount) 
		    ,DATEADD(DAY, 7, @p_mod_date)
		    ,@nama 
		    ,@penasihat_hukum
			-- 
		    ,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		    ,''
		    ,@jabatan 
		FROM dbo.WARNING_LETTER_DELIVERY wld
		INNER JOIN dbo.WARNING_LETTER wl ON wl.DELIVERY_CODE = wld.CODE
		WHERE wld.CODE = @p_letter_no
		AND NOT EXISTS (
				SELECT 1
				FROM dbo.WARNING_LETTER wl2
				INNER JOIN dbo.WARNING_LETTER_DELIVERY wld2 ON wld2.CODE = wl2.DELIVERY_CODE
				WHERE wld2.CLIENT_NO = wld.CLIENT_NO
				  AND (
					  (wl.LETTER_TYPE = 'SP1' AND wl2.LETTER_TYPE IN ('SP2', 'SOMASI'))
					  OR
					  (wl.LETTER_TYPE = 'SP2' AND wl2.LETTER_TYPE = 'SOMASI')
				  )
		  )

		INSERT INTO dbo.RPT_SURAT_PERINGATAN_LAMPIRAN
		(
		    user_id
		    ,nomor_surat
		    ,tanggal_surat_peringatan
		    ,invoice_no
		    ,agreement_no
		    ,main_contract_no
		    ,asset_name
		    ,brand
		    ,year
		    ,periode_pemakaian
		    ,amount
		    ,due_date_invoice
		    ,denda_keterlambatan_pembayaran_sewa
		    ,status
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		select  
			@p_user_id
		    ,wl.LETTER_NO 
		    ,wld.letter_date
		    ,inv.invoice_external_no 
		    ,am.Agreement_no 
		    ,aex.main_contract_no 
		    ,agast.asset_name 
		    ,'' 
		    ,agast.asset_year 
		    ,convert(varchar(30), period.period_date, 103) + ' - ' + convert(varchar(30), period.period_due_date, 103)
		    ,sum(invd.billing_amount) + sum(invd.ppn_amount)
		    ,inv.invoice_due_date 
		    ,ISNULL(aob.ob_amount, 0) 
		    ,wld.letter_type
			--
		    ,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address 
		FROM dbo.WARNING_LETTER_DELIVERY wld
		INNER JOIN dbo.WARNING_LETTER wl ON wl.DELIVERY_CODE = wld.CODE
		INNER JOIN dbo.INVOICE inv ON inv.CLIENT_NO = wld.CLIENT_NO
		INNER JOIN dbo.INVOICE_DETAIL invd ON invd.INVOICE_NO = inv.INVOICE_NO
		INNER JOIN dbo.AGREEMENT_MAIN am ON am.AGREEMENT_NO = invd.AGREEMENT_NO
		INNER JOIN dbo.APPLICATION_EXTENTION aex ON aex.APPLICATION_NO = am.APPLICATION_NO
		INNER JOIN dbo.AGREEMENT_ASSET agast ON agast.ASSET_NO = invd.ASSET_NO AND agast.AGREEMENT_NO = am.AGREEMENT_NO
		OUTER APPLY (
			SELECT 
				CASE am.first_payment_type
					WHEN 'ARR' THEN period_date + 1
					ELSE period_date
				END AS period_date,
				period_due_date
			FROM dbo.xfn_due_date_period(invd.asset_no, CAST(invd.billing_no AS INT)) aa
			WHERE invd.billing_no = aa.billing_no
			  AND invd.asset_no = aa.asset_no
		) period
		OUTER APPLY (
			SELECT 
				ISNULL(aob.OBLIGATION_AMOUNT, 0) - ISNULL(aobp.PAYMENT_AMOUNT, 0) AS ob_amount
			FROM dbo.AGREEMENT_OBLIGATION aob
			OUTER APPLY (
				SELECT 
					SUM(ISNULL(aobp.PAYMENT_AMOUNT, 0)) AS PAYMENT_AMOUNT
				FROM dbo.AGREEMENT_OBLIGATION_PAYMENT aobp
				WHERE aobp.OBLIGATION_CODE = aob.CODE
			) aobp
			WHERE aob.INVOICE_NO = invd.INVOICE_NO
			  AND invd.ASSET_NO = aob.ASSET_NO
			  AND invd.BILLING_NO = aob.INSTALLMENT_NO
			  AND aob.OBLIGATION_TYPE = 'OVDP'
		) aob
		--OUTER APPLY (
		--	SELECT aob.OBLIGATION_AMOUNT - aobp.PAYMENT_AMOUNT AS ob_amount
		--	FROM dbo.AGREEMENT_OBLIGATION aob
		--	OUTER APPLY (
		--		SELECT SUM(aobp.PAYMENT_AMOUNT) AS PAYMENT_AMOUNT
		--		FROM dbo.AGREEMENT_OBLIGATION_PAYMENT aobp
		--		WHERE aobp.OBLIGATION_CODE = aob.CODE
		--	) aobp
		--	WHERE aob.INVOICE_NO = invd.INVOICE_NO
		--	  AND invd.ASSET_NO = aob.ASSET_NO
		--	  AND invd.BILLING_NO = aob.INSTALLMENT_NO
		--	  AND aob.OBLIGATION_TYPE = 'OVDP'
		--) aob
		WHERE wld.CODE = @p_letter_no
		GROUP BY 
			wl.LETTER_NO,
			am.AGREEMENT_NO,
			wld.LETTER_DATE,
			aex.MAIN_CONTRACT_NO, 
			am.AGREEMENT_EXTERNAL_NO, 
			agast.ASSET_NAME, 
			agast.ASSET_YEAR, 
			inv.INVOICE_EXTERNAL_NO, 
			period.period_date, 
			period.period_due_date,
			inv.INVOICE_DUE_DATE,
			aob.ob_amount,
			wld.LETTER_TYPE


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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
