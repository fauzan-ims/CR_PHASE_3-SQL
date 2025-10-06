CREATE PROCEDURE dbo.xsp_master_transaction_insert
(
	@p_code							nvarchar(50)
	,@p_transaction_name			nvarchar(250)
	,@p_module_name					nvarchar(250) 
	,@p_is_active					nvarchar(1)
	,@p_is_calculated				nvarchar(1)
	,@p_gl_link_code				nvarchar(50)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	if @p_is_calculated = 'T'
		set @p_is_calculated = '1' ;
	else
		set @p_is_calculated = '0' ;

	begin TRY
		
		if exists (select 1 from master_transaction where transaction_name = @p_transaction_name)
		begin
			set @msg = 'Name already exist';
			raiserror(@msg, 16, -1) ;
		END
        
		insert into dbo.master_transaction
		(
		    code,
		    transaction_name,
		    module_name,
		    is_calculated,
		    is_active,
			gl_link_code,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(	
			upper(@p_code)
			,upper(@p_transaction_name)
			,@p_module_name
			,@p_is_active
			,@p_is_calculated
			,@p_gl_link_code
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


