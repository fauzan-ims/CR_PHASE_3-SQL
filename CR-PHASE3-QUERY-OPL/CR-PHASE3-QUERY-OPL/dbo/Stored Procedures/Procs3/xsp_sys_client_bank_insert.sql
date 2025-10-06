CREATE PROCEDURE dbo.xsp_sys_client_bank_insert
(
	@p_code				   nvarchar(50)
	,@p_client_code		   nvarchar(50)
	,@p_currency_code	   nvarchar(3)
	,@p_bank_code		   nvarchar(50)
	,@p_bank_name		   nvarchar(100)
	,@p_bank_branch		   nvarchar(250)
	,@p_bank_account_no	   nvarchar(50)
	,@p_bank_account_name  nvarchar(250)
	,@p_is_default		   nvarchar(1)
	,@p_is_auto_debet_bank nvarchar(1)
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

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	if @p_is_auto_debet_bank = 'T'
		set @p_is_auto_debet_bank = '1' ;
	else
		set @p_is_auto_debet_bank = '0' ;

	begin try

		if exists (select 1 from sys_general_subcode_detail where code = @p_code)
		begin
    		SET @msg = 'Code already exist';
    		raiserror(@msg, 16, -1) ;
		end

		insert into sys_client_bank
		(
			code
			,client_code
			,currency_code
			,bank_code
			,bank_name
			,bank_branch
			,bank_account_no
			,bank_account_name
			,is_default
			,is_auto_debet_bank
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
			,@p_client_code
			,@p_currency_code
			,@p_bank_code
			,@p_bank_name
			,@p_bank_branch
			,@p_bank_account_no
			,@p_bank_account_name
			,@p_is_default
			,@p_is_auto_debet_bank
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

