CREATE PROCEDURE dbo.xsp_billing_generate_detail_insert
(
	@p_id						bigint	= 0 output
	,@p_generate_code			nvarchar(50)
	,@p_agreement_no			nvarchar(50)
	,@p_asset_no				nvarchar(50)
	,@p_billing_no				int
	,@p_due_date				datetime
	,@p_billing_date			datetime
	,@p_rental_amount			decimal(18, 2)
	,@p_description				nvarchar(4000)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

	insert into billing_generate_detail
	(
		generate_code
		,agreement_no
		,asset_no
		,billing_no
		,due_date
		,billing_date
		,rental_amount
		,description
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
		@p_generate_code
		,@p_agreement_no
		,@p_asset_no
		,@p_billing_no
		,@p_due_date
		,@p_billing_date
		,@p_rental_amount
		,@p_description
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)

	set @p_id = @@IDENTITY

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
