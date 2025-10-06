CREATE PROCEDURE dbo.xsp_application_fee_amortization_insert
(
	@p_application_no			nvarchar(50)
	,@p_installment_no			int
	,@p_fee_code				nvarchar(50)
	,@p_fee_name				nvarchar(250)
	,@p_amort_due_date			datetime
	,@p_amort_amount			decimal(18,2)
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)as
begin

	declare	@msg	nvarchar(max)

	begin try
	
		insert into	dbo.application_fee_amortization
		(
			application_no
			,installment_no
			,fee_code
			,fee_name
			,amortization_date
			,amortization_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_installment_no
			,@p_fee_code
			,@p_fee_name
			,@p_amort_due_date
			,@p_amort_amount	
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

