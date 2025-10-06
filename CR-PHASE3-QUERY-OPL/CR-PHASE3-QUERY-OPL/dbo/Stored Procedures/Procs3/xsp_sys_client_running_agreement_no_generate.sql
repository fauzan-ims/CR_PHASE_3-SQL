CREATE PROCEDURE dbo.xsp_sys_client_running_agreement_no_generate
(
	@p_client_code		 nvarchar(50)
	,@p_branch_code		 nvarchar(50)
	,@p_application_type nvarchar(50)
	,@p_agreement_no	 nvarchar(50) output
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg				  nvarchar(max)
			,@year				  nvarchar(2)
			,@month				  nvarchar(2)
			,@branch_code		  nvarchar(50)
			,@running_client_code nvarchar(50)
			,@running_client_no	  nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

	begin try
		if exists
		(
			select	1
			from	sys_client_running_agreement_no
			where	client_code		= @p_client_code
					and branch_code = @p_branch_code
		)
		begin
			select	@branch_code = branch_code
					,@running_client_code = running_client_code
					,@running_client_no = replace(str(cast(running_client_no as int) + 1, 3, 0), ' ', '0')
			from	sys_client_running_agreement_no
			where	client_code		= @p_client_code
					and branch_code = @p_branch_code ;

			if (@p_application_type = 'APPLICATION')
			begin
				set @p_agreement_no = @branch_code + '.MAGROPL.' +@year+@month+ '.' + @running_client_code+ '.' + (@running_client_no) ;
			end
			else
			begin
				set @p_agreement_no = @branch_code + '.AGROPL.' +@year+@month+ '.' + @running_client_code+ '.' + (@running_client_no) ;
			end

			update	sys_client_running_agreement_no
			set		running_client_no = @running_client_no
			where	client_code		= @p_client_code
					and branch_code = @p_branch_code ;
		end ;
		else
		begin
			select	@running_client_code = isnull(replace(str(cast(max(running_client_code) as int) + 1, 7, 0), ' ', '0'), @year + @month + '001')
			from	sys_client_running_agreement_no
			where	branch_code = @p_branch_code

			insert into dbo.sys_client_running_agreement_no
			(
				client_code
				,branch_code
				,running_client_code
				,running_client_no
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_client_code
				,@p_branch_code
				,@running_client_code
				,'001'
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
			)  
			if (@p_application_type = 'APPLICATION')
			begin
				set @p_agreement_no = @p_branch_code + '.MAGROPL.' + @year + @month + '.' + @running_client_code + '.' + ('001') ;
			end ;
			else
			begin
				set @p_agreement_no = @p_branch_code + '.AGROPL.' + @year + @month + '.' + @running_client_code + '.' + ('001') ;
			end ;
		end ;
	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch ;
end




