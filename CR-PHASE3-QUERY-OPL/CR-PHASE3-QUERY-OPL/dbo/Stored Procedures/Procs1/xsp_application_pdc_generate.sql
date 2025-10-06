CREATE PROCEDURE dbo.xsp_application_pdc_generate 
(
	@p_application_no	nvarchar(50)
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
	declare @msg						nvarchar(max)			
			,@currency_code				nvarchar(3)
			,@bank_code					nvarchar(50)
			,@bank_name					nvarchar(250)
			,@start_date				datetime
			,@pdc_amount				decimal(18,2)
			,@pdc_value_amount			decimal(18,2)
			,@pdc_inkaso_fee_amount		decimal(18,2)
			,@pdc_clearing_fee_amount	decimal(18,2)
			,@allocation_type			nvarchar(50)
			,@pdc_start_no				nvarchar(50)
			,@prefix_code				nvarchar(10)
			,@postfix_code				nvarchar(10)
			,@no_of_pdc					int
			,@freq						int
			,@due_date					datetime

	begin try
	    
		--validate amount in header can not zero
		if((select pdc_amount from dbo.application_pdc_generate where application_no = @p_application_no) = 0)
		begin
			set @msg =  'Amount cannot zero' 
			raiserror(@msg,16,1)
		end
        
		--delete	dbo.application_pdc
		--where	application_code = @p_application_no

		select	@currency_code				= pdc_currency_code
				,@bank_code					= pdc_bank_code
				,@bank_name					= pdc_bank_name
				,@start_date				= pdc_first_date	
				,@due_date					= pdc_first_date	
				,@pdc_value_amount			= pdc_value_amount
				,@pdc_inkaso_fee_amount		= pdc_inkaso_fee_amount
				,@pdc_clearing_fee_amount	= pdc_clearing_fee_amount
				,@pdc_amount				= pdc_amount 
				,@allocation_type			= pdc_allocation_type
				,@pdc_start_no				= pdc_no_running
				,@prefix_code				= isnull(pdc_no_prefix, '')
				,@postfix_code				= isnull(pdc_no_postfix, '')
				,@no_of_pdc					= pdc_count
				,@freq						= pdc_frequency_month
		from	dbo.application_pdc_generate
		where	application_no				= @p_application_no
		
		declare	@counter				int = 1	
				,@pdc_no				nvarchar(50)
				,@pdc_detail_id			int = 0
				,@no					int
				,@temp					int = len(@pdc_start_no)
				,@lenght				INT = len(@pdc_start_no)
					
		while (@counter <= @no_of_pdc)
		begin		
			
			set @pdc_no = @prefix_code + @pdc_start_no + isnull(@postfix_code, '')--format pdc dirakit

			exec dbo.xsp_application_pdc_insert @p_id							= @pdc_detail_id output -- bigint
												,@p_application_code			= @p_application_no -- nvarchar(50)
												,@p_pdc_no						= @pdc_no -- nvarchar(50)
												,@p_pdc_date					= @due_date -- datetime
												,@p_pdc_bank_code				= @bank_code -- nvarchar(50)
												,@p_pdc_bank_name				= @bank_name -- nvarchar(250)
												,@p_pdc_allocation_type			= @allocation_type -- nvarchar(50)
												,@p_pdc_currency_code			= @currency_code -- nvarchar(3)
												,@p_pdc_value_amount			= @pdc_value_amount -- decimal(18, 0)
												,@p_pdc_inkaso_fee_amount		= @pdc_inkaso_fee_amount -- decimal(18, 0)
												,@p_pdc_clearing_fee_amount		= @pdc_clearing_fee_amount -- decimal(18, 0)
												,@p_pdc_amount					= @pdc_amount -- decimal(18, 0)
												,@p_cre_date					= @p_cre_date -- datetime
												,@p_cre_by						= @p_cre_by -- nvarchar(15)
												,@p_cre_ip_address				= @p_cre_ip_address -- nvarchar(15)
												,@p_mod_date					= @p_mod_date -- datetime
												,@p_mod_by						= @p_mod_by -- nvarchar(15)
												,@p_mod_ip_address				= @p_mod_ip_address -- nvarchar(15)
			
			

				set	@no = cast(@pdc_start_no as int) + 1
				set	@lenght = len(@no)	

				IF @lenght > @temp
					SET @temp = @lenght

			--begin 
				select @pdc_start_no = replace(str(cast((cast(@pdc_start_no as int) + 1) as nvarchar), @temp, 0), ' ', '0') --untuk buat no pdc selanjutnya
				set @due_date = dateadd(month, (@counter* @freq), @start_date)
				set @counter	= @counter + 1

			--end
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

