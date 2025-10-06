CREATE PROCEDURE [dbo].[xsp_insurance_policy_main_update]
(
	@p_code					nvarchar(50)
	,@p_policy_no			nvarchar(50)
	,@p_cover_note_no		nvarchar(50)	= null
	,@p_cover_note_date		datetime		= null
	,@p_invoice_no			nvarchar(50)	= null
	,@p_invoice_date		datetime		= null
	,@p_faktur_no			nvarchar(50)	= null
    ,@p_faktur_date			datetime		= null
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
			,@loop							int = 0
			,@end_loop						int
			,@stamp_fee_before				decimal(18,2)
			,@sum_stamp_fee_detail			decimal(18,2)
			,@last_id_coverage				int
            ,@stamp_fee_detail				decimal(18,2)
			,@value1						int
			,@value2						int
			,@cre_by						nvarchar(50)

	begin try
		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'INSINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'INSFKT' ;


		select	@cre_by = cre_by
		from	dbo.insurance_policy_main
		where	code = @p_code ;

		if(@cre_by not like '%MIG%')
		begin
			if(@p_invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
			begin
				if(@value1 <> 0)
				begin
					set @msg = N'Invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + ' months.' ;

					raiserror(@msg, 16, -1) ;
				end
				else if (@value1 = 0)
				begin
					set @msg = N'Faktur date must be equal than system date.' ;

					raiserror(@msg, 16, -1) ;
				end
			end

			if(@p_faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
			begin
				if(@value2 <> 0)
				begin
					set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value2) + ' months.' ;

					raiserror(@msg, 16, -1) ;
				end
				else if (@value2 = 0)
				begin
					set @msg = N'Faktur date must be equal than system date.' ;

					raiserror(@msg, 16, -1) ;
				end
			end
		end
		

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

		--if(month(@p_invoice_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = 'Invoice Date must be in the same month with system date.' ;

		--	raiserror(@msg, 16, -1) ;
		--end

		if(@p_faktur_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Faktur Date must be less or equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end

		--if(month(@p_faktur_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = 'Faktur Date must be in the same month with system date.' ;

		--	raiserror(@msg, 16, -1) ;
		--end

		IF  (len(@p_faktur_no) != 16)
		begin
			set	@msg = 'Faktur Number Must be 16 Digits.'
			raiserror(@msg, 16, -1) ;
		END

		select	@source_type		= source_type
				,@sppa_code			= sppa_code
				,@stamp_fee_before	= stamp_fee_amount
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
	
		--Sepria (15juli2024): update hanya jika Stamp Fee nya di update
		if (@stamp_fee_before <> @p_stamp_fee_amount)
		begin
		    select	@end_loop = count(1)
			from	dbo.insurance_policy_asset ipa 
					inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code
			where	ipa.policy_code = @p_code

			set @stamp_fee_detail = @p_stamp_fee_amount / convert(decimal(18,2), @end_loop)

			update	dbo.insurance_policy_asset_coverage
			set		initial_stamp_fee_amount = round(@stamp_fee_detail,0)
					,mod_by					 = @p_mod_by
					,mod_date				 = @p_mod_date
					,mod_ip_address			 = @p_mod_ip_address
			from	dbo.insurance_policy_asset_coverage ipac
					inner join dbo.insurance_policy_asset ipa on ipac.register_asset_code = ipa.code
			where	ipa.policy_code = @p_code

			select	@sum_stamp_fee_detail	= sum(ipac.initial_stamp_fee_amount)
			from	dbo.insurance_policy_asset_coverage ipac
					inner join dbo.insurance_policy_asset ipa on ipac.register_asset_code = ipa.code
			where	ipa.policy_code = @p_code

			if(@sum_stamp_fee_detail <> @p_stamp_fee_amount)
			begin
		
				select top 1 @last_id_coverage = ipac.id 
				from 	dbo.insurance_policy_asset_coverage ipac
						inner join dbo.insurance_policy_asset ipa on ipac.register_asset_code = ipa.code
				where	ipa.policy_code = @p_code 
				order by id desc
                         
				update	dbo.insurance_policy_asset_coverage
				set		initial_stamp_fee_amount = initial_stamp_fee_amount + (@p_stamp_fee_amount - @sum_stamp_fee_detail)
						,mod_by					 = @p_mod_by
						,mod_date				 = @p_mod_date
						,mod_ip_address			 = @p_mod_ip_address
				from	dbo.insurance_policy_asset_coverage ipac
						inner join dbo.insurance_policy_asset ipa on ipac.register_asset_code = ipa.code
				where	ipa.policy_code = @p_code
				and		ipac.id			= @last_id_coverage
			end
            
			update	dbo.insurance_policy_asset_coverage
			set		buy_amount				= isnull(ipac.initial_buy_amount, 0) - (isnull(initial_discount_amount, 0) + isnull(initial_discount_ppn, 0) - isnull(initial_discount_pph, 0)) + isnull(initial_admin_fee_amount, 0) + isnull(initial_stamp_fee_amount, 0) 
			from	dbo.insurance_policy_asset_coverage ipac
					inner join dbo.insurance_policy_asset ipa on ipac.register_asset_code = ipa.code
			where	ipa.policy_code = @p_code
            
			update dbo.insurance_policy_main
			set		total_net_premi_amount	= initial_buy - (discount_amount + ppn_amount - pph_amount) + admin_amount + stamp_amount --buy_amount
					,total_discount_amount	= discount_amount
					,total_premi_buy_amount	= initial_buy--initial_buy
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			from	dbo.insurance_policy_main ipm
					outer apply (	select	isnull(sum(ipac.buy_amount),0)						'buy_amount'	
											,isnull(sum(ipac.initial_discount_amount),0)		'discount_amount'
											,isnull(sum(ipac.initial_discount_ppn),0)			'ppn_amount'
											,isnull(sum(ipac.initial_discount_pph),0)			'pph_amount'
											,isnull(sum(ipac.initial_admin_fee_amount),0)		'admin_amount'
											,isnull(sum(ipac.initial_stamp_fee_amount),0)		'stamp_amount'
											,isnull(sum(ipac.initial_buy_amount),0)				'initial_buy'
									from	dbo.insurance_policy_asset_coverage ipac
											inner join dbo.insurance_policy_asset ipa on ipac.register_asset_code = ipa.code
									where	ipa.policy_code = ipm.code
								)ipac
			where code = @p_code
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

