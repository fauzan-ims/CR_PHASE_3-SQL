--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_data_asset]
(
	@p_user_id			nvarchar(50) 
	,@p_branch_code		nvarchar(50) 
	,@p_branch_name		nvarchar(50) 
	,@p_as_of_date		datetime	 
	,@p_is_condition	nvarchar(1)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
BEGIN

	delete dbo.rpt_data_asset
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@status_asset					nvarchar(50)	
			,@total_data					int				
			
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Data Asset';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		--declare c_asset cursor for
		--select	distinct ag.status
		--from	dbo.asset_aging ag
		--		left join dbo.asset ass on (ass.code = ag.code)
		--where	ass.branch_code = case @p_branch_code
		--								when 'ALL' then ass.BRANCH_CODE
		--								else @p_branch_code
		--							end 
		--		and  cast(ag.aging_date as date) = @p_as_of_date ;

		--open	c_asset

		--fetch	c_asset
		--into	@status_asset

		--while @@fetch_status = 0
		--begin

		--	select	@total_data = count(ag.code)
		--	from	dbo.asset_aging ag
		--			left join dbo.asset ass on (ass.code = ag.code)
		--	where	ag.status			= @status_asset
		--			and ass.branch_code = case @p_branch_code
		--								when 'ALL' then ass.BRANCH_CODE
		--								else @p_branch_code
		--							end 

			insert into rpt_data_asset
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,as_of_date		
				,status_asset	
				,total_data		
				,is_condition
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select		@p_user_id
						,@report_company
						,@report_title
						,@report_image
						,@p_branch_code
						,@p_branch_name
						,@p_as_of_date
						,status
						,count(code)
						,''
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
			from		ifinams.dbo.asset
			where		branch_code = case @p_branch_code
										  when 'ALL' then branch_code
										  else @p_branch_code
									  end
			and			purchase_date <= @p_as_of_date
			group by	status 
			order by	status asc;

			--fetch	c_asset
			--into	@status_asset

		--end

		--close		c_asset
		--deallocate	c_asset

		--if not exists (select * from dbo.rpt_data_asset where user_id = @p_user_id)
		--begin
		--		insert into dbo.rpt_data_asset
		--		(
		--		    user_id
		--		    ,report_company
		--		    ,report_title
		--		    ,report_image
		--		    ,branch_code
		--		    ,branch_name
		--		    ,as_of_date
		--		    ,status_asset
		--		    ,total_data
		--		    ,is_condition
		--		    ,cre_date
		--		    ,cre_by
		--		    ,cre_ip_address
		--		    ,mod_date
		--		    ,mod_by
		--		    ,mod_ip_address
		--		)
		--		values
		--		(   
		--			@p_user_id
		--		    ,@report_company
		--		    ,@report_title
		--		    ,@report_image
		--		    ,@p_branch_code
		--		    ,@p_branch_name
		--		    ,@p_as_of_date
		--		    ,null
		--		    ,null
		--		    ,null
		--		    ,@p_cre_date		
		--			,@p_cre_by			
		--			,@p_cre_ip_address	
		--			,@p_mod_date		
		--			,@p_mod_by			
		--			,@p_mod_ip_address
		--		)
		--end


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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

