--created by, Bilal at 30/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_annual_report
(
	@p_user_id			nvarchar(max)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_as_of_date		datetime
	,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
begin

	delete dbo.rpt_annual_report
	where user_id = @p_user_id 

	delete dbo.rpt_annual_report_detail
	where user_id = @p_user_id

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@branch_name			nvarchar(250)
		    ,@agreement_no			nvarchar(50)
		    ,@client_name			nvarchar(250)
		    ,@seq					int
		    ,@merk					nvarchar(50)
		    ,@model					nvarchar(50)
		    ,@type					nvarchar(50)
		    ,@chasis_no				nvarchar(50)
		    ,@engine_no				nvarchar(50)
		    ,@bpkb_no				nvarchar(50)
		    ,@year					nvarchar(4)
		    ,@transaction_date		datetime
		    ,@registered_name		nvarchar(250)
		    ,@doc_type				nvarchar(50)
		    ,@plat_no				nvarchar(50)
		    ,@agreement_status		nvarchar(50)
		    ,@doc_location			nvarchar(50)
		    ,@product_name			nvarchar(250)
		    ,@reason				nvarchar(50)
		    ,@total					int
			--
			,@cre_date				datetime		= getdate()
			,@cre_ip_address		nvarchar(15)	= ''

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param 
		where	code = 'COMP2';

		set	@report_title = 'Report Annual'

		insert into dbo.rpt_annual_report
		(
		    user_id
		    ,filter_branch_code
			,filter_branch_name
		    ,filter_as_of_date
		    ,report_company
		    ,report_title
		    ,report_image
		    ,branch_name
		    ,agreement_no
		    ,client_name
		    ,seq
		    ,merk
		    ,model
		    ,type
		    ,chasis_no
		    ,engine_no
		    ,bpkb_no
		    ,year
		    ,transaction_date
		    ,registered_name
		    ,doc_type
		    ,plat_no
		    ,agreement_status
		    ,doc_location
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
				,@p_as_of_date
                ,@report_company
                ,@report_title
                ,@report_image
                ,dm.branch_name
                ,ass.agreement_external_no
				--CASE
                 --   WHEN ISNULL(ass.agreement_no, '') = '' THEN amast.agreement_no
                 --   ELSE ass.agreement_no
				 --end
                ,ass.client_name
				--case
				 --  when isnull(ass.client_name, '') = '' then am.client_name
				 --  else ass.client_name
				 --END
                ,''--row_number() over (partition by
					--                       ass.agreement_no
					--                   order by ass.agreement_no
					--                   ) as row_num
                ,av.merk_name
                ,av.model_name
                ,av.type_item_name
                ,av.chassis_no 
                ,av.engine_no
                ,av.bpkb_no
                ,av.built_year
				--case
                 --   when isnull(av.built_year, '') = '' then amast.ASSET_YEAR
                 --   else av.built_year
                 --end
                ,ass.invoice_date
                ,av.stnk_name             -- nama yang tertera di bpkb
                ,dm.document_type
                ,av.plat_no
                ,am.agreement_status
                ,amast.bbn_location_description
				,@p_is_condition
				--
				,@cre_date		
				,@p_user_id			
				,@cre_ip_address	
				,@cre_date		
				,@p_user_id		
				,@cre_ip_address
        from	dbo.document_main                      dm with (nolock)
                left join ifinams.dbo.asset            ass with (nolock) on (dm.asset_no              = ass.code)
                left join ifinams.dbo.asset_vehicle    av with (nolock) on (av.asset_code             = ass.code)
                left join ifinopl.dbo.agreement_asset  amast with (nolock) on (amast.fa_code           = ass.code and amast.agreement_no = ass.agreement_no)
                left join ifinopl.dbo.agreement_main   am with (nolock) on (am.agreement_no            = amast.agreement_no)
                --left join dbo.document_movement_detail dmd with (nolock) on (dmd.document_code        = dm.code)
                --left join dbo.fixed_asset_main         dmfam with (nolock) on (dmfam.asset_no         = dm.asset_no)
                --left join dbo.document_pending         dp with (nolock) on (dmd.document_pending_code = dp.code)
                --left join dbo.document_movement        dmv with (nolock) on (dmv.code                 = dmd.movement_code)
		where	dm.branch_code = case @p_branch_code
									when 'ALL' then dm.branch_code
									else @p_branch_code
								end	
        and		cast(isnull(dm.mutation_date,'1900-01-01') as date) <= cast(@p_as_of_date as date)
		and		dm.document_status <> 'RELEASE'
		--and		dm.branch_name = case @p_branch_name
		--							when 'ALL' then dm.branch_name
		--							else @p_branch_name
		--						end	
		--(dm.branch_code	= @p_branch_code or @p_branch_code = 'ALL')
		--and		(
		--			isnull(ass.agreement_no, '') <> ''
		--			or amast.agreement_no        <> ''
		--		)

		if not exists (select 1 from dbo.rpt_annual_report where user_id = @p_user_id)
		begin
				
				insert into dbo.rpt_annual_report
				(
					user_id
					,filter_branch_code
					,filter_branch_name
					,filter_as_of_date
					,report_company
					,report_title
					,report_image
					,branch_name
					,agreement_no
					,client_name
					,seq
					,merk
					,model
					,type
					,chasis_no
					,engine_no
					,bpkb_no
					,year
					,transaction_date
					,registered_name
					,doc_type
					,plat_no
					,agreement_status
					,doc_location
					,is_condition
					--
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
					,@p_as_of_date
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
					,''
					,''
					,''
					,null
					,''
					,''
					,'' 
					,''
					,'' 
					,@p_is_condition
					--
					,@cre_date		
					,@p_user_id			
					,@cre_ip_address	
					,@cre_date		
					,@p_user_id		
					,@cre_ip_address
				)
		end


		insert into dbo.rpt_annual_report_detail
		(
		    user_id
		   ,product
		   ,reason
		   ,total
		   ,total_agreement
		   ,total_unit
		)
		select
                @p_user_id
				,'OPERATING_ LEASE'
				,dmv.movement_remarks
				,count(ass.code)
				,count(ass.agreement_no)
				,count(ass.code)
         from	dbo.document_main                      dm with (nolock)
                left join ifinams.dbo.asset            ass with (nolock) on (dm.asset_no              = ass.code)
                left join ifinams.dbo.asset_vehicle    av with (nolock) on (av.asset_code             = ass.code)
                left join ifinopl.dbo.agreement_asset  amast with (nolock) on (amast.fa_code           = ass.code and amast.agreement_no = ass.agreement_no)
                left join ifinopl.dbo.agreement_main   am with (nolock) on (am.agreement_no            = amast.agreement_no)
                left join dbo.document_movement_detail dmd with (nolock) on (dmd.document_code        = dm.code)
                left join dbo.document_movement        dmv with (nolock) on (dmv.code                 = dmd.movement_code)
		where	dm.branch_code = case @p_branch_code
									when 'ALL' then dm.branch_code
									else @p_branch_code
								end	
        and		cast(isnull(dm.mutation_date,'1900-01-01') as date) <= cast(@p_as_of_date as date)
		and		dm.document_status <> 'RELEASE'
		group by dmv.movement_remarks;

		if not exists (select 1 from dbo.rpt_annual_report where user_id = @p_user_id)
		begin
		   insert into dbo.rpt_annual_report_detail
		   (
		       user_id
		      ,product
		      ,reason
		      ,total
			  ,total_agreement
			  ,total_unit
		   )
		   values
		   (   @p_user_id
		      ,''
		      ,''
		      ,null
			  ,0
			  ,0
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
