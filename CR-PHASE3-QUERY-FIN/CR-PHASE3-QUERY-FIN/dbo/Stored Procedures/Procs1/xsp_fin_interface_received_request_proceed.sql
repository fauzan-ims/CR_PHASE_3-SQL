/*
	created: Fadlan, 27 Mei 2021
*/
CREATE PROCEDURE dbo.xsp_fin_interface_received_request_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

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
			select code
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
				  ,@p_mod_date			
				  ,@p_mod_by			
				  ,@p_mod_ip_address	
				  ,@p_mod_date			
				  ,@p_mod_by			
				  ,@p_mod_ip_address	
			from   dbo.fin_interface_received_request
			where  code = @p_code

			insert into dbo.received_request_detail
			(
				received_request_code
				,branch_code
				,branch_name
				,gl_link_code
				,agreement_no
				,facility_code
				,facility_name
				,purpose_loan_code
				,purpose_loan_name
				,purpose_loan_detail_code
				,purpose_loan_detail_name
				,orig_currency_code
				,orig_amount
				,division_code
				,division_name
				,department_code
				,department_name
				,remarks
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	rrd.received_request_code
				   ,rrd.branch_code
				   ,rrd.branch_name
				   ,rrd.gl_link_code
				   ,rrd.agreement_no
				   ,rrd.facility_code
				   ,rrd.facility_name
				   ,rrd.purpose_loan_code
				   ,rrd.purpose_loan_name
				   ,rrd.purpose_loan_detail_code
				   ,rrd.purpose_loan_detail_name
				   ,rrd.orig_currency_code
				   ,rrd.orig_amount
				   ,rrd.division_code
				   ,rrd.division_name
				   ,rrd.department_code
				   ,rrd.department_name
				   ,rrd.remarks
				   ,@p_mod_date			
				   ,@p_mod_by			
				   ,@p_mod_ip_address	
				   ,@p_mod_date			
				   ,@p_mod_by			
				   ,@p_mod_ip_address	
			from	dbo.fin_interface_received_request_detail rrd
					inner join dbo.fin_interface_received_request rr on (rr.code = rrd.received_request_code)
			where	rr.code = @p_code

		update	dbo.fin_interface_received_request
		set		job_status = 'POST'
				,failed_remarks = null
		where	code = @p_code ;
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
