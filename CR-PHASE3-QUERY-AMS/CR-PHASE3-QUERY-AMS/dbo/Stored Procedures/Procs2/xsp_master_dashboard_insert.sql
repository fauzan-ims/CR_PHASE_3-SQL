CREATE PROCEDURE dbo.xsp_master_dashboard_insert
(
	@p_code			   nvarchar(50)
	,@p_dashboard_name nvarchar(250)
	,@p_dashboard_type nvarchar(20)
	,@p_dashboard_grid nvarchar(50)
	,@p_sp_name		   nvarchar(250)
	,@p_is_active	   nvarchar(1)
	,@p_is_editable	   nvarchar(1)
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
	declare @msg nvarchar(max) ;

	-- data tidak boleh sama
	if exists
	(
		select	code
		from	dbo.master_dashboard
		where	code = @p_code
	)
	begin
		raiserror('Code Master Dashboard Is Already Exist', 16, -2) ;

		return ;
	end ;
	else if exists
	(
		select	code
		from	dbo.master_dashboard
		where	dashboard_name = @p_dashboard_name
	)
	begin
		raiserror('Name Master Dashboard Is Already Exist', 16, -2) ;

		return ;
	end ;
	else if exists
	(
		select	code
		from	dbo.master_dashboard
		where	sp_name = @p_sp_name
	)
	begin
		raiserror('Api Name Master Dashboard Is Already Exist', 16, -2) ;

		return ;
	end ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	if @p_is_editable = 'T'
		set @p_is_editable = '1' ;
	else
		set @p_is_editable = '0' ;

	begin try
		insert into master_dashboard
		(
			code
			,dashboard_name
			,dashboard_type
			,dashboard_grid
			,sp_name
			,is_active
			,is_editable
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
			,@p_dashboard_name
			,@p_dashboard_type
			,@p_dashboard_grid
			,@p_sp_name
			,@p_is_active
			,@p_is_editable
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
