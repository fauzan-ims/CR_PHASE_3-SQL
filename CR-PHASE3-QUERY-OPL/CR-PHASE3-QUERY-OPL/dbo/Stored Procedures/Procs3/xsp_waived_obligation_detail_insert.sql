CREATE PROCEDURE [dbo].[xsp_waived_obligation_detail_insert]
(
	@p_id					   bigint = 0 output
	,@p_waived_obligation_code nvarchar(50)
	,@p_invoice_no			   nvarchar(50)
	,@p_obligation_type		   nvarchar(10)
	,@p_obligation_name		   nvarchar(250)
	,@p_installment_no		   int
	,@p_obligation_amount	   decimal(18, 2)
	,@p_waived_amount		   decimal(18, 2)
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
	declare @msg nvarchar(max) ;

	begin TRY

		insert into waived_obligation_detail
		(
			waived_obligation_code
			,invoice_no
			,obligation_type
			,obligation_name
			,installment_no
			,obligation_amount
			,waived_amount
			,ASSET_NO
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_waived_obligation_code
			,case when @p_obligation_type <> 'LRAP' then @p_invoice_no else '-' end
			,@p_obligation_type
			,@p_obligation_name
			,@p_installment_no
			,@p_obligation_amount
			,@p_waived_amount
			,case when @p_obligation_type = 'LRAP' then @p_invoice_no else '-' end 			
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		update dbo.agreement_asset_late_return
		set		waive_no		= @p_waived_obligation_code
				,waive_amount	= 0
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	asset_no = @p_invoice_no

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
