--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_return_of_loan_bpkb]
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50)
	,@p_as_of_date		datetime	
	,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
BEGIN

	delete rpt_return_of_loan_bpkb
	where	user_id = @p_user_id;

	delete dbo.rpt_return_of_loan_bpkb_summary
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(50)
			,@agreement_no					nvarchar(50)	
			,@client_name					nvarchar(50)	
			,@seq							nvarchar(50)	= '1'	
			,@bpkb_no						nvarchar(50)	
			,@chassis_no					nvarchar(50)	
			,@engine_no						nvarchar(50)	
			,@plat_no						nvarchar(50)	
			,@return_date					datetime		
			,@update_by						nvarchar(50)	
			,@report_title_total			nvarchar(250)

	begin try
	
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'Report Return of Loan BPKB';
		set	@report_title_total = 'Total Report Return of Loan BPKB';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

	begin

			insert into rpt_return_of_loan_bpkb
			(
				user_id
				,filter_branch_code
				,filter_branch_name
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,as_of_date
				,agreement_no	
				,client_name	
				,seq			
				,bpkb_no		
				,chassis_no	
				,engine_no		
				,plat_no		
				,return_date	
				,update_by		
				,is_condition			
			)
			select	@p_user_id
					,@p_branch_code
					,@p_branch_name
					,@report_company
					,@report_title
					,@report_image
					,ass.branch_code
					,ass.branch_name
					,@p_as_of_date
					,ass.agreement_external_no
					,ass.client_name
					--,''--seq
					-- Trisna 10-Jul-2023(+) ====
					,case	
						when ass.agreement_no = '' then @seq
						when ass.agreement_no is null then @seq
						when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) > 1 and ass.agreement_no is null then @seq
						when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) > 1 and ass.agreement_no = '' then @seq
						when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) > 1 and ass.agreement_no is not null then cast(@seq as int) + (row_number() over(partition by ass.agreement_no order by ass.agreement_no) - 1)
						when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) = 0 then @seq
						else @seq
					end
					,av.bpkb_no
					,case
						 when dmd.document_code is null then dpfam.reff_no_2
						 else dmfam.reff_no_2
					end 'reff_no_2'
					,case
						 when dmd.document_code is null then dpfam.reff_no_3
						 else dmfam.reff_no_3
					end 'reff_no_3'
					,case ass.type_code
						when 'VHCL' then av.plat_no
						else ''
					end
					,dmv.movement_date
					,dmv.movement_by_emp_name
					,@p_is_condition
			from	dbo.document_movement dmv
					inner join dbo.document_movement_detail dmd on (dmv.code = dmd.movement_code)
					left join dbo.document_main dm on (dm.code = dmd.document_code)
					inner join ifinams.dbo.asset ass on (ass.code = dm.asset_no) 
					left join dbo.document_pending dp on (dmd.document_pending_code = dp.code)
					left join dbo.fixed_asset_main dpfam on (dpfam.asset_no			= dp.asset_no)
					left join ifinams.dbo.asset_vehicle av on (av.asset_code = ass.code) 
					left join dbo.fixed_asset_main dmfam on (dmfam.asset_no			= dm.asset_no)
					outer apply (
								select count(agreement_no) 'count'
								from ifinams.dbo.asset ast
								where ast.branch_code = ass.branch_code
								) oaast
					outer apply (
								select count(code) 'count'
								from ifinams.dbo.asset ast
								where ast.agreement_no = ass.agreement_no and ast.branch_code = ass.branch_code
								) oaasd
			
			where	ass.branch_code = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end	
					and dm.document_status = 'ON BORROW'
					and dmv.movement_date <= @p_as_of_date
			
			insert into dbo.rpt_return_of_loan_bpkb_summary
			(
			    user_id
			   ,report_company
			   ,report_title
			   ,report_image
			   ,branch_code
			   ,branch_name
			   ,product
			   ,total_agreement
			   ,total_unit
			)
			select	distinct
					@p_user_id
					,@report_company
					,@report_title_total
					,@report_image
					,ass.branch_code
					,ass.branch_name
					,'OPERATING LEASE'
					,count(agreement_no) --oaast.count) -- Trisna 10-Jul-2023(+) ====
					,count(ass.code) --oaasd.count) -- Trisna 10-Jul-2023(+) ====
			from	dbo.document_movement dmv
					inner join dbo.document_movement_detail dmd on (dmv.code = dmd.movement_code)
					left join dbo.document_main dm on (dm.code = dmd.document_code)
					inner join ifinams.dbo.asset ass on (ass.code = dm.asset_no) 
					left join dbo.document_pending dp on (dmd.document_pending_code = dp.code)
					left join dbo.fixed_asset_main dpfam on (dpfam.asset_no			= dp.asset_no)
					left join ifinams.dbo.asset_vehicle av on (av.asset_code = ass.code) 
					left join dbo.fixed_asset_main dmfam on (dmfam.asset_no			= dm.asset_no)
					outer apply (
								select count(agreement_no) 'count'
								from ifinams.dbo.asset ast
								where ast.branch_code = ass.branch_code
								) oaast
					outer apply (
								select count(code) 'count'
								from ifinams.dbo.asset ast
								where ast.agreement_no = ass.agreement_no and ast.branch_code = ass.branch_code
								) oaasd
			
			where	ass.branch_code = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end	
					and dm.document_status = 'ON BORROW'
					and dmv.movement_date <= @p_as_of_date
			group by ass.branch_code
					,ass.branch_name
			/*
			from	dbo.document_movement dmv
					inner join dbo.document_movement_detail dmd on (dmv.code = dmd.movement_code)
					left join dbo.document_main dm on (dm.code = dmd.document_code)
					left join ifinams.dbo.asset ass on (ass.code = dm.asset_no) 
					outer apply (
								select count(agreement_no) 'count'
								from ifinams.dbo.asset ast
								where ast.branch_code = ass.branch_code
								) oaast
					outer apply (
								select count(code) 'count'
								from ifinams.dbo.asset ast
								where ast.agreement_no = ass.agreement_no and ast.branch_code = ass.branch_code
								) oaasd
			where	ass.branch_code = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end	
			*/

	END
    
	if not exists (select * from dbo.rpt_return_of_loan_bpkb where user_id = @p_user_id)
	begin
				
			insert into dbo.rpt_return_of_loan_bpkb
			(
			    user_id
			    ,filter_branch_code
				,filter_branch_name
			    ,report_company
			    ,report_title
			    ,report_image
			    ,branch_code
			    ,branch_name
			    ,as_of_date
			    ,agreement_no
			    ,client_name
			    ,seq
			    ,bpkb_no
			    ,chassis_no
			    ,engine_no
			    ,plat_no
			    ,return_date
			    ,update_by
				,is_condition
			)
			values
			(   
				@p_user_id
				,@p_branch_code
				,@p_branch_name
				,@report_company
				,@report_title
				,@report_image
				,@p_branch_code
			    ,''
			    ,@p_as_of_date
			    ,''
			    ,''
			    ,''
			    ,''
			    ,''
			    ,''
			    ,''
			    ,null
			    ,''
				,@p_is_condition
			)
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


