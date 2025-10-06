
CREATE procedure dbo.xsp_ifinproc_new_asset_insert
(
	@p_id				  bigint
	,@p_asset_code		  nvarchar(50)
	,@p_purchase_price	  decimal(18, 2)
	,@p_orig_amount		  decimal(18, 2)
	,@p_type			  nvarchar(50)
	,@p_posting_date	  datetime = null
	,@p_return_date		  datetime = null
	,@p_invoice_date_type nvarchar(50)
	,@p_invoice_code	  nvarchar(50)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		insert into dbo.ifinproc_new_asset
		(
			asset_code
			,purchase_price
			,orig_amount
			,type
			,posting_date
			,return_date
			,invoice_date_type
			,invoice_code
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
			@p_asset_code
			,@p_purchase_price
			,@p_orig_amount
			,@p_type
			,@p_posting_date
			,@p_return_date
			,@p_invoice_date_type
			,@p_invoice_code
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
