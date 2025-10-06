CREATE PROCEDURE dbo.xsp_sys_menu_insert
(
	@p_code				 nvarchar(50)  OUTPUT
	,@p_name			 nvarchar(250)
	,@p_abbreviation	 nvarchar(50)  = ''
	,@p_module_code		 nvarchar(50)  = ''
	,@p_parent_menu_code nvarchar(50)  = ''
	,@p_url_menu		 nvarchar(200) = ''
	,@p_order_key		 nvarchar(200)
	,@p_css_icon		 nvarchar(250) = ''
	,@p_is_active		 nvarchar(1)
	,@p_type			 nvarchar(5)  = ''
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @rows_number as int
			,@menu_code as	nvarchar(50)
			,@msg			nvarchar(max) ;

	set @rows_number =
	(
		select	convert(int, substring(max(CODE), 2, 7)) + 1
		from	sys_menu
	) ;
	set @menu_code = convert(nvarchar(10), (
											   select	substring('0000000', len(@rows_number), len('0000000') - len(@rows_number))
										   ) + convert(nvarchar(10), @rows_number)
							) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		insert into sys_menu
		(
			code
			,name
			,abbreviation
			,module_code
			,parent_menu_code
			,url_menu
			,order_key
			,css_icon
			,is_active
			,type
			--				
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	'M' + @menu_code
			,upper(@p_name)
			,@p_abbreviation
			,@p_module_code
			,@p_parent_menu_code
			,@p_url_menu
			,@p_order_key
			,@p_css_icon
			,@p_is_active
			,@p_type
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = 'M' + @menu_code;

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
