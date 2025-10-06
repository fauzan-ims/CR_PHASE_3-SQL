/*
exec dbo.xsp_due_date_change_update_amortization @p_code = N'' -- nvarchar(50)
												 ,@p_asset_no = N'' -- nvarchar(50)
												 ,@p_mod_date = '2023-07-07 11.36.49' -- datetime
												 ,@p_mod_by = N'' -- nvarchar(15)
												 ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Jumat, 07 Juli 2023 18.36.39 -- 
CREATE PROCEDURE dbo.xsp_due_date_change_update_amortization
(
	@p_code			   nvarchar(50)
	,@p_asset_no	   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_billing_no	   int
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try 
		delete dbo.agreement_asset_amortization
		where	agreement_no   = @p_agreement_no
				and asset_no   = @p_asset_no
				and billing_no >= @p_billing_no ; 

		insert into dbo.agreement_asset_amortization
		(
			agreement_no
			,billing_no
			,asset_no
			,due_date
			,billing_date
			,billing_amount
			,description
			,invoice_no
			,generate_code
			,hold_billing_status
			,hold_date
			,reff_code
			,reff_remark
			,reff_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_agreement_no
				,installment_no
				,asset_no
				,due_date
				,billing_date
				,billing_amount
				,description
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.due_date_change_amortization_history
		where	due_date_change_code = @p_code
				and asset_no		 = @p_asset_no
				and installment_no	 >= @p_billing_no 
				and old_or_new		= 'NEW' 
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
