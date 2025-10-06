CREATE PROCEDURE dbo.xsp_spaf_claim_paid
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@claim_amount		decimal(18,2)
			,@fa_code			nvarchar(50)
			,@claim_type		nvarchar(25)
			,@remark			nvarchar(4000)
			,@date				datetime = dbo.xfn_get_system_date()
			,@agreement_no		nvarchar(50)
			,@client_name		nvarchar(250)
			,@spaf_amount		decimal(18,2)
			,@subvention_amount	decimal(18,2)

	begin try
			declare cursor_name cursor fast_forward read_only for
			select	scd.claim_amount
					,sa.fa_code
					,sc.claim_type
					,ass.agreement_no
					,ass.client_name
					,sa.SUBVENTION_AMOUNT
					,sa.SPAF_AMOUNT
			from dbo.spaf_claim sc
			left join dbo.spaf_claim_detail scd on (scd.spaf_claim_code = sc.code)
			left join dbo.spaf_asset sa on (sa.code = scd.spaf_asset_code)
			left join dbo.asset ass on (ass.code = sa.fa_code)
			where sc.code = @p_code
			
			open cursor_name
			
			fetch next from cursor_name 
			into @claim_amount
				,@fa_code
				,@claim_type
				,@agreement_no
				,@client_name
				,@subvention_amount
				,@spaf_amount
			
			while @@fetch_status = 0
			begin
			
				set @remark = 'Income from ' + @claim_type + ', ' + format(@claim_amount, '#,###.00', 'DE-de')
				exec dbo.xsp_asset_income_ledger_insert @p_id					= 0
														,@p_asset_code			= @fa_code
														,@p_date				= @date
														,@p_reff_code			= @p_code
														,@p_reff_name			= 'SPAF / SUBVENTION'
														,@p_reff_remark			= @remark
														,@p_income_amount		= @claim_amount
														,@p_agreement_no		= @agreement_no
														,@p_client_name			= @client_name
														,@p_cre_date			= @p_mod_date	  
														,@p_cre_by				= @p_mod_by		  
														,@p_cre_ip_address		= @p_mod_ip_address
														,@p_mod_date			= @p_mod_date	  
														,@p_mod_by				= @p_mod_by		  
														,@p_mod_ip_address		= @p_mod_ip_address

				--Update Asset
				update	dbo.asset
				set		spaf_amount				= @spaf_amount
						,subvention_amount		= @subvention_amount
						,claim_spaf				= @p_code
						,claim_spaf_date		= @date
						,mod_by					= @p_mod_by
						,mod_date				= @p_mod_date
						,mod_ip_address			= @p_mod_ip_address
				where	code = @p_code ;
				
			    fetch next from cursor_name 
				into @claim_amount
					,@fa_code
					,@claim_type
					,@agreement_no
					,@client_name
					,@subvention_amount
					,@spaf_amount
			end
		close cursor_name
		deallocate cursor_name

		update	dbo.spaf_claim
		set		status			= 'PAID'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

end
