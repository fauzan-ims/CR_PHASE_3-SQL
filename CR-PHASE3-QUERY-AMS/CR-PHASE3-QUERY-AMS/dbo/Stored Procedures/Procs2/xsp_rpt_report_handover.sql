--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_handover
(
	@p_user_id			nvarchar(50) = ''
	,@p_branch_code		NVARCHAR(50) = ''
	,@p_from_date		datetime		= null
	,@p_to_date			datetime		= null
)
as
BEGIN

	delete dbo.rpt_report_handover
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
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'PHYSICAL UNIT CHECKING FORM';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_handover
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
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

			)
			select	@p_user_id
					,@report_company
					,@report_title	
					,@report_image	
					,ha.branch_code
					,ha.branch_name
					,ha.code
					,ha.type
					,ha.fa_code
					,av.type_item_name
					,av.plat_no
					,av.chassis_no
					,av.engine_no
					,ha.handover_date
					,ha.handover_from
					,ha.handover_to
					,ha.handover_address
					,ha.remark
					,ha.status
			from dbo.handover_asset ha
			left join dbo.asset ass on (ass.code = ha.code)
			left join dbo.asset_vehicle av on (av.asset_code = ass.code)
			where ha.branch_code = @p_branch_code
			and  cast(ha.handover_date as date)between cast(@p_from_date as date) and cast(@p_to_date as date)
			
			--VALUES
			--(
			--	@p_user_id
			--	,@report_company				
			--	,@report_title
			--	,@report_image
			--	,@branch_code			
			--	,@branch_name			
			--	,@handover_code		
			--	,@type				
			--	,@asset_no			
			--	,@asset_description	
			--	,@plat_no			
			--	,@chassis_no		
			--	,@engine_no			
			--	,@handover_date		
			--	,@handover_from		
			--	,@handover_to		
			--	,@handover_address	
			--	,@remarks			
			--	,@status			
			--)
		
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

