CREATE PROCEDURE [dbo].[xsp_cashier_transaction_generate_allocation]
(
	@p_code			   nvarchar(50)
	,@p_status		   nvarchar(50) = ''
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
	declare @msg					nvarchar(max)
			,@agreement_no			nvarchar(50)
			,@client_no				nvarchar(50)
			,@gl_link_code			nvarchar(50)
			,@cashier_trx_date		datetime
			,@cashier_currency_code nvarchar(3) ;

	begin try
		if exists
		(
			select	1
			from	dbo.cashier_transaction
			where	code			   = @p_code
					and cashier_status <> 'HOLD'
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;

			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			select	@cashier_currency_code = isnull(am.currency_code, ct.cashier_currency_code)
					--,@agreement_no = ct.agreement_no -- Louis Kamis, 26 Juni 2025 13.11.49 -- 
					,@client_no = ct.client_no -- Louis Kamis, 26 Juni 2025 13.12.38 -- 
					,@cashier_trx_date = ct.cashier_trx_date
			from	dbo.cashier_transaction ct
					left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
			where	code = @p_code ;

			--if (isnull(@agreement_no, '') <> '')-- Louis Senin, 30 Juni 2025 10.56.47 -- 
			if (isnull(@client_no, '') <> '')-- Louis Senin, 30 Juni 2025 10.56.47 -- 
			begin
				-- untuk yg ada agreeent
				if (
					   @p_status = 'REPO I'
					   or	@p_status = 'REPO II'
				   )
				begin
					-- untuk status Repo I dan Repo II
					select		mt.code
								,@cashier_currency_code 'currency_code'
								,mt.transaction_name
								,mt.module_name
					from		dbo.master_cashier_priority mcp
								inner join master_cashier_priority_detail mcd on (mcd.cashier_priority_code = mcp.code)
								inner join master_transaction mt on (mt.code								= mcd.transaction_code)
					where		mcp.is_default	   = '1'
								and mt.module_name = ''
					order by	order_no ;
				end ;
				else
				begin
					if exists
					(
						select	1
						from	dbo.cashier_transaction
						where	code					= @p_code
								and is_received_request = '1'
					)
					begin
						select	value 'code'
								,@cashier_currency_code 'currency_code'
								,jgl.gl_link_name 'transaction_name'
								,'' as 'module_name'
						from	dbo.sys_global_param sgp inner join dbo.journal_gl_link jgl on (jgl.code = sgp.value)
						where	sgp.code in
						(
							'TOLAMTGL', 'DPSINSTGL'
						) ;
					end ;
					else
					begin
						-- untuk status selain Repo I dan Repo II
						select		mt.code
									,@cashier_currency_code 'currency_code'
									,mt.transaction_name
									,mt.module_name
						from		dbo.master_cashier_priority mcp
									inner join master_cashier_priority_detail mcd on (mcd.cashier_priority_code = mcp.code)
									inner join master_transaction mt on (mt.code								= mcd.transaction_code)
						where		mcp.is_default = '1'
						order by	order_no ;
					end ;
				end ;
			end ;
			else
			begin
				-- jika tidak ada 
				select	mt.code
						,@cashier_currency_code 'currency_code'
						,mt.transaction_name
						,mt.module_name
				from	dbo.master_transaction mt
						inner join dbo.sys_global_param sgp on (sgp.value = mt.code)
				where	sgp.code = 'TRXSPND' ;
			end ;
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
			set @msg = 'V' + ';' + @msg ;
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
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
