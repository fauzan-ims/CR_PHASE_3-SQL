CREATE PROCEDURE [dbo].[xsp_rpt_received_existing]
(
	@p_user_id				nvarchar(50) 
	,@p_branch_code			nvarchar(50) 
	,@p_branch_name			nvarchar(250)
	,@p_as_of_date			datetime  
	,@p_is_condition		nvarchar(1) --(+) Untuk Kondisi Excel Data Only   
)
as
begin

	delete dbo.rpt_received_existing
	where	user_id = @p_user_id;

	declare @msg				 nvarchar(max)
			,@report_company	 nvarchar(250)
			,@report_title		 nvarchar(250)
			,@report_image		 nvarchar(250)
			,@agreement_no		 nvarchar(50)
			,@branch_name		 nvarchar(250)
			,@client_name		 nvarchar(250)
			,@seq				 int			= 1
			,@bpkb_no			 nvarchar(50)
			,@chasis_no			 nvarchar(50)
			,@engine_no			 nvarchar(50)
			,@plat_no			 nvarchar(50)
			,@return_date		 datetime
			,@update_by			 nvarchar(50)
			--
			,@cre_date			datetime		= getdate()
			,@cre_ip_address	nvarchar(15)	= ''

	begin try
	
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'REPORT RECEIVED (EXISTING)';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

	begin

			insert into dbo.rpt_received_existing
			(
			    user_id
			    ,filter_branch_code
				,filter_branch_name
			    ,filter_as_of_date
			    ,report_company
			    ,report_title
			    ,report_image
			    ,agreement_no
			    ,branch_name
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
			select --distinct
				@p_user_id
				,@p_branch_code
				,@p_branch_name
				,@p_as_of_date
				,@report_company
				,@report_title
				,@report_image
				,ass.agreement_external_no
				 --case
                 --   when isnull(ass.agreement_no, '') = '' then amast.agreement_no
                 --   else ass.agreement_no
                 --END
				,ass.branch_name
                ,case
                    when isnull(ass.client_name, '') = '' then am.client_name
                    else ass.client_name
                end
                ,1 -- tidak ada sequence
				,av.bpkb_no
				,av.chassis_no
				,av.engine_no
				,av.plat_no
				,dh.movement_date
				,dh.movement_by
				,@p_is_condition
				--
				,@cre_date		
				,@p_user_id			
				,@cre_ip_address	
				,@cre_date		
				,@p_user_id		
				,@cre_ip_address
		from	dbo.document_main dm
				inner join document_history dh on dh.document_code = dm.code
				inner join ifinams.dbo.asset ass on (ass.code = dm.asset_no) 
				inner join ifinams.dbo.asset_vehicle av on (av.asset_code = ass.code) 
                left join ifinopl.dbo.agreement_asset amast with (nolock) on (amast.fa_code = ass.code)
                left join ifinopl.dbo.agreement_main am with (nolock) on (am.agreement_no = amast.agreement_no)
		where	dh.MOVEMENT_TYPE= 'RECEIVED'
		and		ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end	 
        and		cast(dh.movement_date as date)<= cast(@p_as_of_date as date)
		
		 
			if not exists (select 1 from dbo.rpt_received_existing where user_id = @p_user_id)
			begin
	  		
				insert into dbo.rpt_received_existing
				(
				    user_id
				   ,filter_branch_code
				   ,filter_branch_name
				   ,filter_as_of_date
				   ,report_company
				   ,report_title
				   ,report_image
				   ,agreement_no
				   ,branch_name
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
					,''
					,''
					,''
					,''
					,''
					,null
					,''
					,@p_is_condition
					--
					,getdate()
					,@p_user_id
					,''
					,getdate()
					,@p_user_id
					,''
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

