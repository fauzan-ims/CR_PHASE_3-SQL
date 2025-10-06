-- Louis Rabu, 08 Februari 2023 14.29.17 -- 
CREATE PROCEDURE dbo.xsp_ams_interface_cashier_received_request_cancel 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@doc_ref_name		nvarchar(250)
			,@doc_ref_code		nvarchar(50);

	begin try
		select  @doc_ref_code					= doc_ref_code
				,@doc_ref_name					= doc_ref_name
		from    dbo.ams_interface_cashier_received_request
        where	code = @p_code
	
			--if (@doc_ref_name = 'INSURANCE REGISTER')
			--begin 
			--	update insurance_register
			--	set    register_status = 'HOLD'
			--		   --
			--		   ,mod_date		 = @p_mod_date		
			--		   ,mod_by			 = @p_mod_by			
			--		   ,mod_ip_address	 = @p_mod_ip_address	
			--	where  code = @doc_ref_code
							
			--end
			--else 
			if (@doc_ref_name = 'INSURANCE ENDORSEMENT')
			begin
				update endorsement_main
				set    endorsement_status = 'HOLD'
					   --
					   ,mod_date		  = @p_mod_date		
					   ,mod_by			  = @p_mod_by			
					   ,mod_ip_address	  = @p_mod_ip_address	
				where  code				  = @doc_ref_code
							
			end
			
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
