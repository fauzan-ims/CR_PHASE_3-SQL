--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_pending_cover_note
(
	@p_user_id			nvarchar(50) = ''
	,@p_branch_code		nvarchar(50) = ''
	,@p_branch_name		nvarchar(50) = ''
	,@p_supplier_code	nvarchar(50) = ''
	,@p_supplier_name	nvarchar(50) = ''
	,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
BEGIN

	delete rpt_pending_cover_note
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(50)
			,@supplier_name					nvarchar(50)	
			,@overdue_days					int				
			,@unit							int						
			,@cover_note_no					nvarchar(50)	
			,@cover_note_exp_date			datetime		
			,@system_date					date = cast(dbo.xfn_get_system_date() as date) ;

	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Pending Cover Note';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_pending_cover_note
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,supplier_name			
				,overdue_days			
				,unit							
				,cover_note_no			
				,cover_note_exp_date
				,filter_supplier		
				,is_condition	
			)
			select @p_user_id
					,@report_company
					,@report_title
					,@report_image
					,dp.branch_code
					,dp.branch_name
					,fam.vendor_name
					,datediff(day,dp.entry_date, dbo.xfn_get_system_date())
					,asset_main.id
					--,asset_main2.id
					,dp.cover_note_no
					,dp.cover_note_exp_date
					--,dm.receive_remark
					,@p_supplier_name
					,@p_is_condition
			from dbo.document_pending dp
			left join dbo.fixed_asset_main fam on (fam.asset_no = dp.asset_no)
			outer apply (select count(1) 'id' from dbo.fixed_asset_main fam where fam.asset_no = dp.asset_no) asset_main
			--outer apply (select count(1) 'id' from dbo.fixed_asset_main fam where fam.asset_no = dp.asset_no and dp.document_status = 'HOLD') asset_main2
			inner join dbo.document_movement_detail dmd on  (dmd.document_pending_code = dp.code)
			inner join dbo.document_movement dm on (dm.code = dmd.movement_code)
			where dp.document_type = 'COVERNOTE'
			and dp.DOCUMENT_status = 'HOLD'
			--and dm.movement_status in
			--(
			--	'HOLD', 'ON PROCESS', 'ON TRANSIT'
			--)
			group by fam.vendor_name
					,dp.branch_code
					,dp.branch_name
					,datediff(day, dp.entry_date, dbo.xfn_get_system_date())
					,asset_main.id
					--,asset_main2.id
					,dp.cover_note_no
					,dp.cover_note_exp_date
					,dm.receive_remark

			--select	@p_user_id
			--		,@report_company
			--		,@report_title
			--		,@report_image
			--		,@p_branch_code
			--		,@p_branch_name
			--		,mv.name
			--		,datediff(day,rr.cover_note_exp_date,@system_date)
			--		,rr.count_asset
			--		,rr.cover_note_no
			--		,rr.cover_note_exp_date
			--		,@p_supplier_name
			--		,@p_is_condition
			--from	dbo.replacement_request  rr
			--		left join dbo.replacement rp on(rp.code = rr.cover_note_no)
			--		left join ifinbam.dbo.master_vendor mv on (mv.code = rr.vendor_code)
			--where	rr.status = 'HOLD'
			--and		rr.branch_code = case @p_branch_code
			--						when 'ALL' then rr.branch_code
			--						else @p_branch_code
			--					end	
			--and		mv.NAME = @p_supplier_name

			if not exists (select * from dbo.rpt_pending_cover_note where user_id = @p_user_id)
			begin
				
					insert into dbo.rpt_pending_cover_note
					(
					    user_id
					    ,report_company
					    ,report_title
					    ,report_image
					    ,branch_code
					    ,branch_name
					    ,supplier_name
					    ,overdue_days
					    ,unit
					    ,cover_note_no
					    ,cover_note_exp_date
					    ,filter_supplier
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
					    ,@p_supplier_name
					    ,null
					    ,null
					    ,''
					    ,null
					    ,@p_supplier_name
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

