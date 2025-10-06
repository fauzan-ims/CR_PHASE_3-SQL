CREATE PROCEDURE xsp_mtn_invoice_due_date
(
	@p_agreement_no		nvarchar(50)
	,@p_invoice_no		nvarchar(50)
	 --
   ,@p_mtn_remark		nvarchar(4000)
   ,@p_mtn_cre_by		nvarchar(250)
)
as
begin
	begin try
		begin transaction ;

			declare @invoice_no					nvarchar(50) = replace(@p_invoice_no, '/', '.')
					,@msg						nvarchar(max)
					,@agreement_no				nvarchar(50) = replace(@p_agreement_no,'/','.')
					,@top_date					int
					,@asset_no					nvarchar(50)
					,@ovd_amount				decimal(18,2)
					,@mod_date					datetime = dbo.xfn_get_system_date()
					,@mod_by					nvarchar(15) = 'MAINTENANCE'
					,@mod_ip_address			nvarchar(15) = '127.0.0.1'

			if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
			begin
				set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists
			(
				select	1
				from	dbo.invoice
				where	invoice_no		   = @invoice_no
						and invoice_status = 'PAID'
			)
			begin
				set @msg = 'Status Invoice sudah PAID';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			select	@top_date = credit_term 
			from	dbo.agreement_main
			where	agreement_no = @agreement_no

			select	@asset_no = asset_no
			from	dbo.agreement_asset 
			where	agreement_no = @agreement_no

			select dbo.xfn_calculate_penalty_per_agreement(@agreement_no, @mod_date, @invoice_no, @asset_no) 'overdue_before'

			update	dbo.invoice
			set		invoice_due_date = dateadd(day,@top_date,invoice_date)
					,mod_date = @mod_date
					,mod_by = @p_mtn_cre_by
					,mod_ip_address = @mod_ip_address
			where	invoice_no = @invoice_no

			select @ovd_amount = dbo.xfn_calculate_penalty_per_agreement(@agreement_no, @mod_date, @invoice_no, @asset_no) -- calculate overdue kembali

			update	dbo.agreement_obligation
			set		obligation_amount = @ovd_amount
					,mod_date = @mod_date
					,mod_by = @p_mtn_cre_by
					,mod_ip_address = @mod_ip_address
			where	invoice_no = @invoice_no
			and		agreement_no = @agreement_no

			select dbo.xfn_calculate_penalty_per_agreement(@agreement_no, @mod_date, @invoice_no, @asset_no) 'overdue_after'


			INSERT INTO dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(
				'MTN INVOICE DUE DATE'
				,@p_mtn_remark
				,'INVOICE'
				,@invoice_no
				,@agreement_no -- REFF_2 - nvarchar(50)
				,null -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mtn_cre_by
			)
	
			if @@error = 0
			begin
				select 'SUCCESS'
				commit transaction ;
			end ;
			else
			begin
				select 'GAGAL PROCESS : ' + @msg
				rollback transaction ;
			end

		end try
		begin catch
			select 'GAGAL PROCESS : ' + @msg
			rollback transaction ;
		end catch ;    
end
