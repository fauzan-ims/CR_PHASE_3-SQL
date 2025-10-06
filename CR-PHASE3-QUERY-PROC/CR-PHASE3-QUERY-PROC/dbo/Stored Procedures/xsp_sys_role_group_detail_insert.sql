CREATE PROCEDURE dbo.xsp_sys_role_group_detail_insert
(
	@p_id				bigint = 0 output
	,@p_role_group_code nvarchar(50)
	,@p_role_code		nvarchar(50)
	,@p_role_name		nvarchar(250)
	,@p_menu_code		nvarchar(50)	= ''
	,@p_menu_name		nvarchar(250)	= ''
	,@p_submenu_code	nvarchar(50)	= ''
	,@p_submenu_name	nvarchar(250)	= ''
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists(select 1 from dbo.sys_role_group_detail where role_group_code = @p_role_group_code and role_code = @p_role_code and menu_code = @p_menu_code and submenu_code = @p_submenu_code)
		begin
			set @msg = 'role code '+@p_role_code+' role code '+@p_role_name+' is already used'

			raiserror(@msg, 16, -1) ;

			return ;
		end

		insert into sys_role_group_detail
		(
			role_group_code
			,role_code
			,role_name
			,menu_code
			,menu_name
			,submenu_code
			,submenu_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_role_group_code
			,@p_role_code
			,@p_role_name
			,@p_menu_code
			,@p_menu_name
			,@p_submenu_code
			,@p_submenu_name
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
