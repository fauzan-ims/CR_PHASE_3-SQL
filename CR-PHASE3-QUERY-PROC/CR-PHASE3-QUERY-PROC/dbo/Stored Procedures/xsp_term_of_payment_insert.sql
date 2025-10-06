CREATE PROCEDURE dbo.xsp_term_of_payment_insert
(
	@p_id				 bigint = 0 output
	,@p_po_code			 nvarchar(50)
	,@p_transaction_code nvarchar(50)
	,@p_transaction_name nvarchar(250)
	,@p_transaction_date datetime	= null
	,@p_termin_type_code nvarchar(50)
	,@p_termin_type_name nvarchar(250)
	,@p_refference_code	 nvarchar(50)
	,@p_percentage		 decimal(18, 2)
	,@p_amount			 decimal(18, 2)
	,@p_is_paid			 nvarchar(1)
	,@p_pph_amount		 decimal(18, 2)	= 0
	,@p_ppn_amount		 decimal(18, 2)	= 0
	,@p_remark			 nvarchar(4000)	= ''
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_paid = 'T'
		set @p_is_paid = '1' ;
	else
		set @p_is_paid = '0' ;

	begin try
		if(@p_percentage > 100)
		begin
			set @msg = 'Percentage Must Be Less Than 100';
			raiserror(@msg ,16,-1)
		end
		insert into term_of_payment
		(
			po_code
			,transaction_code
			,transaction_name
			,transaction_date
			,termin_type_code
			,termin_type_name
			,refference_code
			,percentage
			,amount
			,is_paid
			,pph_amount
			,ppn_amount
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_po_code
			,@p_transaction_code
			,@p_transaction_name
			,@p_transaction_date
			,@p_termin_type_code
			,@p_termin_type_name
			,@p_refference_code
			,@p_percentage
			,@p_amount
			,@p_is_paid
			,@p_pph_amount
			,@p_ppn_amount
			,@p_remark
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
