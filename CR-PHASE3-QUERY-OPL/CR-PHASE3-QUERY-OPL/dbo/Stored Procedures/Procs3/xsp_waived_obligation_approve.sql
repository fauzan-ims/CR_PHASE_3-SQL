-- Louis Rabu, 11 Januari 2023 21.32.31 -- 
CREATE PROCEDURE dbo.xsp_waived_obligation_approve
(
	@p_code				nvarchar(50)
	,@p_approval_reff	nvarchar(250)  = ''
	,@p_approval_remark nvarchar(4000) = ''
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg				   nvarchar(max)
			,@agreement_no		   nvarchar(50)
			,@waived_date		   datetime
			,@waived_amount		   decimal(18, 2)
			,@installment_no	   int
			,@obligation_code	   nvarchar(50)
			,@asset_no			   nvarchar(50)
			,@invoice_no		   nvarchar(50) 
			-- (+) Ari 2023-10-10 ket : get sisa waived yg sudah terbayarkan
			,@sisa_waive_amount	   decimal(18,2) 
			,@sisa_pembayaran	   decimal(18,2)

	begin try
		if exists
		(
			select	1
			from	dbo.waived_obligation
			where	code			  = @p_code
					and waived_status <> 'ON PROCESS'
		)
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else
		begin
			select	@agreement_no = agreement_no
			from	dbo.waived_obligation
			where	code = @p_code ;

			-- (+) Ari 2023-10-10 ket : get sisa waived yg sudah terbayarkan
			select	@sisa_waive_amount = waived_amount
			from	waived_obligation_detail 
			where	waived_obligation_code = @p_code
			
			declare c_waive cursor local fast_forward read_only for
			select	wo.waived_date
					--,wod.waived_amount
					,wod.installment_no
					,ao.asset_no
					,wod.invoice_no
					,ao.code
			from	dbo.waived_obligation_detail wod
					inner join dbo.waived_obligation wo on (wo.code						  = wod.waived_obligation_code)
					inner join dbo.agreement_obligation ao on (
																  ao.agreement_no		  = wo.agreement_no
																  and  ao.obligation_type = wod.obligation_type
																  and  ao.invoice_no	  = wod.invoice_no
															  )
			where	waived_obligation_code = @p_code ;

			open c_waive ;

			fetch c_waive
			into @waived_date
				 --,@waived_amount
				 ,@installment_no
				 ,@asset_no
				 ,@invoice_no
				 ,@obligation_code ;

			while @@fetch_status = 0
			begin
				
				-- (+) Ari 2023-10-10 ket : get obligation amount per asset
				select	@waived_amount = obligation_amount 
				from	agreement_obligation
				where	asset_no = @asset_no
				and		installment_no = @installment_no

				select	@sisa_pembayaran = sum(payment_amount) 
				from	dbo.agreement_obligation_payment
				where	asset_no = @asset_no
				and		installment_no = @installment_no

				set @sisa_pembayaran = isnull(@waived_amount,0) - isnull(@sisa_pembayaran,0)

				if(@sisa_waive_amount >= @sisa_pembayaran and @sisa_pembayaran > 0) -- (+) Ari 2023-10-10 ket : tambah kondisi pengecekan obligasi perasset dengan obligasi yang dibayarkan
				begin 
					exec dbo.xsp_agreement_obligation_payment_insert @p_id						= 0
																	 ,@p_obligation_code		= @obligation_code
																	 ,@p_agreement_no			= @agreement_no
																	 ,@p_asset_no				= @asset_no
																	 ,@p_invoice_no				= @invoice_no
																	 ,@p_installment_no			= @installment_no
																	 ,@p_payment_date			= @waived_date
																	 ,@p_value_date				= @waived_date
																	 ,@p_payment_source_type	= N'WAIVED OBLIGATION'
																	 ,@p_payment_source_no		= @p_code
																	 ,@p_payment_amount			= @sisa_pembayaran --@waived_amount
																	 ,@p_is_waive				= N'1'
																	 --
																	 ,@p_cre_date				= @p_mod_date
																	 ,@p_cre_by					= @p_mod_by
																	 ,@p_cre_ip_address			= @p_mod_ip_address
																	 ,@p_mod_date				= @p_mod_date
																	 ,@p_mod_by					= @p_mod_by
																	 ,@p_mod_ip_address			= @p_mod_ip_address	

					exec dbo.xsp_opl_interface_agreement_update_out_insert @p_agreement_no		= @agreement_no
																		   ,@p_mod_date			= @p_mod_date
																		   ,@p_mod_by			= @p_mod_by
																		   ,@p_mod_ip_address	= @p_mod_ip_address 

					-- update lms status
					exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no	= @agreement_no
																  ,@p_status		= N''

					set @sisa_waive_amount = @sisa_waive_amount - @sisa_pembayaran -- (+) Ari 2023-10-10 ket : cek sisa waive amount yg sudah dibayarkan
				end
				else if(@sisa_waive_amount < @sisa_pembayaran and @sisa_waive_amount > 0) -- (+) Ari 2023-10-10 ket : jika sisa waive amount lebih kecil dari tunggakan obligasinya, masukkan semua sisanya
				begin
					exec dbo.xsp_agreement_obligation_payment_insert @p_id						= 0
																	 ,@p_obligation_code		= @obligation_code
																	 ,@p_agreement_no			= @agreement_no
																	 ,@p_asset_no				= @asset_no
																	 ,@p_invoice_no				= @invoice_no
																	 ,@p_installment_no			= @installment_no
																	 ,@p_payment_date			= @waived_date
																	 ,@p_value_date				= @waived_date
																	 ,@p_payment_source_type	= N'WAIVED OBLIGATION'
																	 ,@p_payment_source_no		= @p_code
																	 ,@p_payment_amount			= @sisa_waive_amount --@waived_amount
																	 ,@p_is_waive				= N'1'
																	 --
																	 ,@p_cre_date				= @p_mod_date
																	 ,@p_cre_by					= @p_mod_by
																	 ,@p_cre_ip_address			= @p_mod_ip_address
																	 ,@p_mod_date				= @p_mod_date
																	 ,@p_mod_by					= @p_mod_by
																	 ,@p_mod_ip_address			= @p_mod_ip_address	

					exec dbo.xsp_opl_interface_agreement_update_out_insert @p_agreement_no		= @agreement_no
																		   ,@p_mod_date			= @p_mod_date
																		   ,@p_mod_by			= @p_mod_by
																		   ,@p_mod_ip_address	= @p_mod_ip_address 

					-- update lms status
					exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no	= @agreement_no
																  ,@p_status		= N''

					set @sisa_waive_amount = @sisa_waive_amount - @sisa_pembayaran -- (+) Ari 2023-10-10 ket : cek sisa waive amount yg sudah dibayarkan
				end

				fetch c_waive
				into @waived_date
					 --,@waived_amount
					 ,@installment_no
					 ,@asset_no
					 ,@invoice_no
					 ,@obligation_code ;
			end ;

			close c_waive ;
			deallocate c_waive ;

			update	dbo.waived_obligation
			set		waived_status	= 'APPROVE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
		end ;
	end try
	begin catch
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
