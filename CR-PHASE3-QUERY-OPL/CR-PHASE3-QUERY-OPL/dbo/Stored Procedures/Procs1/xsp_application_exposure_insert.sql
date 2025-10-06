/*
	ALTERd : Nia, 10 Agus 2021
*/
CREATE PROCEDURE dbo.xsp_application_exposure_insert
(
	@p_id						bigint = 0 output
	,@p_application_no			nvarchar(50)
	,@p_relation_type			nvarchar(20) = '-'
	,@p_agreement_no			nvarchar(50)
	,@p_agreement_date			datetime
	,@p_facility_name			nvarchar(250)
	,@p_amount_finance_amount   decimal(18, 2)
	,@p_os_installment_amount   decimal(18, 2)
	,@p_installment_amount      decimal(18, 2)
	,@p_tenor					int
	,@p_os_tenor				int
	,@p_last_due_date			datetime
	,@p_ovd_days				int
	,@p_ovd_installment_amount  decimal(18, 2)
	,@p_description				nvarchar(4000)
	--
	,@p_cre_date		        datetime
	,@p_cre_by			        nvarchar(15)
	,@p_cre_ip_address	        nvarchar(15)
	,@p_mod_date		        datetime
	,@p_mod_by			        nvarchar(15)
	,@p_mod_ip_address	        nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max);

	begin try
		
		insert into dbo.application_exposure
		(
		    application_no,
		    relation_type,
		    agreement_no,
		    agreement_date,
		    facility_name,
		    amount_finance_amount,
		    os_installment_amount,
		    installment_amount,
		    tenor,
		    os_tenor,
		    last_due_date,
		    ovd_days,
		    ovd_installment_amount,
		    description,
			--
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(	@p_application_no			
			,@p_relation_type			
			,@p_agreement_no			
			,@p_agreement_date			
			,@p_facility_name			
			,@p_amount_finance_amount   
			,@p_os_installment_amount   
			,@p_installment_amount      
			,@p_tenor					
			,@p_os_tenor				
			,@p_last_due_date			
			,@p_ovd_days				
			,@p_ovd_installment_amount  
			,@p_description				
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




