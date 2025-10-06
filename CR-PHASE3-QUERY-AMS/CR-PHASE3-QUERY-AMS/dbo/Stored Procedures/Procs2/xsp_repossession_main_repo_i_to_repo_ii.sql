create PROCEDURE dbo.xsp_repossession_main_repo_i_to_repo_ii
as
declare @msg		   nvarchar(max)
		,@id_interface nvarchar(50)
		,@agreement_no nvarchar(50) ;

begin try
	declare curr_repossession_main cursor for
	select		code
				,agreement_no
	from		dbo.repossession_main
	where		repossession_status					   = 'REPO I'
				and cast(estimate_repoii_date as date) = cast(dbo.xfn_get_system_date() as date)
	order by	code asc offset 0 rows fetch next 10 rows only ;

	open curr_repossession_main ;

	fetch next from curr_repossession_main
	into @id_interface
		 ,@agreement_no ;

	while @@fetch_status = 0
	begin
		update	dbo.repossession_main
		set		repossession_status				= 'REPO II'
				,estimate_repoii_date			= null
				,repossession_status_process	= ''
		where	code							= @id_interface ;

		update	dbo.agreement_main
		set		repossession_status				= 'REPO II'
		where	agreement_no					= @agreement_no ;

		insert into dbo.rep_interface_agreement_update_out
		(
			agreement_no
			,agreement_status
			,agreement_sub_status
			,termination_date
			,termination_status
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	agreement_no
				,''--'LUNAS'
				,''--'INVENTORY'
				,getdate()
				,''--'INVENTORY'
				,getdate()
				,'job'
				,'127.0.0.1'
				,getdate()
				,'job'
				,'127.0.0.1'
		from	dbo.agreement_main
		where	agreement_no = @agreement_no ;

		fetch next from curr_repossession_main
		into @id_interface
			 ,@agreement_no ;
	end ;

	close curr_repossession_main ;
	deallocate curr_repossession_main ;
end try
begin catch
	if (len(@msg) <> 0)
	begin
		set @msg = 'V' + ';' + @msg ;
	end ;
	else
	begin
		set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
	end ;

	raiserror(@msg, 16, -1) ;

	return ;
end catch ;
