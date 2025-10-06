CREATE PROCEDURE [dbo].[xsp_master_user_main_getrows_all_role]
	@p_cre_by nvarchar(15)
as
begin
	create table #temp
	(
		role_code nvarchar(50) COLLATE Latin1_General_CI_AS
	) ;

	declare @role_code nvarchar(50) ;

	--get main role from group
	begin
		declare c_role cursor local fast_forward for

		select	grd.role_code 
		from	dbo.sys_company_user_main_group_sec umgs 
				inner join dbo.sys_role_group_detail grd on (grd.role_group_code = umgs.role_group_code collate Latin1_General_CI_AS) 
		where	umgs.user_code = @p_cre_by ;


		open c_role ;

		fetch c_role
		into @role_code ;

		while @@fetch_status = 0
		begin
			insert into #temp
			values (@role_code) ;

			fetch c_role
			into @role_code ;
		end ;

		close c_role ;
		deallocate c_role ;
	end ;


	select	*
	from	#temp ;

	drop table #temp ;
end ;
