--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_status_pengajuan_birojasa
(
	@p_user_id			nvarchar(50) 
	,@p_branch_code		nvarchar(50) 
	,@p_branch_name		nvarchar(50) 
	,@p_asset_code		nvarchar(50) 
	,@p_item_name		nvarchar(50)
	,@p_is_condition	nvarchar(1)
)
as
BEGIN

	delete dbo.rpt_status_pengajuan_birojasa
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250) ;
			--,@branch_code					nvarchar(50)	
			--,@branch_name					nvarchar(50)	
			--,@asset_code					nvarchar(50)	
			--,@asset_description				nvarchar(50)	
			--,@plat_no						nvarchar(50)	
			--,@chassis_no					nvarchar(50)	
			--,@engine_no						nvarchar(50)	
			--,@document_type					nvarchar(50)	
			--,@doc_exp_date					nvarchar(50)	
			--,@rental_status					nvarchar(50)	
			--,@aging_days					int

	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Status Pengajuan Birojasa';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_status_pengajuan_birojasa
			(
				user_id
				,report_company
				,report_title
				,report_image
				,filter_asset_code
				,filter_asset_desc
				,filter_branch_name
				,branch_code
				,branch_name
				,asset_code
				,asset_description
				,plat_no
				,chassis_no
				,engine_no
				,document_type
				,doc_exp_date
				,rental_status
				,aging_days
				,IS_CONDITION

			)
			select  @p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_asset_code
					,@p_item_name
					,@p_branch_name
					,@p_branch_code					
					,ast.branch_name
					,ast.code
					,ast.item_name
					,avi.plat_no
					,avi.chassis_no
					,avi.engine_no
					,sgt.document_name
					,case sgt.document_name
							when 'STNK' then test1.exp_date
							when 'KEUR' then test2.EXP_DATE
							else NULL
					end 'doc_exp_date'
					,ast.rental_status
					,datediff(day,RMAIN.register_date,dbo.xfn_get_system_date()) 'aging'
					,@p_is_condition
			from	ifinams.dbo.asset ast
					inner join IFINAMS.dbo.REGISTER_MAIN rmain on rmain.fa_code = ast.CODE
					left join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
					left join IFINAMS.dbo.ASSET_DOCUMENT asd on asd.ASSET_CODE = ast.CODE
					left join IFINAMS.dbo.SYS_GENERAL_DOCUMENT SGT on asd.DOCUMENT_CODE = SGT.CODE
					outer apply 
					(
						SELECT	avi.STNK_EXPIRED_DATE 'exp_date' 
						from	ifinams.dbo.asset ast1
								left join ifinams.dbo.asset_vehicle avi1 on avi1.asset_code = ast1.code
								left join IFINAMS.dbo.ASSET_DOCUMENT asd1 on asd1.ASSET_CODE = ast1.CODE
								left join IFINAMS.dbo.SYS_GENERAL_DOCUMENT SGT1 on asd1.DOCUMENT_CODE = SGT1.CODE
						where	SGT1.DOCUMENT_NAME='STNK' and ast1.code = ast.code
					) test1
					outer apply 
					(
						SELECT	avi.KEUR_EXPIRED_DATE 'EXP_DATE'
						from	ifinams.dbo.asset ast1
								left join ifinams.dbo.asset_vehicle avi1 on avi1.asset_code = ast1.code
								left join IFINAMS.dbo.ASSET_DOCUMENT asd1 on asd1.ASSET_CODE = ast1.CODE
								left join IFINAMS.dbo.SYS_GENERAL_DOCUMENT SGT1 on asd1.DOCUMENT_CODE = SGT1.CODE
						where	SGT1.DOCUMENT_NAME='KEUR' and ast1.code = ast.code
					) test2
			where	ast.branch_code = case @p_branch_code
										when 'ALL' then ast.branch_code
										else @p_branch_code
									end	
			and		ast.code	= case @p_asset_code
										when ' ALL' then ast.code
										else @p_asset_code
									end	
			and		rmain.register_status = 'ON PROCESS' ;

			if not exists (select * from dbo.rpt_status_pengajuan_birojasa where user_id = @p_user_id)
			begin
					insert into dbo.rpt_status_pengajuan_birojasa
					(
					    user_id
					    ,report_company
					    ,report_title
					    ,report_image
					    ,filter_asset_code
					    ,filter_asset_desc
						,filter_branch_name
					    ,branch_code
					    ,branch_name
					    ,asset_code
					    ,asset_description
					    ,plat_no
					    ,chassis_no
					    ,engine_no
					    ,document_type
					    ,doc_exp_date
					    ,rental_status
					    ,aging_days
						,is_condition
					)
					values
					(   
						@p_user_id
					    ,@report_company
					    ,@report_title
					    ,@report_image
					    ,@p_asset_code
					    ,@p_item_name
					    ,@p_branch_code
						,@p_branch_name
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,NULL
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

