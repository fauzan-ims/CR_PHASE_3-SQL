CREATE PROCEDURE dbo.xsp_sys_role_sec_insert
(
	@p_code			   nvarchar(50) output
	,@p_name		   nvarchar(250)
	,@p_access_type	   nvarchar(1)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @rows_number int
			,@role_code	 nvarchar(10)
			,@msg		 nvarchar(max) ;

	set @rows_number =
	(
		select	count(1) + 1
		from	sys_role_sec
	) ;
	set @role_code = convert(nvarchar(10), (
											   select	substring('0000000', len(@rows_number), len('0000000') - len(@rows_number))
										   ) + convert(nvarchar(10), @rows_number)
							) ;
	set @role_code = 'R' + @role_code + @p_access_type;

	begin try
		insert into sys_role_sec
		(
			code
			,name
			,access_type
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@role_code
			,@p_name
			,@p_access_type
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @role_code;
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
