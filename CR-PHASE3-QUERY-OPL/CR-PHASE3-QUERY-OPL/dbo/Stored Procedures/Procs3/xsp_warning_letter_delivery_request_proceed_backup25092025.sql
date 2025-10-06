CREATE PROCEDURE dbo.xsp_warning_letter_delivery_request_proceed_backup25092025
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
			,@letter_type					nvarchar(20)
			,@agreement_no					nvarchar(50)
			,@installment_no				int
			,@branch_code					nvarchar(50)
			,@code							nvarchar(50)
			,@branch_name					nvarchar(250)
			,@collector_code				nvarchar(50)	= null
			,@collector_name				nvarchar(250)	= null
			,@letter_code					nvarchar(50)
			,@code_sp1						nvarchar(50)
			,@letter_code_sp1				nvarchar(50)
			,@code_sp2						nvarchar(50)
			,@letter_code_sp2				nvarchar(50)
			,@client_no						NVARCHAR(50)
			,@client_name					nvarchar(250)
			,@overdue_days					BIGINT
            ,@total_overdue_amount			DECIMAL(18,2)
			,@total_agreement_count			BIGINT
			,@total_asset_count				BIGINT
            ,@total_monthly_rental_amount	DECIMAL(18,2)
			,@last_print_by					nvarchar(250)
			,@letter_status					nvarchar(50)
			,@generate_type					nvarchar(250)
			,@letter_date					DATETIME
			,@print_count					INT
			,@p_id							INT;


	select	@branch_code					= max(wl.branch_code		)
			,@branch_name					= max(wl.branch_name		)
			,@letter_code					= max(wl.letter_no			)
			,@agreement_no					= max(wl.agreement_no		)
			,@collector_code				= max(am.marketing_code		)
			,@collector_name				= max(am.marketing_name		)
			,@letter_type					= max(wl.LETTER_TYPE		)
			,@agreement_no					= max(wl.agreement_no		)
			,@installment_no				= max(wl.INSTALLMENT_NO		)
			,@client_no						= am.CLIENT_NO
			,@client_name					= am.CLIENT_NAME
			,@overdue_days					= MAX(wl.OVERDUE_DAYS		)
			,@total_overdue_amount			= SUM(a.OBLIGATION_AMOUNT) - SUM(ISNULL(b.PAYMENT_AMOUNT, 0))
			,@total_agreement_count			= max(taskAgg.total_agreement_count			)
			,@total_asset_count				= max(taskagg.total_asset_count				)
			,@total_monthly_rental_amount	= max(taskAgg.total_monthly_rental_amount	)
			,@last_print_by					= max(wl.last_print_by						)
			,@letter_status					= max(wl.letter_status						)
			,@generate_type					= max(wl.generate_type						)
			,@installment_no				= max(wl.installment_no						)
			,@letter_date					= max(wl.LETTER_DATE						)
			,@print_count					= max(wl.PRINT_COUNT						)
	FROM warning_letter wl
			INNER JOIN dbo.agreement_main am ON am.agreement_no = wl.agreement_no
			LEFT JOIN dbo.AGREEMENT_OBLIGATION a ON a.AGREEMENT_NO = am.AGREEMENT_NO
			LEFT JOIN dbo.AGREEMENT_OBLIGATION_PAYMENT b ON b.OBLIGATION_CODE = a.CODE
			OUTER APPLY (
				SELECT
					COUNT(a.agreement_no) AS total_agreement_count,
					COUNT(b.asset_no) AS total_asset_count,
					SUM(b.monthly_rental_rounded_amount) AS total_monthly_rental_amount
				FROM dbo.agreement_main a
					INNER JOIN dbo.agreement_asset b ON b.agreement_no = a.agreement_no
				WHERE a.client_no = am.client_no
					AND a.AGREEMENT_STATUS = 'GO LIVE'
			) taskAgg
	where	wl.code				= @p_code
	GROUP BY am.client_no, am.client_name;
	
	begin try

	select	*
			from	warning_letter wl
			where	wl.agreement_no	   = @agreement_no
					and wl.letter_type = @letter_type
					and letter_status  = 'ON PROCESS'

		if exists
		(
			select	1
			from	warning_letter wl
			where	wl.agreement_no	   = @agreement_no
					and wl.letter_type = @letter_type
					and letter_status  = 'ON PROCESS'
		)
		begin
			begin
				exec dbo.xsp_warning_letter_delivery_insert	@p_code								= @code OUTPUT
															,@p_branch_code						= @branch_code
															,@p_branch_name						= @branch_name
															,@p_delivery_status					= 'HOLD' 
															,@p_delivery_date					= @p_mod_date 
															,@p_delivery_courier_type			= 'INTERNAL'
															,@p_delivery_courier_code			= ''
															,@p_delivery_collector_code			= @collector_code
															,@p_delivery_collector_name			= @collector_name
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
															,@p_mod_ip_address					= @p_mod_ip_address ;
			END ;

			if (
				   @letter_type = 'SOMASI'
				   or	@letter_type = 'SP2'
			   )
			begin
				if exists
				(
					select	1
					from	warning_letter wl
					where	wl.agreement_no		= @agreement_no
							--and wl.installment_no = @installment_no
							and wl.letter_type	= 'SP1'
							and letter_status	= 'ON PROCESS'
				)
				begin
					select	@letter_code_sp1	= letter_no
							,@code_sp1			= wl.code
					from	warning_letter wl
					where	wl.agreement_no		= @agreement_no
							--and wl.installment_no = @installment_no
							and wl.letter_type	= 'SP1'
							and letter_status	= 'ON PROCESS' ;

					update	dbo.warning_letter
					set		letter_status		= 'POST'
							,delivery_code		= @code
							,delivery_date		= @p_mod_date
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @code_sp1 ;
				end ;
			end ;

			if (@letter_type = 'SOMASI')
			begin
				if exists
				(
					select	1
					from	warning_letter wl
					where	wl.agreement_no		= @agreement_no
							--and wl.installment_no = @installment_no
							and wl.letter_type	= 'SP2'
							and letter_status	= 'ON PROCESS'
				)
				begin
					select	@letter_code_sp2	= letter_no
							,@code_sp2			= wl.code
					from	warning_letter wl
					where	wl.agreement_no		= @agreement_no
							--and wl.installment_no = @installment_no
							and wl.letter_type	= 'SP2'
							and letter_status	= 'ON PROCESS' ;

					update	dbo.warning_letter
					set		letter_status	= 'POST'
							,delivery_code	= @code
							,delivery_date	= @p_mod_date
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code			= @code_sp2 ;
				end ;
			end ;

			update	dbo.warning_letter
			set		letter_status		= 'POST'
					,delivery_code		= @code
					,delivery_date		= @p_mod_date
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
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
