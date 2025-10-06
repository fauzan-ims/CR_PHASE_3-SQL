CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_detail_update_faktur]
(
	@p_id						bigint
	,@p_faktur_no				nvarchar(50)	= ''
	,@p_faktur_date				datetime		= null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@total_amount		decimal(18, 2)
			,@total_amount_head decimal(18, 2)
			,@total_amount_dtl	decimal(18, 2)
			,@ppn				decimal(18, 2)
			,@pph				decimal(18, 2)
			,@shipping_fee		decimal(18, 2)
			,@discount			decimal(18, 2)
			,@discount_head		decimal(18, 2)
			,@info_detail		nvarchar(4000)
			,@id_detail			int
			,@invoice_code		nvarchar(50)
			,@info				nvarchar(max)
			,@faktur_no			nvarchar(1)
			,@value				int
			,@info_detail2		nvarchar(4000)

	begin try
		
		select	@ppn		= b.ppn
				,@id_detail = b.id
		from	dbo.ap_invoice_registration_detail_faktur	  a
				inner join dbo.ap_invoice_registration_detail b on a.invoice_registration_detail_id = b.id
		where	a.id = @p_id ;
		
		set @faktur_no = ISNUMERIC(@p_faktur_no)

		if (@faktur_no = '0')
		begin
			set @msg = N'Faktur no can only be filled with numbers.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if @ppn > 0
		begin
			if (@p_faktur_no = '')
			begin
				set	@msg = 'Please input faktur no.'
				raiserror(@msg, 16, -1) ;
			end
		end

		if (@p_faktur_no <> '')
		begin
			if  (len(@p_faktur_no) != 16)
			begin
				set	@msg = 'Faktur no must be 16 digits'
				raiserror(@msg, 16, -1) ;
			end
		end

		if (@p_faktur_no <> '')
		begin
			if (isnull(@p_faktur_date,'') = '')
			begin
				set	@msg = 'Please input faktur date.'
				raiserror(@msg, 16, -1) ;
			end
		end

		--if (month(@p_faktur_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = N'Faktur date must be in the same month as system date.' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		select	@value = value
		from	dbo.sys_global_param
		where	CODE = 'APFKTBCM' ;

		if(@p_faktur_date < dateadd(month, -@value, dbo.xfn_get_system_date()))
		begin
			if(@value <> 0)
			begin
				set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if(@value = 0)
			begin
				set @msg = N'Faktur date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if (@p_faktur_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Faktur date must be less or equal than system date.' ;

			raiserror(@msg, 16, -1) ;
		end

		update	dbo.ap_invoice_registration_detail_faktur
		set		faktur_no				= @p_faktur_no
				,faktur_date			= @p_faktur_date
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

	

		--select	@info_detail = stuff((
		--						 select distinct
		--								case isnull(b.PLAT_NO, '')
		--									when '' then ', ' + a.faktur_no
		--									else ',' + b.plat_no + ' - ' + b.engine_no + ' - ' + b.chassis_no + ' - ' + a.faktur_no
		--								end
		--						 from	dbo.ap_invoice_registration_detail_faktur		a
		--								left join dbo.purchase_order_detail_object_info b on a.purchase_order_detail_object_info_id = b.id
		--						 where	invoice_registration_detail_id = @id_detail
		--						 for xml path('')
		--					 ), 1, 1, ''
		--					) ;

		select	@info_detail = stuff((
								 select distinct
										case isnull(b.PLAT_NO, '')
											when '' then null
											else ',' + b.plat_no + ' - ' + b.engine_no + ' - ' + b.chassis_no + ' - ' + a.faktur_no
										end
								 from	dbo.ap_invoice_registration_detail_faktur		a
										left join dbo.purchase_order_detail_object_info b on a.purchase_order_detail_object_info_id = b.id
								 where	invoice_registration_detail_id = @id_detail
								 for xml path('')
							 ), 1, 1, ''
							) ;

		select	@info_detail2 = stuff((
								  select	distinct
											',' + avh.plat_no + ' - ' + avh.engine_no + ' - ' + avh.chassis_no + ' - ' + a.faktur_no
								  from		dbo.ap_invoice_registration_detail		 aird
											inner join dbo.ap_invoice_registration_detail_faktur a on a.invoice_registration_detail_id = aird.id
											inner join dbo.good_receipt_note_detail	 grnd on grnd.id							   = aird.grn_detail_id
											inner join dbo.good_receipt_note		 grn on (grn.code							   = grnd.good_receipt_note_code)
											inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
											inner join dbo.purchase_order_detail	 pod on (
																								pod.po_code						   = po.code
																								and pod.id						   = grnd.purchase_order_detail_id
																							)
											inner join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
											left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
											inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
											inner join dbo.procurement_request		 pr on (pr.code								   = prc.procurement_request_code)
											inner join dbo.procurement_request_item	 pri on (
																								pri.procurement_request_code	   = pr.code
																								and	 pri.item_code				   = grnd.item_code
																							)
											inner join ifinams.dbo.asset_vehicle	 avh on avh.asset_code						   = pri.fa_code
								  where		aird.id = @id_detail
								  for xml path('')
							  ), 1, 1, ''
							 ) ;

		update dbo.ap_invoice_registration_detail
		set		info_detail				= isnull(@info_detail, @info_detail2)
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where id = @id_detail

		select @invoice_code = invoice_register_code 
		from dbo.ap_invoice_registration_detail 
		where id = @id_detail

		select	@info = stuff((
						  select	',' + info_detail
						  from		dbo.ap_invoice_registration_detail
						  where		invoice_register_code = @invoice_code
						  for xml path('')
					  ), 1, 1, ''
					 ) ;

		update dbo.ap_invoice_registration
		set unit_info				= @info
			--
			,mod_date				= @p_mod_date
			,mod_by					= @p_mod_by
			,mod_ip_address			= @p_mod_ip_address
		where code = @invoice_code
		
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
