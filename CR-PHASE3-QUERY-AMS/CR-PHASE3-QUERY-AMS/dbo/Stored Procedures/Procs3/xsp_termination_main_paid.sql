/*
	alterd : Nidya Pratiwi, 15 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_termination_main_paid 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@deposit_amount		decimal(18, 2)
			,@deposit_date			datetime
			,@deposit_reff_no		nvarchar(250)
			,@deposit_remarks		nvarchar(4000)
			,@policy_code			nvarchar(50)
			,@termination_status	nvarchar(10)
			,@policy_status			nvarchar(10)
			,@policy_process_status	nvarchar(10)
			,@received_request_code	nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@plafond_no			nvarchar(50)
			,@currency				nvarchar(3)
			,@policy_no				nvarchar(50)
			,@remark				nvarchar(4000)
			,@reff_remark			nvarchar(4000)
			,@fa_code				nvarchar(50)
			,@item_name				nvarchar(250)
			,@refund_amount			decimal(18,2)
			,@client_name			nvarchar(250)
			
	begin TRY

		select	@branch_code			= tm.branch_code			
				,@branch_name			= tm.branch_name			
				,@deposit_amount		= termination_amount		
				,@deposit_date			= termination_date			
				,@deposit_remarks		= termination_remarks
				,@termination_status	= termination_status
				,@policy_code			= ipm.code
				,@policy_no				= ipm.policy_no 
				,@currency				= ipm.currency_code
		from	dbo.termination_main tm
				inner join dbo.insurance_policy_main ipm on (ipm.code = tm.policy_code)
		where	tm.code					= @p_code	

		select @policy_status = ipm.policy_status
			   ,@policy_process_status = ipm.policy_process_status
		from   dbo.insurance_policy_main ipm
		where  ipm.code = @policy_code
	 
		select @received_request_code = code
		from dbo.efam_interface_received_request
		where received_source_no = @p_code

		if exists (select 1 from dbo.termination_main where code = @p_code and termination_status = 'APPROVE')
		begin
			update	dbo.termination_main 
			set		termination_status	= 'PAID'
					,received_request_code = @received_request_code
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
			
			set @remark = 'Terminate for ' + isnull(@plafond_no,'') + isnull(@agreement_no,'') + ' Policy Insurance from Policy No : ' + @policy_no
			 
			update	dbo.insurance_policy_main
			set		policy_process_status = null
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code = @policy_code ;

			-- update status asset menjadi claim
			update	dbo.insurance_policy_asset
			set		status_asset = 'TERMINATE'
			where	code in
					(
						select	policy_asset_code
						from	dbo.termination_detail_asset
						where	termination_code = @p_code
					) ;


			exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0
															  ,@p_policy_code		= @policy_code
															  ,@p_history_date		= @deposit_date
															  ,@p_history_type		= 'TERMINATE PAID'
															  ,@p_policy_status		= @termination_status
															  ,@p_history_remarks	= @deposit_remarks
															  ,@p_cre_date			= @p_cre_date		
															  ,@p_cre_by			= @p_cre_by		
															  ,@p_cre_ip_address	= @p_cre_ip_address
															  ,@p_mod_date			= @p_mod_date		
															  ,@p_mod_by			= @p_mod_by		
															  ,@p_mod_ip_address	= @p_mod_ip_address

			
			declare cursor_name cursor fast_forward read_only for
			select	fa_code
					,ass.item_name
					,tda.refund_amount
					,ass.agreement_no
					,ass.client_name
			from	dbo.insurance_policy_asset ipa
			inner join dbo.asset ass on (ass.code = ipa.fa_code)
			inner join dbo.termination_detail_asset tda on (tda.policy_asset_code = ipa.code)
			where	ipa.code in
					(
						select	policy_asset_code
						from	dbo.termination_detail_asset
						where	termination_code = @p_code
					) ;
			
			open cursor_name
			
			fetch next from cursor_name 
			into @fa_code
				,@item_name
				,@refund_amount
				,@agreement_no
				,@client_name
			
			while @@fetch_status = 0
			begin
				set @reff_remark = 'Insurance refund for ' + @fa_code + ' - ' + @item_name + '. Amount : ' + format (@refund_amount, '#,###.00', 'DE-de')
			    exec dbo.xsp_asset_income_ledger_insert @p_id				= 0
														,@p_asset_code		= @fa_code
														,@p_date			= @p_mod_date
														,@p_reff_code		= @p_code
														,@p_reff_name		= 'INSURANCE REFUND'
														,@p_reff_remark		= @reff_remark
														,@p_income_amount	= @refund_amount
														,@p_agreement_no	= @agreement_no
														,@p_client_name		= @client_name
														,@p_cre_date		= @p_cre_date		
														,@p_cre_by			= @p_cre_by		
														,@p_cre_ip_address	= @p_cre_ip_address
														,@p_mod_date		= @p_mod_date		
														,@p_mod_by			= @p_mod_by		
														,@p_mod_ip_address	= @p_mod_ip_address
			
			    fetch next from cursor_name 
				into @fa_code
					,@item_name
					,@refund_amount
					,@agreement_no
					,@client_name
			end
			
			close cursor_name
			deallocate cursor_name
			
		end
        else
		begin
		    set @msg = 'Data already proceed' ;
			raiserror(@msg, 16, -1) ;
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

