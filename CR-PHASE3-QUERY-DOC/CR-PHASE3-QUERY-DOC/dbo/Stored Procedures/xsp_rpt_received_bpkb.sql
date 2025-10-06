--created by, Bilal at 30/06/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_received_bpkb]
(
	@p_user_id			  nvarchar(max)
	,@p_branch_code		  nvarchar(50)
	,@p_branch_name		  nvarchar(50)
	,@p_from_date		  datetime
	,@p_to_date			  datetime
    ,@p_is_condition	  nvarchar(1) --(+) Untuk Kondisi Excel Data Only
    --
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin

	delete dbo.rpt_received_bpkb
	where user_id = @p_user_id

	delete dbo.rpt_received_bpkb_detail
	where user_id = @p_user_id

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@branch				nvarchar(250)
		    ,@agreement_no			nvarchar(50)
		    ,@client_name			nvarchar(250)
		    ,@seq					int				= 1
		    ,@bpkb_no				nvarchar(50)
		    ,@chasis_no				nvarchar(50)
		    ,@engine_no				nvarchar(50)
		    ,@plat_no				nvarchar(50)
		    ,@return_date			datetime
		    ,@update_by				nvarchar(50)
		    ,@product				nvarchar(250)
		    ,@branch_name			nvarchar(250)
		    ,@total_agreement		int
		    ,@total_unit			int
			,@filter_branch_name	nvarchar(250)
			--
			,@cre_date				datetime		= getdate()
			,@cre_ip_address		nvarchar(15)	= ''
			,@report_title_total	nvarchar(250)

	begin try

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set	@report_title = 'Report Received BPKB Borrow' ;
		set	@report_title_total = 'Total Report Received BPKB Borrow' ;

		select	@filter_branch_name = name 
		from	ifinsys.dbo.sys_branch 
		where	code = @p_branch_code
		
		insert into dbo.rpt_received_bpkb
		(
		    user_id
		    ,filter_branch_code
			,filter_branch_name
		    ,filter_from_date
		    ,filter_to_date
		    ,report_company
		    ,report_title
		    ,report_image
		    ,branch
		    ,agreement_no
		    ,client_name
		    ,seq
		    ,bpkb_no
		    ,chasis_no
		    ,engine_no
		    ,plat_no
		    ,return_date
		    ,update_by
			,is_condition
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		select   
				@p_user_id
				,@p_branch_code
				,@p_branch_name
				,@p_from_date
				,@p_to_date
				,@report_company
				,@report_title
				,@report_image
				,ass.branch_name
				,ass.agreement_external_no
				,ass.client_name
				,'1' -- tidak ada informasi seq number
					--case	
					--	when ass.agreement_no = '' then @seq
					--	when ass.agreement_no is null then @seq
					--	when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) > 1 and ass.agreement_no is null then @seq
					--	when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) > 1 and ass.agreement_no = '' then @seq
					--	when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) > 1 and ass.agreement_no is not null then cast(@seq as int) + (row_number() over(partition by ass.agreement_no order by ass.agreement_no) - 1)
					--	when (row_number() over(partition by ass.agreement_no order by ass.agreement_no)) = 0 then @seq
					--	else @seq
					--end
				,av.bpkb_no
				,av.chassis_no
				,av.engine_no
				,av.plat_no
				,dm.mutation_return_date
				,dhs.MOVEMENT_BY
				,@p_is_condition
				--
				,@cre_date		
				,@p_user_id			
				,@cre_ip_address	
				,@cre_date		
				,@p_user_id		
				,@cre_ip_address
		from	dbo.document_main dm
				inner join dbo.document_history dhs on (dhs.document_code = dm.code)
				inner join ifinams.dbo.asset ass on (dm.asset_no = ass.code)
				inner join ifinams.dbo.asset_vehicle av on dm.asset_no = av.asset_code
		where	dhs.movement_type = 'RECEIVED'
		AND		movement_location IN ('BRANCH', 'BORROW CLIENT', 'THIRD PARTY','DEPARTMENT')
		and		dm.document_type = 'BPKB'
		and		dm.branch_code = case @p_branch_code
									when 'ALL' then dm.branch_code
									else @p_branch_code
								end	
		and		cast(dhs.movement_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date);


		insert into dbo.rpt_received_bpkb_detail
		(
		    user_id
		   ,product
		   ,branch_name
		   ,total_agreement
		   ,total_unit
		)
		select	distinct
				@p_user_id
				,'OPERATING LEASE'
				,ass.branch_name
				,count(isnull(ass.agreement_no, '1')) 
				,count(ass.code) 
		from	dbo.document_main dm
				inner join dbo.DOCUMENT_HISTORY dhs ON (dhs.DOCUMENT_CODE = dm.CODE)
				inner join ifinams.dbo.asset ass on (dm.asset_no = ass.code)
				inner join ifinams.dbo.asset_vehicle av on dm.asset_no = av.asset_code
		where	dhs.movement_type = 'RECEIVED'
		AND		movement_location IN ('BRANCH', 'BORROW CLIENT', 'THIRD PARTY','DEPARTMENT')
		and		dm.document_type = 'BPKB'
		and		dm.branch_code = case @p_branch_code
									when 'ALL' then dm.branch_code
									else @p_branch_code
								end	
		and		cast(dhs.movement_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		group by ass.branch_name;

		if not exists (select * from dbo.rpt_received_bpkb where user_id = @p_user_id)
		begin
				insert into dbo.rpt_received_bpkb
				(
				    user_id
				    ,filter_branch_code
				    ,filter_branch_name
				    ,filter_from_date
				    ,filter_to_date
				    ,report_company
				    ,report_title
				    ,report_image
				    ,branch
				    ,agreement_no
				    ,client_name
				    ,seq
				    ,bpkb_no
				    ,chasis_no
				    ,engine_no
				    ,plat_no
				    ,return_date
				    ,update_by
					,is_condition
				    ,cre_date
				    ,cre_by
				    ,cre_ip_address
				    ,mod_date
				    ,mod_by
				    ,mod_ip_address
				)
				values
				(   
					@p_user_id
				    ,@p_branch_code
				    ,@p_branch_name
				    ,@p_from_date
				    ,@p_to_date
				    ,@report_company
				    ,@report_title
				    ,@report_image
				    ,''
				    ,''
				    ,''
				    ,null
				    ,''
				    ,''
				    ,''
				    ,''
				    ,null
				    ,''
					,@p_is_condition
				    ,@p_cre_date		
					,@p_cre_by			
					,@p_cre_ip_address	
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address	
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
END

