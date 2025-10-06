CREATE PROCEDURE dbo.xsp_repossession_pricing_proceed
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@code					nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@repossession_code		nvarchar(50)
			,@transaction_status	nvarchar(10)
			,@appraisal_status		nvarchar(10)
			,@transaction_date		datetime
			,@transaction_amount	decimal(18, 2)
			,@request_amount		decimal(18, 2)
			,@transaction_remarks	nvarchar(4000)
			,@received_date			nvarchar(50)
			,@received_reff_no		nvarchar(50)
			,@agreement_external_no	nvarchar(50)
			,@received_reff_name	nvarchar(250);

	begin try
		if not exists	(	
							select	1 
							from	dbo.repossession_pricing_detail 
							where	pricing_code = @p_code
						)
		begin
			set @msg = 'Please input Repossession data';
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.repossession_pricing where code = @p_code and transaction_status = 'HOLD')
		begin
			select	@code					= rpc.code		
				   ,@branch_code			= rpc.branch_code
				   ,@branch_name			= rpc.branch_name
				   ,@repossession_code		= rpd.asset_code	
				   ,@transaction_status		= rpc.transaction_status
				   ,@transaction_date		= rpc.transaction_date
				   ,@request_amount			= rpd.request_amount
			from	repossession_pricing rpc
					left join dbo.repossession_pricing_detail rpd on (rpd.pricing_code = rpc.code)
			where	rpc.code				= @p_code


			begin
				update	dbo.repossession_pricing_detail
				set		approve_amount			= request_amount
				where	pricing_code			= @code

				update	dbo.repossession_pricing
				set		transaction_status		= 'ON PROCESS'
						--
						,mod_date				= @p_mod_date		
						,mod_by					= @p_mod_by			
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @p_code
			end
		end
		else
		begin
			set @msg = 'Data already process';
			raiserror(@msg,16,1) ;
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

