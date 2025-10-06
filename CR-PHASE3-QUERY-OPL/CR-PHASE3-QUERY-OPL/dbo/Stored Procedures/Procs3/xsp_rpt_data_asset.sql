--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_data_asset
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50)
	,@p_as_of_date		datetime	
	,@p_is_condition	nvarchar(1)
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

	begin

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
			)
			values
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@p_branch_code
				,@p_branch_name
				,@p_as_of_date		
				,@status_asset	
				,@total_data	
				,@p_is_condition	
			)

			if not exists (select 1 from dbo.rpt_data_asset where user_id = @p_user_id)
			begin
					
					insert into dbo.rpt_data_asset
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
					)
					values
					(   
						@p_user_id
					    ,@report_company
					    ,@report_title
					    ,@report_image
					    ,@p_branch_code
					    ,@p_branch_name
					    ,@p_as_of_date
					    ,''
					    ,null
						,@p_is_condition
					)

			end
	end
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

