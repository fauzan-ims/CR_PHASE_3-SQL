CREATE PROCEDURE dbo.xsp_insurance_register_existing_asset_insert
(
	--@p_id				   bigint = 0 output
	@p_register_code	   nvarchar(50)
	,@p_fa_code			   nvarchar(50)
	,@p_sum_insured_amount decimal(18, 2)	= 0
	,@p_coverage_code	   nvarchar(50)		= ''
	,@p_premi_sell_amount  decimal(18, 2)	= 0
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into insurance_register_existing_asset
		(
			register_code
			,fa_code
			,sum_insured_amount
			,coverage_code
			,premi_sell_amount
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
			@p_register_code
			,@p_fa_code
			,@p_sum_insured_amount
			,@p_coverage_code
			,@p_premi_sell_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		--set @p_id = @@identity ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
