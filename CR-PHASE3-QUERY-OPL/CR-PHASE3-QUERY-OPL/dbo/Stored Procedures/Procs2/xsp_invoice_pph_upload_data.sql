CREATE PROCEDURE dbo.xsp_invoice_pph_upload_data
(
	@p_invoice_external_no nvarchar(50)
	,@p_payment_reff_no	   nvarchar(50) = ''
	,@p_payment_reff_date  datetime		= ''
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	/*
		Cre_by		: sepria
		Cre_date	: 2024-07-02
		Cre_Note	: untuk menampung data upload dan munculkan validasi tanpa memproses data lainnya
	*/
	
	declare @msg		 nvarchar(max)
			,@invoice_no nvarchar(50) ;

	begin try
		
		insert into invoice_pph_upload_data
		(
			 p_user_id
			,invoice_external_no	
			,payment_reff_no		
			,payment_reff_date		
			,cre_date				
			,cre_by					
			,cre_ip_address			
			,mod_date				
			,mod_by					
			,mod_ip_address			
		)
		values
		(
			@p_cre_by
			,@p_invoice_external_no 
			,@p_payment_reff_no	   
			,@p_payment_reff_date  
			--
			,@p_cre_date		   
			,@p_cre_by			   
			,@p_cre_ip_address	   
			,@p_mod_date		   
			,@p_mod_by			   
			,@p_mod_ip_address	   
		)


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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
