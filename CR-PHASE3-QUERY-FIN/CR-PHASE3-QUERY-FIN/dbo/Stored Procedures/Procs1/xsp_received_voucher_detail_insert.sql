CREATE PROCEDURE dbo.xsp_received_voucher_detail_insert
(
	@p_id					  bigint = 0 output
	,@p_received_voucher_code nvarchar(50)
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_gl_link_code		  nvarchar(50)
	,@p_orig_amount			  decimal(18, 2) = 0
	,@p_orig_currency_code	  nvarchar(3)
	,@p_exch_rate			  decimal(18, 6) = 1
	,@p_base_amount			  decimal(18, 2) = 0
	,@p_division_code		  nvarchar(50)	 = null
	,@p_division_name		  nvarchar(250)	 = null
	,@p_department_code		  nvarchar(50)	 = null
	,@p_department_name		  nvarchar(250)	 = null
	,@p_remarks				  nvarchar(4000)
	,@p_doc_reff_no			  nvarchar(50) = '' -- (+) Ari 2023-12-02
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@sum_amount		decimal(18, 2)
			,@rate_amount		decimal(18, 6);

	begin TRY
    
	set @p_base_amount = @p_orig_amount * @p_exch_rate

		insert into received_voucher_detail
		(
			received_voucher_code
			,branch_code
			,branch_name
			,gl_link_code
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,division_code
			,division_name
			,department_code
			,department_name
			,remarks
			,doc_reff_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_received_voucher_code
			,@p_branch_code
			,@p_branch_name
			,@p_gl_link_code
			,@p_orig_amount
			,@p_orig_currency_code
			,@p_exch_rate
			,@p_base_amount
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_remarks
			,@p_doc_reff_no -- (+) Ari 2023-12-02
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		select	@sum_amount = isnull(sum(base_amount),0)
		from	dbo.received_voucher_detail
		where	received_voucher_code = @p_received_voucher_code

		select	@rate_amount = received_exch_rate
		from	dbo.received_voucher
		where	code = @p_received_voucher_code

		update	dbo.received_voucher
		set		received_orig_amount	= @sum_amount * @rate_amount
				,received_base_amount	= @sum_amount 
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_received_voucher_code;

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
