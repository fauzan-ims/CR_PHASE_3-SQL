CREATE PROCEDURE dbo.xsp_fin_interface_received_request_post
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date 		datetime
	,@p_cre_by 			nvarchar(15)
	,@p_cre_ip_address 	nvarchar(15)
	,@p_mod_date 		datetime
	,@p_mod_by 			nvarchar(15)
	,@p_mod_ip_address 	nvarchar(15)
)
as
begin

	declare @msg		nvarchar(max);
		
	begin try

		insert into dbo.received_request
		(
			code
			,branch_code
			,branch_name
			,received_source
			,received_request_date
			,received_source_no
			,received_status
			,received_currency_code
			,received_amount
			,received_remarks
			,received_transaction_code
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
			   ,branch_code
			   ,branch_name
			   ,received_source
			   ,received_request_date
			   ,received_source_no
			   ,received_status
			   ,received_currency_code
			   ,received_amount
			   ,received_remarks
			   ,null
			   ,cre_date
			   ,cre_by
			   ,cre_ip_address
			   ,mod_date
			   ,mod_by
			   ,mod_ip_address 
		from	dbo.fin_interface_received_request
		where	code = @p_code

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
