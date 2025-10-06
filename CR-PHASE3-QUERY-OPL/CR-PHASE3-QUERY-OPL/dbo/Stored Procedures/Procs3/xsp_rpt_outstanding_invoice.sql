--Created by, Rian at 21/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_outstanding_invoice
(
	@p_user_id		   nvarchar(50)
	,@p_branch_code	   nvarchar(50) = 'all'
	--,@p_branch_name	   nvarchar(50)
	,@p_customer_code  nvarchar(50) = ''
	,@p_customer_name  nvarchar(50)
	,@p_as_of_date	   datetime
    ,@p_is_condition   nvarchar(1) --(+) Untuk Kondisi Excel Data Only
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin

	delete	dbo.rpt_outstanding_invoice
	where	user_id = @p_user_id ;

	declare @msg				  nvarchar(max)
			,@customer_name		  nvarchar(250)
			,@report_company	  nvarchar(250)
			,@report_image		  nvarchar(250)
			,@report_title		  nvarchar(250)
			,@nomor_agreement	  nvarchar(50)
			,@object_sewa		  nvarchar(250)
			,@plat_no			  nvarchar(15)
			,@nomor_invoice		  nvarchar(50)
			,@preiode_sewa		  nvarchar(50)
			,@periode_berjalan	  nvarchar(50)
			,@nominam_invoice	  decimal(18, 2)
			,@tanggal_jatuh_tempo datetime
			,@branch_name		  nvarchar(250) 
			,@tanggal_invoice	  datetime
            ,@client_name		  nvarchar(250)
			,@payment_amount	  decimal(18,2)
			,@outstanding_amount  decimal(18,2)


	begin try
		
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set @report_title = N'Report Outstanding Invoice' ;

		declare cursor_name cursor fast_forward read_only for

		select	 am.client_name
				,am.agreement_external_no
				,ags.asset_name
				,ags.fa_reff_no_01
				,inv.invoice_external_no
				,am.periode
				,cast(agi.current_installment_no as nvarchar) + ' / ' + cast(am.periode as nvarchar)
				,isnull(agiv.ar_amount,0)--isnull(invd.total_amount, 0)
				,inv.invoice_due_date
				,inv.invoice_date
				,isnull(oapaip.payment_amount,0)--isnull(((total_billing_amount + total_ppn_amount) - total_discount_amount),0) - isnull(aip.payment_amount, 0)
		from	dbo.agreement_main am
				left join dbo.agreement_asset ags on (ags.agreement_no = am.agreement_no)
				left join dbo.agreement_information agi on (agi.agreement_no = am.agreement_no)
				inner join dbo.agreement_invoice agiv on (agiv.asset_no = ags.asset_no)
				left join dbo.invoice inv on (inv.invoice_no = agiv.invoice_no)
				outer apply (
								select	sum(isnull(aip.payment_amount,0)) 'payment_amount'
								from	dbo.agreement_invoice_payment aip
								where	aip.agreement_no = am.agreement_no and aip.invoice_no = agiv.INVOICE_NO
							)
							oapaip
		where	(am.client_no = @p_customer_code OR @p_customer_code = '')	
		and		inv.invoice_status					= 'POST'
		and		cast(inv.invoice_due_date as date) <= @p_as_of_date
		and		(am.branch_code	= @p_branch_code OR @p_branch_code = 'all')

		open cursor_name ;

		fetch next from cursor_name
		into @customer_name
			 ,@nomor_agreement
			 ,@object_sewa
			 ,@plat_no
			 ,@nomor_invoice
			 ,@preiode_sewa
			 ,@periode_berjalan
			 ,@nominam_invoice
			 ,@tanggal_jatuh_tempo
			 ,@tanggal_invoice
			 ,@payment_amount

		while @@fetch_status = 0
		begin

			set	@outstanding_amount = @nominam_invoice - @payment_amount

			insert into dbo.rpt_outstanding_invoice
			(
				user_id
				,branch_code
				,customer_code
				,customer_name
				,as_of_date
				,report_company
				,report_image
				,report_title
				,nomor_agreement
				,client_name
				,object_sewa
				,plat_no
				,nomor_invoice
				,invoice_date
				,periode_sewa
				,periode_berjalan
				,nominam_invoice
				,tanggal_jatuh_tempo
				,branch_name
				,payment_amount
				,outstanding_amount
				,is_condition
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(
				@p_user_id
				,@p_branch_code
				,@p_customer_code
				,@p_customer_name
				,@p_as_of_date
				,@report_company
				,@report_image
				,@report_title
				,@nomor_agreement
				,@customer_name
				,@object_sewa
				,@plat_no
				,@nomor_invoice
				,@tanggal_invoice
				,@preiode_sewa
				,@periode_berjalan
				,@nominam_invoice
				,@tanggal_jatuh_tempo
				,@branch_name
				,@payment_amount
				,@outstanding_amount
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			fetch next from cursor_name
			into @customer_name
				 ,@nomor_agreement
				 ,@object_sewa
				 ,@plat_no
				 ,@nomor_invoice
				 ,@preiode_sewa
				 ,@periode_berjalan
				 ,@nominam_invoice
				 ,@tanggal_jatuh_tempo
				 ,@tanggal_invoice
				 ,@payment_amount
		end ;

		close cursor_name ;
		deallocate cursor_name ;

		if not exists
		(
			select	*
			from	rpt_outstanding_invoice
			where	user_id = @p_user_id
		)
		begin
			insert into dbo.rpt_outstanding_invoice
			(
				user_id
				,branch_code
				,customer_code
				,customer_name
				,as_of_date
				,report_company
				,report_image
				,report_title
				,nomor_agreement
				,client_name
				,object_sewa
				,plat_no
				,nomor_invoice
				,invoice_date
				,periode_sewa
				,periode_berjalan
				,nominam_invoice
				,tanggal_jatuh_tempo
				,branch_name
				,tanggal_invoice
				,is_condition
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(
				@p_user_id
				,@p_branch_code
				,@p_customer_code
				,@p_customer_name
				,@p_as_of_date
				,@report_company
				,@report_image
				,@report_title
				,''
				,''
				,''
				,''
				,''
				,null
				,''
				,''
				,null
				,''
				,@branch_name
				,@tanggal_invoice
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
