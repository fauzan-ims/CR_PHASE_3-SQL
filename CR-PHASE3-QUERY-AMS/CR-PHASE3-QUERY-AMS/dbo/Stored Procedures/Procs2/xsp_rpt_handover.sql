--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_handover
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50)
	,@p_from_date		datetime
	,@p_to_date			datetime
    ,@p_is_condition	nvarchar(1)
)
as
BEGIN

	delete dbo.rpt_handover
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)	
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(50)
			,@handover_code					nvarchar(50)
			,@type							nvarchar(50)
			,@asset_no						nvarchar(50)
			,@asset_description				nvarchar(100)
			,@plat_no						nvarchar(50)
			,@chassis_no					nvarchar(50)
			,@engine_no						nvarchar(50)
			,@handover_date					datetime
			,@handover_from					nvarchar(50)
			,@handover_to					nvarchar(50)
			,@handover_address				nvarchar(500)
			,@remarks						nvarchar(4000)
			,@status						nvarchar(50)
	
	begin try
	
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'Report Handover';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

	BEGIN

			insert into rpt_handover
			(
				user_id
				,report_company
				,report_title
				,report_image
				,filter_branch_name
				,branch_code
				,branch_name
				,from_date
				,to_date
				,handover_code
				,type
				,asset_no
				,asset_description
				,plat_no
				,chassis_no
				,engine_no
				,handover_date
				,handover_from
				,handover_to
				,handover_address
				,remarks
				,status
				,is_condition

			)
			select
				@p_user_id		--user_id
				,@report_company				--	,report_company
				,@report_title				--	,report_title
				,@report_image				--	,report_image
				,@p_branch_name
				,@p_branch_code				--	,branch_code
				,ha.branch_name				--	,branch_name
				,@p_from_date				--	,from_date
				,@p_to_date				--	,to_date
				,ha.code				--	,handover_code
				,ha.type				--	,type
				,ast.code				--	,asset_no
				,ast.item_name		--	,asset_description
				,avh.plat_no				--	,plat_no
				,avh.chassis_no				--	,chassis_no
				,avh.engine_no				--	,engine_no
				,ha.handover_date				--	,handover_date
				,ha.handover_from				--	,handover_from
				,ha.handover_to				--	,handover_to
				,ha.handover_address				--	,handover_address
				,ha.remark				--	,remarks
				,ha.status				--	,status
				,@p_is_condition
				from dbo.handover_asset ha
				inner join dbo.asset ast on ast.code=ha.fa_code
				left join dbo.asset_vehicle avh on avh.asset_code = ast.code
				where ast.branch_code = case @p_branch_code
									when 'ALL' then ast.branch_code
									else @p_branch_code
								end	
				and  ha.status IN ('POST','HOLD')
				and  cast(ha.handover_date as date)between cast(@p_from_date as date) and cast(@p_to_date as date)
	end
    
	if not exists (select * from dbo.rpt_handover where user_id = @p_user_id)
	begin

				insert into dbo.rpt_handover
				(
				    user_id
				    ,report_company
				    ,report_title
				    ,report_image
				    ,filter_branch_name
				    ,branch_code
				    ,branch_name
				    ,from_date
				    ,to_date
				    ,handover_code
				    ,type
				    ,asset_no
				    ,asset_description
				    ,plat_no
				    ,chassis_no
				    ,engine_no
				    ,handover_date
				    ,handover_from
				    ,handover_to
				    ,handover_address
				    ,remarks
				    ,status
				    ,is_condition
				)
				values
				(   
					@p_user_id
				    ,@report_company
				    ,@report_title	
				    ,@report_image	
				    ,@p_branch_name
				    ,@p_branch_code
				    ,null
				    ,@p_from_date
				    ,@p_to_date
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,@p_is_condition
				)
        end
	end try
	BEGIN catch
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

