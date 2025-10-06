CREATE PROCEDURE dbo.xsp_reconcile_transaction_upload
(
	@p_id					   bigint = 0 output
	,@p_reconcile_code		   nvarchar(50) 
	,@p_transaction_source	   nvarchar(250) 
	,@p_transaction_no		   nvarchar(250) 
	,@p_transaction_reff_no	   nvarchar(250) = ''
	,@p_transaction_value_date datetime 
	,@p_transaction_amount	   decimal(18, 2) = 0
	,@p_remark				   nvarchar(4000) = ''
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@remark	nvarchar(4000)

	begin try
		set @remark = isnull(@p_transaction_source,'') + ' - ' + isnull(@p_transaction_no,'') + ' - ' + isnull(@p_transaction_reff_no,'')
		insert into reconcile_transaction
		(
			reconcile_code
			,transaction_source
			,transaction_no
			,transaction_reff_no
			,transaction_value_date
			,transaction_amount
			,is_system
			,is_reconcile
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
		(	@p_reconcile_code
			,@p_transaction_source
			,@p_transaction_no
			,@p_transaction_reff_no
			,@p_transaction_value_date
			,@p_transaction_amount
			,0
			,0
			,@remark
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
