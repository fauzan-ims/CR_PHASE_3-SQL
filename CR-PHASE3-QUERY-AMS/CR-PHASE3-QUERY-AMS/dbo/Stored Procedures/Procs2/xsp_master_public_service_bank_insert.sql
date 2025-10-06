CREATE PROCEDURE dbo.xsp_master_public_service_bank_insert
(
	@p_id					bigint = 0 output
	,@p_public_service_code nvarchar(50)
	,@p_currency_code		nvarchar(3)
	,@p_bank_code			nvarchar(50)
	,@p_bank_name			nvarchar(250)
	,@p_bank_branch			nvarchar(250)
	,@p_bank_account_no		nvarchar(50)
	,@p_bank_account_name	nvarchar(250)
	,@p_is_default			nvarchar(1)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	begin TRY
		if exists(select 1 from dbo.master_public_service_bank where public_service_code = @p_public_service_code and bank_account_no = @p_bank_account_no)
		begin
			set @msg = 'Data already exist.';
			raiserror(@msg ,16,-1);
		end

		if @p_is_default = '1'
		begin
			update	dbo.master_public_service_bank
			set		is_default = 0
			where	public_service_code = @p_public_service_code
			and		is_default = 1
		end

		insert into master_public_service_bank
		(
			public_service_code
			,currency_code
			,bank_code
			,bank_name
			,bank_branch
			,bank_account_no
			,bank_account_name
			,is_default
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_public_service_code
			,@p_currency_code
			,@p_bank_code
			,@p_bank_name
			,upper(@p_bank_branch)
			,@p_bank_account_no
			,upper(@p_bank_account_name)
			,@p_is_default
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


