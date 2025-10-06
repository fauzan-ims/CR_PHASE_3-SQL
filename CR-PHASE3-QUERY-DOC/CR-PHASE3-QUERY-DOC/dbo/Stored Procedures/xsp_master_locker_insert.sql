CREATE PROCEDURE dbo.xsp_master_locker_insert
(
	@p_code			   nvarchar(50)  
	,@p_locker_name	   nvarchar(4000)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(4000)
	,@p_is_active	   nvarchar(1)
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
	declare @msg nvarchar(max) 
			,@rows_count int = 0;

	select	@rows_count = count(1)
	from	master_drawer
	where	is_active = '1'
	and		locker_code = @p_code ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try

		if exists (select 1 from master_locker where locker_name = @p_locker_name)
		begin
			SET @msg = 'Name already exist';
    		raiserror(@msg, 16, -1) ;
		end;

		insert into master_locker
		(
			code
			,locker_name
			,branch_code
			,branch_name
			,is_active
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	upper(@p_code)
			,upper(@p_locker_name)
			,@p_branch_code
			,@p_branch_name
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @p_code ;
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
