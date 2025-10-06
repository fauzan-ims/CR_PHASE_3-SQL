CREATE PROCEDURE [dbo].[xsp_insurance_policy_main_update_old]
(
	@p_code					nvarchar(50)
	,@p_policy_no			nvarchar(50)
	,@p_cover_note_no		nvarchar(50)	= null
	,@p_cover_note_date		datetime		= null
	,@p_invoice_no			nvarchar(50)	= null
	,@p_invoice_date		datetime		= null
	,@p_faktur_no			nvarchar(50)	= NULL
    ,@p_faktur_date			DATETIME		= null
	,@p_stamp_fee_amount	decimal(18,2)	= 0
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@source_type					nvarchar(20)
			,@sppa_code						nvarchar(50)
			,@policy_asset_code				nvarchar(50)
			,@counter						int
			,@amount						decimal(18,2)
			,@id_coverage					int
			,@count_id						int
			,@coverage_stamp_amount			decimal(18,2)
			,@tot_stamp_detail				decimal(18,2)
			,@tot_stamp_header				decimal(18,2)
			,@selisih						decimal(18,2)
			,@initial_buy_amount			decimal(18,2)
			,@initial_discount_amount		decimal(18,2)
			,@initial_discount_ppn			decimal(18,2)
			,@initial_discount_pph			decimal(18,2)
			,@initial_stamp_fee_amount		decimal(18,2)
			,@initial_admin_fee_amount		decimal(18,2)
			,@buy_amount					decimal(18,2)

	begin try
		if (@p_cover_note_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Cover No Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_invoice_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Invoice Date must be less or equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if(month(@p_invoice_date) < month(dbo.xfn_get_system_date()))
		begin
			set @msg = 'Invoice Date must be in the same month with system date.' ;

			raiserror(@msg, 16, -1) ;
		end

		if(@p_faktur_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Faktur Date must be less or equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end

		if(month(@p_faktur_date) < month(dbo.xfn_get_system_date()))
		begin
			set @msg = 'Faktur Date must be in the same month with system date.' ;

			raiserror(@msg, 16, -1) ;
		end

		IF  (len(@p_faktur_no) != 16)
		begin
			set	@msg = 'Faktur Number Must be 16 Digits.'
			raiserror(@msg, 16, -1) ;
		END

		select	@source_type	= source_type
				,@sppa_code		= sppa_code
		from	dbo.insurance_policy_main
		where	code			= @p_code ;

		-- tambah validasi nomor policy tidak bisa sama. unttuk maskapai yang sama dan policy status nya aktif
		update	insurance_policy_main
		set		policy_no			= @p_policy_no
				,cover_note_no		= @p_cover_note_no
				,cover_note_date	= @p_cover_note_date
				,invoice_no			= @p_invoice_no
				,invoice_date		= @p_invoice_date
				,faktur_no			= @p_faktur_no
				,faktur_date		= @p_faktur_date
				,stamp_fee_amount	= @p_stamp_fee_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

		declare curr_update_coverage cursor fast_forward read_only for
		select ipac.id
				,stamp.stamp_amount
		from dbo.insurance_policy_asset ipa
		inner join dbo.insurance_policy_asset_coverage ipac on ipa.code = ipac.register_asset_code
		outer apply 
		(
			select cast(@p_stamp_fee_amount / count(ipac.id) as bigint) 'stamp_amount'
			from dbo.insurance_policy_main ipm
			inner join dbo.insurance_policy_asset ipa on ipa.policy_code = ipm.code
			inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code
			where ipm.code = @p_code
			group by ipm.stamp_fee_amount
		)stamp
		where ipa.policy_code = @p_code
		
		open curr_update_coverage
		
		fetch next from curr_update_coverage 
		into @id_coverage
			,@coverage_stamp_amount
		
		while @@fetch_status = 0
		begin
				--set @buy_amount =  @initial_buy_amount - (@initial_discount_amount + @initial_discount_ppn - @initial_discount_pph) + @coverage_stamp_amount + @initial_admin_fee_amount

		  --  	update dbo.insurance_policy_asset_coverage
				--set		initial_stamp_fee_amount = @coverage_stamp_amount
				--		--,buy_amount				 = @buy_amount --buy_amount + @coverage_stamp_amount
				--		--
				--		,mod_by					 = @p_mod_by
				--		,mod_date				 = @p_mod_date
				--		,mod_ip_address			 = @p_mod_ip_address
				--where id = @id_coverage

				select	@initial_buy_amount			= initial_buy_amount
						,@initial_discount_amount	= initial_discount_amount
						,@initial_discount_ppn		= initial_discount_ppn
						,@initial_discount_pph		= initial_discount_pph
						,@initial_admin_fee_amount  = initial_admin_fee_amount
				from	dbo.insurance_policy_asset_coverage
				where	id = @id_coverage ;

				exec dbo.xsp_insurance_policy_asset_coverage_update @p_id							= @id_coverage
																	,@p_initial_buy_amount			= @initial_buy_amount
																	,@p_initial_discount_amount		= @initial_discount_amount
																	,@p_initial_discount_ppn		= @initial_discount_ppn
																	,@p_initial_discount_pph		= @initial_discount_pph
																	,@p_initial_admin_fee_amount	= @initial_admin_fee_amount
																	,@p_initial_stamp_fee_amount	= @coverage_stamp_amount
																	,@p_mod_date					= @p_mod_date
																	,@p_mod_by						= @p_mod_by
																	,@p_mod_ip_address				= @p_mod_ip_address
				

		    fetch next from curr_update_coverage 
			into @id_coverage
				,@coverage_stamp_amount
		end
		
		close curr_update_coverage
		deallocate curr_update_coverage

		select @tot_stamp_detail = sum(ipac.initial_stamp_fee_amount)
		from dbo.insurance_policy_main ipm
		inner join dbo.insurance_policy_asset ipa on ipa.policy_code = ipm.code
		inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code
		where ipm.code = @p_code

		select @tot_stamp_header = stamp_fee_amount 
		from dbo.insurance_policy_main
		where code = @p_code

		set @selisih = @tot_stamp_header -  @tot_stamp_detail

		if @tot_stamp_detail <> @tot_stamp_header
		begin
			select top 1 
					@id_coverage = ipac.ID
					,@coverage_stamp_amount = ipac.initial_stamp_fee_amount
			from dbo.insurance_policy_main ipm
			inner join dbo.insurance_policy_asset ipa on ipa.policy_code = ipm.code
			inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code
			where ipm.code = @p_code

			--update dbo.insurance_policy_asset_coverage
			--set initial_stamp_fee_amount = @coverage_stamp_amount + @selisih
			--where id = @id_coverage

			select	@initial_buy_amount			= initial_buy_amount
					,@initial_discount_amount	= initial_discount_amount
					,@initial_discount_ppn		= initial_discount_ppn
					,@initial_discount_pph		= initial_discount_pph
					,@initial_admin_fee_amount  = initial_admin_fee_amount
			from	dbo.insurance_policy_asset_coverage
			where	id = @id_coverage ;

			set @initial_stamp_fee_amount = @coverage_stamp_amount + @selisih

			exec dbo.xsp_insurance_policy_asset_coverage_update @p_id							= @id_coverage
																,@p_initial_buy_amount			= @initial_buy_amount
																,@p_initial_discount_amount		= @initial_discount_amount
																,@p_initial_discount_ppn		= @initial_discount_ppn
																,@p_initial_discount_pph		= @initial_discount_pph
																,@p_initial_admin_fee_amount	= @initial_admin_fee_amount
																,@p_initial_stamp_fee_amount	= @initial_stamp_fee_amount
																,@p_mod_date					= @p_mod_date
																,@p_mod_by						= @p_mod_by
																,@p_mod_ip_address				= @p_mod_ip_address
		end
		
		declare curr_update_invoice cursor fast_forward read_only for
		select ipa.code 
		from dbo.insurance_policy_asset ipa
		inner join dbo.insurance_policy_asset_coverage ipac on (ipa.code = ipac.register_asset_code)
		where ipa.policy_code = @p_code
		and ipac.sppa_code = @sppa_code
		
		open curr_update_invoice
		
		fetch next from curr_update_invoice 
		into @policy_asset_code
		
		while @@fetch_status = 0
		begin
		    update dbo.insurance_policy_asset
			set		invoice_code		= @p_invoice_no
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @policy_asset_code		
		
		    fetch next from curr_update_invoice 
			into @policy_asset_code
		end
		
		close curr_update_invoice
		deallocate curr_update_invoice

		

		
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

