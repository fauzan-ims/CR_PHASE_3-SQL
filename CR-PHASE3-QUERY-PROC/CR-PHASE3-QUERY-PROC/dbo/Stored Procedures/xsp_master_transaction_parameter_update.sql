CREATE PROCEDURE [dbo].[xsp_master_transaction_parameter_update]
(
	@p_id					   bigint
	,@p_transaction_code	   nvarchar(50)
	,@p_process_code		   nvarchar(50)
	,@p_order_key			   int				= 0
	,@p_parameter_amount	   decimal(18, 2)	= 0
	,@p_is_calculate_by_system nvarchar(1)
	,@p_is_transaction		   nvarchar(1)
	,@p_is_amount_editable	   nvarchar(1)		= 'F'
	,@p_is_discount_editable   nvarchar(1)
	,@p_gl_link_code		   nvarchar(50)		= null
	,@p_gl_link_name		   nvarchar(50)		= null
	,@p_discount_gl_link_code  nvarchar(50)		= null
	,@p_discount_gl_link_name  nvarchar(50)		= null
	,@p_maximum_disc_pct	   decimal(9, 6)	= 0
	,@p_maximum_disc_amount	   decimal(18, 2)	= 0
	,@p_is_journal			   nvarchar(1)		= 'F'
	,@p_debet_or_credit		   nvarchar(10)		= ''
	,@p_is_discount_jurnal	   nvarchar(1)		= 'F'
	,@p_is_reduce_transaction  nvarchar(1)		= 'F'
	,@p_is_psak				   nvarchar(1)		= 'F'
	,@p_psak_gl_link_code	   nvarchar(50)		= null
	,@p_psak_gl_link_name	   nvarchar(50)		= null
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_calculate_by_system = 'T'
		set @p_is_calculate_by_system = '1' ;
	else
		set @p_is_calculate_by_system = '0' ;

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

	if @p_is_reduce_transaction = 'T'
		set @p_is_reduce_transaction = '1' ;
	else
		set @p_is_reduce_transaction = '0' ;

	if @p_is_psak = 'T'
		set @p_is_psak = '1' ;
	else
		set @p_is_psak = '0' ;

	begin try
		update	master_transaction_parameter
		set		transaction_code			= @p_transaction_code
				,process_code				= @p_process_code
				,order_key					= @p_order_key
				,parameter_amount			= @p_parameter_amount
				,is_calculate_by_system		= @p_is_calculate_by_system
				,is_transaction				= @p_is_transaction
				,is_amount_editable			= @p_is_amount_editable
				,is_discount_editable		= @p_is_discount_editable
				,gl_link_code				= @p_gl_link_code
				,gl_link_name				= @p_gl_link_name
				,discount_gl_link_code		= @p_discount_gl_link_code
				,discount_gl_link_name		= @p_discount_gl_link_name
				,maximum_disc_pct			= @p_maximum_disc_pct
				,maximum_disc_amount		= @p_maximum_disc_amount
				,is_journal					= @p_is_journal
				,debet_or_credit			= @p_debet_or_credit
				,is_discount_jurnal			= @p_is_discount_jurnal
				,is_reduce_transaction		= @p_is_reduce_transaction
				,is_psak					= @p_is_psak
				,psak_gl_link_code			= @p_psak_gl_link_code
				,psak_gl_link_name			= @p_psak_gl_link_name
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id = @p_id ;
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
