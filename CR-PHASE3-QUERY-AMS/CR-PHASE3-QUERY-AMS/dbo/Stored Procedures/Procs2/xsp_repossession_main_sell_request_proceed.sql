CREATE PROCEDURE dbo.xsp_repossession_main_sell_request_proceed
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@selling_code						nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@approve_amount					decimal(18, 2)
			,@request_amount					decimal(18, 2);
			
	begin try
		if exists (select 1 from dbo.repossession_main rmn
								 inner join dbo.repossession_pricing_detail rpd on (rpd.repossession_code = rmn.code)
								 where code	= @p_code)

		begin
		select	@branch_code						= rmn.branch_code
				,@branch_name						= rmn.branch_name
				,@request_amount					= isnull(rmn.pricing_amount, 0)
				,@approve_amount					= rpd.approve_amount
		from	dbo.repossession_main rmn
				inner join dbo.repossession_pricing_detail rpd on (rpd.repossession_code = rmn.code)
		where	code								= @p_code

		if exists (select 1 from dbo.repossession_selling where transaction_status = 'HOLD' and branch_code = @branch_code)
		begin
			select @selling_code = code from dbo.repossession_selling where transaction_status = 'HOLD' and branch_code = @branch_code
		end

		else
		begin
			exec dbo.xsp_repossession_selling_insert @p_code					= @selling_code output
													 ,@p_branch_code			= @branch_code
													 ,@p_branch_name			= @branch_name		
													 ,@p_transaction_status		= 'HOLD'
													 ,@p_transaction_date		= @p_mod_date	
													 ,@p_transaction_remarks	= ''
													 ,@p_sell_to_type			= 'DIRECT SELL'
													 ,@p_sell_to_name			= ''
													 ,@p_auction_code			= null
													 ,@p_cre_date				= @p_mod_date		
													 ,@p_cre_by					= @p_mod_by			
													 ,@p_cre_ip_address			= @p_mod_ip_address
													 ,@p_mod_date				= @p_mod_date		
													 ,@p_mod_by					= @p_mod_by			
													 ,@p_mod_ip_address			= @p_mod_ip_address
			
		end

		exec dbo.xsp_repossession_selling_detail_insert @p_code								= 0
														,@p_selling_code					= @selling_code
														,@p_repossession_code				= @p_code
														,@p_request_amount					= @approve_amount
														,@p_sell_status						= 'HOLD'
														,@p_is_sold							= 0
														,@p_is_unit_out						= 0
														,@p_sell_date						= ''
														,@p_sell_amount						= 0
														,@p_sell_remarks					= ''
														,@p_net_received_amount				= 0
														,@p_received_request_code			= null
														,@p_received_voucher_no				= null
														,@p_received_voucher_date			= null
														,@p_reversal_status					= ''
														,@p_reversal_date					= null
														,@p_reversal_amount					= 0
														,@p_reversal_remarks				= null
														,@p_payment_request_code			= null
														,@p_payment_voucher_no				= null
														,@p_payment_voucher_date			= null
														,@p_cre_date						= @p_mod_date		
														,@p_cre_by							= @p_mod_by			
														,@p_cre_ip_address					= @p_mod_ip_address
														,@p_mod_date						= @p_mod_date		
														,@p_mod_by							= @p_mod_by			
														,@p_mod_ip_address					= @p_mod_ip_address
			end

			else
			begin
					set @msg = 'Unit must be given a price';
					raiserror(@msg,16,1) ;
			end

			update	dbo.repossession_main
			set		repossession_status_process = 'SELLING'
			where	code						= @p_code
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

