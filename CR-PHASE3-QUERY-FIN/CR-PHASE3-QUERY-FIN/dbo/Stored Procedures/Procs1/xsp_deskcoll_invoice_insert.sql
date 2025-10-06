create procedure [dbo].[xsp_deskcoll_invoice_insert]
(
	@p_id				  bigint = 0 output
	,@p_deskcoll_main_id  bigint
	,@p_invoice_no		  nvarchar(50)
	,@p_invoice_type	  nvarchar(10)
	,@p_ovd_days		  int
	,@p_billing_date	  datetime
	,@p_new_billing_date  datetime
	,@p_billing_due_date  datetime
	,@p_billing_amount	  decimal(18, 2)
	,@p_ppn_amount		  decimal(18, 2)
	,@p_pph_amount		  decimal(18, 2)
	,@p_os_billing_amount decimal(18, 2)
	,@p_os_ppn_amount	  decimal(18, 2)
	,@p_os_pph_amount	  decimal(18, 2)
	,@p_result_code		  nvarchar(50)
	,@p_remark			  nvarchar(4000)
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
		insert into dbo.deskcoll_invoice
		(
			deskcoll_main_id
			,invoice_no
			,invoice_type
			,ovd_days
			,billing_date
			,new_billing_date
			,billing_due_date
			,billing_amount
			,ppn_amount
			,pph_amount
			,os_billing_amount
			,os_ppn_amount
			,os_pph_amount
			,result_code
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
		(
			@p_deskcoll_main_id
			,@p_invoice_no
			,@p_invoice_type
			,@p_ovd_days
			,@p_billing_date
			,@p_new_billing_date
			,@p_billing_due_date
			,@p_billing_amount
			,@p_ppn_amount
			,@p_pph_amount
			,@p_os_billing_amount
			,@p_os_ppn_amount
			,@p_os_pph_amount
			,@p_result_code
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
