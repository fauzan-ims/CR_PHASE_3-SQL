CREATE PROCEDURE dbo.xsp_cashier_received_request_insert
(
	@p_code					  nvarchar(50)
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_request_status		  nvarchar(10)
	,@p_request_currency_code nvarchar(5)
	,@p_request_date		  datetime
	,@p_request_amount		  decimal(18, 2)
	,@p_request_remarks		  nvarchar(1000)
	,@p_agreement_no		  nvarchar(50)
	,@p_doc_ref_code		  nvarchar(50)
	,@p_doc_ref_name		  nvarchar(250)
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
	declare @msg nvarchar(max) ;

	begin try

		if exists (select 1 from sys_general_subcode_detail where code = @p_code)
		begin
    		SET @msg = 'Code already exist';
    		raiserror(@msg, 16, -1) ;
		end

		insert into cashier_received_request
		(
			code
			,branch_code
			,branch_name
			,request_status
			,request_currency_code
			,request_date
			,request_amount
			,request_remarks
			,agreement_no
			,doc_ref_code
			,doc_ref_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_request_status
			,@p_request_currency_code
			,@p_request_date
			,@p_request_amount
			,@p_request_remarks
			,@p_agreement_no
			,@p_doc_ref_code
			,@p_doc_ref_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
