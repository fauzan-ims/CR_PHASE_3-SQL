CREATE PROCEDURE dbo.xsp_get_spaf_claim_for_external
(
	@p_receipt_no					nvarchar(50)
	,@p_claim_status				nvarchar(20)
	,@p_spaf_pct					decimal(9,6)
	,@p_claim_amount				decimal(18,2)
	,@p_ppn							decimal(18,2)
	,@p_pph							decimal(18,2)
	,@p_claim_type					nvarchar(50)
	,@p_remark						nvarchar(4000)	= ''
	,@p_claim_req_no				nvarchar(50)	= ''
	,@p_faktur_no					nvarchar(50)	= null
	,@p_faktur_date					datetime		= null
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@date					datetime = getdate()
			,@total					decimal(18,2)
			,@code_spaf_claim		nvarchar(50)
			,@code					nvarchar(50)
			,@count1				int
			,@count2				int
			,@ppn					decimal(18,2)
			,@pph					decimal(18,2)

	begin try
		

		set @total = @p_claim_amount + @p_ppn - @p_pph

		select	@count1 = count(code)
		from	dbo.spaf_asset
		where	spaf_receipt_no = @p_receipt_no ;

		select	@count2 = count(code)
		from	dbo.spaf_asset
		where	subvention_receipt_no = @p_receipt_no ;

		if(@count1 <> 0)
		begin
			set @ppn	= @p_ppn / @count1
			set @pph	= @p_pph / @count1
		end
		else
		begin
			set @ppn	= @p_ppn / @count2
			set @pph	= @p_pph / @count2
		end
		
		--if @p_claim_status = 'Confirmation'

		if exists (select 1 from dbo.spaf_claim scm where scm.receipt_no = @p_receipt_no and scm.status in ('PAID'))--('ON PROCESS', 'PAID'))
		begin
			set @msg = 'Claim for this Receipt No already proceed.';
			raiserror(@msg ,16,-1);	 
		end

		if not exists (select 1 from dbo.spaf_claim scm where scm.receipt_no = @p_receipt_no)
		begin
			--if exists (select 1 from dbo.spaf_claim scm where scm.receipt_no = @p_receipt_no)
			--begin
			--	set @msg = 'Claim for this Receipt No already exist.';
			--	raiserror(@msg ,16,-1);	 
			--end

			exec dbo.xsp_spaf_claim_insert @p_code					= @code_spaf_claim output
										   ,@p_date					= @date
										   ,@p_status				= @p_claim_status
										   ,@p_claim_amount			= @p_claim_amount
										   ,@p_ppn_amount			= @p_ppn
										   ,@p_pph_amount			= @p_pph
										   ,@p_total_claim_amount	= @total
										   ,@p_remark				= @p_remark
										   ,@p_claim_type			= @p_claim_type
										   ,@p_receipt_no			= @p_receipt_no
										   ,@p_reff_claim_req_no	= @p_claim_req_no
										   ,@p_faktur_no			= @p_faktur_no
										   ,@p_faktur_date			= @p_faktur_date
										   ,@p_cre_date				= @p_cre_date
										   ,@p_cre_by				= @p_cre_by
										   ,@p_cre_ip_address		= @p_cre_ip_address
										   ,@p_mod_date				= @p_mod_date
										   ,@p_mod_by				= @p_mod_by
										   ,@p_mod_ip_address		= @p_mod_ip_address
			
			--jika type OPL SPAF
			if (@p_claim_type = 'OPL SPAF MMKSI' or @p_claim_type = 'OPL SPAF')
			begin
				insert into dbo.spaf_claim_detail
				(
					spaf_claim_code
					,spaf_pct
					,claim_amount
					,spaf_asset_code
					,ppn_amount_detail
					,pph_amount_detail
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select @code_spaf_claim
						,@p_spaf_pct
						,spaf_amount--@total
						,code
						,@ppn
						,@pph
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from dbo.spaf_asset
				where spaf_receipt_no = @p_receipt_no
				and validation_status = 'VALID'
			end
			else
			begin
				insert into dbo.spaf_claim_detail
				(
					spaf_claim_code
					,spaf_pct
					,claim_amount
					,spaf_asset_code
					,ppn_amount_detail
					,pph_amount_detail
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select @code_spaf_claim
						,0
						,subvention_amount--@total
						,code
						,@ppn
						,@pph
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from dbo.spaf_asset
				where subvention_receipt_no = @p_receipt_no
				and validation_status = 'VALID'
			end
		end
		else
		begin
			update dbo.spaf_claim
			set		status				= upper(@p_claim_status)
					,claim_amount		= @p_claim_amount
					,ppn_amount			= @p_ppn
					,pph_amount			= @p_pph
					,total_claim_amount = @p_claim_amount + @p_ppn - @p_pph
					,remark				= @p_remark
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	receipt_no			= @p_receipt_no


			select	@code = code 
			from dbo.spaf_claim
			where reff_claim_req_no = @p_claim_req_no

			-- jika statusnya complete
			--if @p_claim_status = 'Complete'
			--begin
			--	exec dbo.xsp_spaf_claim_post @p_code				= @code
			--								 ,@p_mod_date			= @p_mod_date
			--								 ,@p_mod_by				= @p_mod_by
			--								 ,@p_mod_ip_address		= @p_mod_ip_address
			--end
			if @p_claim_status = 'Reject'
			begin
				exec dbo.xsp_spaf_claim_cancel @p_code				= @code
											   ,@p_mod_date			= @p_mod_date
											   ,@p_mod_by			= @p_mod_by
											   ,@p_mod_ip_address	= @p_mod_ip_address
				
			end
		end

	
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
