CREATE PROCEDURE dbo.xsp_rpt_surat_peringatan_kedua
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
			,@total			 decimal(18,2)
			,@terbilang		 nvarchar(100)
			,@tunggakan		 datetime;
			

	delete dbo.rpt_surat_peringatan_kedua
	where	user_id = @p_user_id ;

	begin try

		set @report_title = 'SURAT PERINGATAN KEDUA'

		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGRPT' ;

		select  top 1 @tunggakan = DUE_DATE
		from	dbo.AGREEMENT_INVOICE ai
		where	ai.BILLING_NO = 1

		select 	@total = wl.overdue_installment_amount + wl.overdue_penalty_amount + wl.INSTALLMENT_AMOUNT
		from	dbo.WARNING_LETTER wl
		
		set @terbilang = dbo.Terbilang(@total)

		insert into dbo.rpt_surat_peringatan_kedua
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
			,nomor_sp1
			,tanggal_sp1
			,currency
			,amount
			,overdue_penalty
			,total
			,terbilang_jumlah
			,jatuh_tempo
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
				,ca.address + ', '+ ca.CITY_NAME + ', '+ ca.PROVINCE_NAME + ', '+ ca.ZIP_CODE
				,ca.area_phone_no + ca.phone_no
				,ca.area_phone_no + ca.PHONE_NO
				,wl.agreement_no
				,isnull(wlsp1.letter_no,'-')
				,wlsp1.letter_date
				,am.currency_code
				,isnull(wl.installment_amount,0)
				,isnull(wl.overdue_penalty_amount,0)
				,@total
				,@terbilang
				,@tunggakan
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
				left join dbo.warning_letter wlsp1 on (wlsp1.agreement_no = wl.agreement_no and wlsp1.letter_type = 'SP1')
		where	wl.letter_no = @p_letter_no
		and		ca.is_mailing = '1'

		update	dbo.warning_letter					
		set		last_print_by							= @p_user_id
				,print_count							= print_count +1
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
