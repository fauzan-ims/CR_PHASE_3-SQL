
CREATE PROCEDURE [dbo].[xsp_payment_transaction_reversal_request]
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@payment_transaction_date		datetime
			,@payment_remarks				nvarchar(4000)
			,@system_date					datetime = dbo.xfn_get_system_date()

	begin try

		if exists (select 1 from dbo.payment_transaction where code = @p_code and payment_status <> 'PAID')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin

			select	@branch_code					= branch_code
					,@branch_name					= branch_name
					,@payment_transaction_date		= payment_transaction_date
					,@payment_remarks				= payment_remarks
			from	dbo.payment_transaction
			where	code = @p_code

			exec dbo.xsp_reversal_main_insert @p_code					= 0
											  ,@p_branch_code			= @branch_code
											  ,@p_branch_name			= @branch_name
											  ,@p_reversal_status		= N'HOLD' 
											  ,@p_reversal_date			= @system_date
											  ,@p_reversal_remarks		= @payment_remarks
											  ,@p_source_reff_code		= @p_code
											  ,@p_source_reff_name		= N'Payment Transaction'
											  ,@p_cre_date				= @p_cre_date		
											  ,@p_cre_by				= @p_cre_by			
											  ,@p_cre_ip_address		= @p_cre_ip_address
											  ,@p_mod_date				= @p_mod_date		
											  ,@p_mod_by				= @p_mod_by			
											  ,@p_mod_ip_address		= @p_mod_ip_address
			

			update	dbo.payment_transaction
			set		payment_status		= 'ON REVERSE'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code

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
end

