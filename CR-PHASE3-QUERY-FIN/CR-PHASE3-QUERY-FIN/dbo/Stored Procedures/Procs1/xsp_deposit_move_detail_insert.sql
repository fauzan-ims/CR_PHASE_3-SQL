CREATE PROCEDURE [dbo].[xsp_deposit_move_detail_insert]
(
	@p_to_agreement_no	  nvarchar(50)
	,@p_deposit_move_code nvarchar(50)
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
		insert into dbo.deposit_move_detail
		(
			to_agreement_no
			,deposit_move_code
			,to_deposit_type_code
			,to_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_to_agreement_no
			,@p_deposit_move_code
			,'INSTALLMENT'
			,0
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	begin catch
		declare @error int = @@error ;

		if @error = 2627
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		else if @error = 547
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;

		if len(@msg) <> 0
			set @msg = N'V;' + @msg ;
		else if error_message() like '%V;%'
				or	error_message() like '%E;%'
			set @msg = error_message() ;
		else
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
