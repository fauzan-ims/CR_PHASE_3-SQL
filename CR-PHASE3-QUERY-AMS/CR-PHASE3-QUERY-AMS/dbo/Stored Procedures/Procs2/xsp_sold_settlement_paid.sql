CREATE procedure [dbo].[xsp_sold_settlement_paid]
(
	@p_code			   nvarchar(50)
	,@p_process_date   datetime
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@asset_code	 nvarchar(50)
			,@process_status nvarchar(10)
			,@sale_amount	 decimal(18, 2)
			,@reff_remark	 nvarchar(4000)
			,@item_name		 nvarchar(250)
			,@agreement_no	 nvarchar(50)
			,@client_name	 nvarchar(250)
			,@fee_amount	 decimal(18, 2)
			,@id			 bigint
			,@sale_code		 nvarchar(50)
			,@sale_type		 nvarchar(50)

	begin try
		select	@asset_code		 = dt.asset_code
				,@item_name		 = ast.item_name
				,@sale_amount	 = dt.sold_amount
				,@process_status = ast.process_status
				,@agreement_no	 = ast.agreement_no
				,@client_name	 = ast.client_name
				,@fee_amount	 = dt.total_fee_amount
				,@id			 = dt.id
				,@sale_code		 = dt.sale_code
				,@sale_type		 = sl.sell_type
		from	dbo.sale_detail		 dt
				inner join dbo.asset ast on dt.asset_code = ast.code
				inner join dbo.sale sl on sl.code = dt.sale_code
		where	dt.asset_code = @p_code  --dt.sale_code = @p_code
				and isnull(dt.is_sold,'') = '1';	--(+)raffy 2025/05/13 agar data yang terambil, merupakan data asset yang benar2 terjual

		update	dbo.sale_detail
		set		sale_detail_status	= 'PAID'
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id = @id ;	--sale_code = @p_code

		update	dbo.asset
		set		status				= 'SOLD'
				,process_status		= @process_status
				,fisical_status		= 'SOLD'
				,rental_status		= ''
				,sale_date			= @p_process_date
				,sale_amount		= @sale_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @asset_code ;

		-- Hari - 08.Jul.2023 12:03 PM --	tambahkan proses untuk update claim jadi paid, jika penjualan dari claim
		if exists
		(
			select	1
			from	dbo.claim_main						  cm
					inner join dbo.claim_detail_asset	  cda on cda.claim_code		   = cm.code
																 and   cm.claim_status = 'APPROVE'
					inner join dbo.insurance_policy_asset ipa on cda.policy_asset_code = cda.policy_asset_code
			where	ipa.fa_code = @asset_code
		)
		begin
			declare @claim_code nvarchar(50) ;

			select	@claim_code = cm.code
			from	dbo.claim_main						  cm
					inner join dbo.claim_detail_asset	  cda on cda.claim_code		   = cm.code
																 and   cm.claim_status = 'APPROVE'
					inner join dbo.insurance_policy_asset ipa on cda.policy_asset_code = cda.policy_asset_code
			where	ipa.fa_code = @asset_code ;

			--update	dbo.claim_main
			--set		claim_status = 'PAID'
			--		,claim_progress_status = 'CLAIM PAID'
			--		,received_voucher_date = @p_mod_date
			--where	code = @claim_code ;

			exec dbo.xsp_claim_main_paid @p_code				= @claim_code
										 ,@p_cre_date			= @p_mod_date
										 ,@p_cre_by				= @p_mod_by
										 ,@p_cre_ip_address		= @p_mod_ip_address
										 ,@p_mod_date			= @p_mod_date
										 ,@p_mod_by				= @p_mod_by
										 ,@p_mod_ip_address		= @p_mod_ip_address
		end ;

		set @reff_remark = N'Sale Fee for ' + @asset_code + N' - ' + @item_name + N'. Amount : ' + format(@fee_amount, '#,###.00', 'DE-de') ;

		exec dbo.xsp_asset_expense_ledger_insert @p_id					= 0
												 ,@p_asset_code			= @asset_code
												 ,@p_date				= @p_mod_date
												 ,@p_reff_code			= @sale_code
												 ,@p_reff_name			= 'SALE FEE'
												 ,@p_reff_remark		= @reff_remark
												 ,@p_expense_amount		= @fee_amount
												 ,@p_agreement_no		= @agreement_no
												 ,@p_client_name		= @client_name
												 ,@p_cre_date			= @p_mod_date
												 ,@p_cre_by				= @p_mod_by
												 ,@p_cre_ip_address		= @p_mod_ip_address
												 ,@p_mod_date			= @p_mod_date
												 ,@p_mod_by				= @p_mod_by
												 ,@p_mod_ip_address		= @p_mod_ip_address ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_sold_settlement_paid] TO [ims-raffyanda]
    AS [dbo];

