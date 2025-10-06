CREATE PROCEDURE dbo.xsp_rpt_surat_peringatan_pertama
(
	@p_user_id			nvarchar(50)
	,@p_letter_no		nvarchar(50)
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
	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250) 
			,@report_image	 nvarchar(250)
			,@address		 nvarchar(250)
			,@tunggakan		 datetime
			,@agreement_no	 nvarchar(50)
			,@billing_no	 int
			,@total_amount	decimal(18, 2)
			

	delete dbo.rpt_surat_peringatan_pertama
	where	user_id = @p_user_id ;

	begin try

		set @report_title = 'SURAT PERINGATAN PERTAMA'

		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGRPT' ;

		--select  top 1 @tunggakan = DUE_DATE
		--from	dbo.AGREEMENT_INVOICE ai
		--where	ai.BILLING_NO = 1

		--ambil agreement no
		select	@agreement_no = agreement_no
		from	dbo.warning_letter
		where	letter_no = @p_letter_no

		--select data max due date dan sum total tagihan
		select	@tunggakan = max(ai.due_date)
				,@total_amount = sum(ai.ar_amount)
		from	dbo.agreement_invoice ai
				outer apply
		(
			select	payment_date
			from	dbo.agreement_invoice_payment aip
			where	aip.agreement_no   = ai.agreement_no
					and aip.invoice_no = ai.invoice_no
					and aip.asset_no   = ai.asset_no
		) aip
		where	ai.due_date			< dbo.xfn_get_system_date()
				and aip.payment_date is null
				and ai.agreement_no = @agreement_no ;

		insert into dbo.RPT_SURAT_PERINGATAN_PERTAMA
		(
			user_id
			,report_company
			,report_title
			,report_image
			,city
			,letter_date
			,letter_no
			,client_name
			,address
			,phone_no
			,fax
			,agreement_no
			,angsuran_ke
			,currency
			,amount
			,jatuh_tempo
			,persen
			,tunggakan
			,nama_acof
			,jabatan_acof
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,ca.city_name
				,wl.letter_date
				,wl.letter_no
				,am.client_name
				,ca.address  +', '+ ca.city_name + ', '+ ca.province_name + ', '+ ca.zip_code
				,ca.area_phone_no + ca.phone_no
				,ca.area_phone_no + ca.phone_no
				,wl.agreement_no
				,(select stuff 
				 ((
					select	',' + cast(ai.billing_no as nvarchar(2)) 
					from	dbo.agreement_invoice ai
							outer apply
					(
						select	payment_date
						from	dbo.agreement_invoice_payment aip
						where	aip.agreement_no   = ai.agreement_no
								and aip.invoice_no = ai.invoice_no
								and aip.asset_no   = ai.asset_no
					) aip
					where	ai.due_date			< dbo.xfn_get_system_date()
							and aip.payment_date is null
							and ai.agreement_no = wl.AGREEMENT_NO 
					for xml path(''), type
					).value('.', 'nvarchar(max)'), 1, 1, ''
				 ))
				,am.currency_code
				,isnull(@total_amount,0)
				,@tunggakan
				,ac.charges_rate 
				,isnull(wl.overdue_installment_amount,0) + isnull(wl.overdue_penalty_amount,0) + isnull(@total_amount,0)
				,''
				,''
				--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address	
		from	dbo.warning_letter wl
				inner join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
				inner join dbo.application_main apm on (apm.application_no = am.application_no)
				inner join dbo.client_main cm on (cm.code = apm.client_code)
				inner join dbo.client_address ca on (ca.client_code = cm.code)
				inner join dbo.AGREEMENT_CHARGES ac on (ac.AGREEMENT_NO = am.AGREEMENT_NO)
		where	wl.letter_no = @p_letter_no
		and		ca.is_mailing = '1'
		and		ac.charges_code = 'OVDP'
		
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
end ;
