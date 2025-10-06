
CREATE procedure dbo.xsp_invoice_pph_insert
(
	@p_id				  bigint		 = 0 output
	,@p_invoice_no		  nvarchar(50)
	,@p_settlement_type	  nvarchar(10)
	,@p_settlement_status nvarchar(10)
	,@p_file_path		  nvarchar(250)
	,@p_file_name		  nvarchar(250)
	,@p_payment_reff_no	  nvarchar(50)
	,@p_payment_reff_date nvarchar(50)
	,@p_total_pph_amount  decimal(18, 2) = 0
	--
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into invoice_pph
		(
			invoice_no
			,settlement_type
			,settlement_status
			,file_path
			,file_name
			,payment_reff_no
			,payment_reff_date
			,total_pph_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_invoice_no
			,@p_settlement_type
			,@p_settlement_status
			,@p_file_path
			,@p_file_name
			,@p_payment_reff_no
			,@p_payment_reff_date
			,@p_total_pph_amount
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_invoice_pph_insert] TO [ims-raffyanda]
    AS [dbo];

