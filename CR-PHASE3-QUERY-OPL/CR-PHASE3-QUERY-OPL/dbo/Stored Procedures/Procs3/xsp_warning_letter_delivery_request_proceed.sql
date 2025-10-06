CREATE PROCEDURE dbo.xsp_warning_letter_delivery_request_proceed
(
	@p_code			   NVARCHAR(50)
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
	declare @msg							nvarchar(max)
			,@client_no						nvarchar(50)
			,@warning_letter_delivery_code	nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@date							datetime = dbo.xfn_get_system_date()
			,@client_name					nvarchar(250)
			,@letter_date					datetime
			,@letter_type					nvarchar(50)
			,@generate_type					nvarchar(50)

			,@overdue_days					bigint
			,@total_overdue_amount			decimal(18,2)
			,@total_agreement_count			bigint
			,@total_asset_count				bigint
			,@total_monthly_rental_amount	decimal(18,2)
			,@last_print_by					nvarchar(50)
			,@print_count					bigint
	
	begin try

	select	@client_no		= client_no
			,@branch_code	= branch_code
			,@branch_name	= branch_name
			,@client_name	= client_name
			,@letter_date	= letter_date
			,@letter_type	= letter_type
			,@generate_type	= generate_type

			,@overdue_days					= overdue_days
			,@total_overdue_amount			= total_overdue_amount
			,@total_agreement_count			= total_agreement_count
			,@total_asset_count				= total_asset_count
			,@total_monthly_rental_amount	= total_monthly_rental_amount
			,@last_print_by					= last_print_by
			,@print_count					= print_count
	from	dbo.warning_letter
	where	code = @p_code

	select	@warning_letter_delivery_code = code
	from	dbo.warning_letter_delivery wld
			inner join dbo.warning_letter_delivery_detail wldd on wldd.delivery_code = wld.code
	where	client_no		= @client_no
	and		wldd.letter_code = @p_code
	and		delivery_status = 'HOLD'

	if isnull(@warning_letter_delivery_code,'') = ''
	begin
			exec dbo.xsp_warning_letter_delivery_insert	@p_code								= @warning_letter_delivery_code OUTPUT
														,@p_branch_code						= @branch_code
														,@p_branch_name						= @branch_name
														,@p_delivery_status					= 'HOLD' 
														,@p_delivery_date					= @date 
														,@p_delivery_courier_type			= 'INTERNAL'
														,@p_delivery_courier_code			= ''
														,@p_delivery_collector_code			= ''
														,@p_delivery_collector_name			= ''
														,@p_delivery_remarks				= 'WARNING LETTER DELIVERY'
														,@p_client_no						= @client_no
														,@p_client_name						= @client_name
														,@p_delivery_address				= ''
														,@p_delivery_to_name				= ''
														,@p_client_phone_no					= ''
														,@p_client_npwp						= ''
														,@p_client_email					= ''
														,@p_letter_date						= @letter_date
														,@p_letter_type						= @letter_type
														,@p_generate_type					= @generate_type
														,@p_overdue_days					= @overdue_days
														,@p_total_overdue_amount			= @total_overdue_amount
														,@p_total_agreement					= @total_agreement_count
														,@p_total_asset						= @total_asset_count
														,@p_total_monthly_rental_amount		= @total_monthly_rental_amount
														,@p_last_print_by					= @last_print_by
														,@p_print_count						= @print_count
														,@p_cre_date						= @p_cre_date
														,@p_cre_by							= @p_cre_by
														,@p_cre_ip_address					= @p_cre_ip_address
														,@p_mod_date						= @p_mod_date
														,@p_mod_by							= @p_mod_by
														,@p_mod_ip_address					= @p_mod_ip_address 

			exec dbo.xsp_warning_letter_delivery_detail_insert  @p_id				= 0
			                                                    ,@p_delivery_code	= @warning_letter_delivery_code
			                                                    ,@p_letter_code		= @p_code
			                                                    ,@p_cre_date		= @p_cre_date
																,@p_cre_by			= @p_cre_by
																,@p_cre_ip_address	= @p_cre_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address 
			
	end
		update	dbo.warning_letter
		set		letter_status		= 'POST'
				,delivery_code		= @warning_letter_delivery_code
				,delivery_date		= @date
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

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
