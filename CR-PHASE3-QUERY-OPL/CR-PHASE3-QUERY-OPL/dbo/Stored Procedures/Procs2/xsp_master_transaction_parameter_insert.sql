CREATE PROCEDURE dbo.xsp_master_transaction_parameter_insert
(
	@p_id						bigint = 0 output
	,@p_transaction_code		nvarchar(50)
	,@p_process_code			nvarchar(50)
	,@p_order_key				int				= 0
	,@p_parameter_amount		decimal(18, 2)  = 0
	,@p_is_calculate_by_system	nvarchar(1)
	,@p_is_transaction			nvarchar(1)
	,@p_is_amount_editable		nvarchar(1)	    = 'F'
	,@p_is_discount_editable	nvarchar(1)
	,@p_gl_link_code			nvarchar(50)	= null
	,@p_discount_gl_link_code	nvarchar(50)	= null
	,@p_maximum_disc_pct		decimal(9, 6)
	,@p_maximum_disc_amount		decimal(18, 2)
	,@p_is_journal				nvarchar(1)		= 'F'
	,@p_debet_or_credit			nvarchar(10)	= ''
	,@p_is_discount_jurnal		nvarchar(1)		= 'F'
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_calculate_by_system = 'T'
		set @p_is_calculate_by_system = '1' ;
	else
		set @p_is_calculate_by_system = '0'
		set @p_is_amount_editable = 'T' ;

	if @p_is_transaction = 'T'
		set @p_is_transaction = '1' ;
	else
		set @p_is_transaction = '0' ;

	if @p_is_amount_editable = 'T'
		set @p_is_amount_editable = '1' ;
	else
		set @p_is_amount_editable = '0' ;

	if @p_is_discount_editable = 'T'
		set @p_is_discount_editable = '1' ;
	else
		set @p_is_discount_editable = '0' ;

	if @p_is_journal = 'T'
		set @p_is_journal = '1' ;
	else
		set @p_is_journal = '0' ;

	if @p_is_discount_jurnal = 'T'
		set @p_is_discount_jurnal = '1' ;
	else
		set @p_is_discount_jurnal = '0' ;

	begin try

		--if exists
		--(
		--	select	1
		--	from	master_transaction_parameter
		--	where	transaction_code = @p_transaction_code
		--	and		process_code = @p_process_code
		--)
		--begin
		--	set @msg = 'Transaction Name already exist' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		if @p_maximum_disc_pct > 100
		begin
			set @msg ='Maximum Discount must be lower than 100';
			raiserror(@msg,16,1) ;
		end
		
		select	@p_order_key = max(order_key) + 1
		from	dbo.master_transaction_parameter
		where	process_code = @p_process_code ;
		set		@p_order_key = isnull(@p_order_key,1)

		insert into master_transaction_parameter
		(
			transaction_code
			,process_code
			,order_key
			,parameter_amount
			,is_calculate_by_system
			,is_transaction
			,is_amount_editable
			,is_discount_editable
			,gl_link_code
			,discount_gl_link_code
			,maximum_disc_pct
			,maximum_disc_amount
			,is_journal
			,debet_or_credit
			,is_discount_jurnal
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	
			@p_transaction_code
			,@p_process_code
			,@p_order_key
			,@p_parameter_amount
			,@p_is_calculate_by_system
			,@p_is_transaction
			,@p_is_amount_editable
			,@p_is_discount_editable
			,@p_gl_link_code
			,@p_discount_gl_link_code
			,@p_maximum_disc_pct
			,@p_maximum_disc_amount
			,@p_is_journal
			,@p_debet_or_credit
			,@p_is_discount_jurnal
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

