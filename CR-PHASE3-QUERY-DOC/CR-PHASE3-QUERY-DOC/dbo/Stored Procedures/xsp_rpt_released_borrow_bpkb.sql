--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_released_borrow_bpkb
(
   @p_user_id			nvarchar(50) 
   ,@p_branch_code		nvarchar(50) 
   ,@p_branch_name		nvarchar(250) 
   ,@p_as_of_date		datetime	
   ,@p_is_condition		nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
AS
BEGIN
   DELETE rpt_released_borrow_bpkb
   WHERE  USER_ID = @p_user_id ;

   DECLARE
      @msg              NVARCHAR(MAX)
      ,@report_company  NVARCHAR(250)
      ,@report_title    NVARCHAR(250)
      ,@report_image    NVARCHAR(250)
      ,@branch_code     NVARCHAR(50)
      ,@branch_name     NVARCHAR(50)
      ,@agreement_no    NVARCHAR(50)
      ,@client_name     NVARCHAR(50)
      ,@seq             INT
      ,@merk            NVARCHAR(50)
      ,@model           NVARCHAR(50)
      ,@type            NVARCHAR(50)
      ,@chassis_no      NVARCHAR(50)
      ,@engine_no       NVARCHAR(50)
      ,@bpkb_no         NVARCHAR(50)
      ,@year            NVARCHAR(50)
      ,@plat_no         NVARCHAR(50)
      ,@faktur          NVARCHAR(50)
      ,@kwitansi        NVARCHAR(50)
      ,@registered_name NVARCHAR(50)
      ,@reason          nvarchar(50)
      ,@borrowed_date   datetime
      ,@returned_date   datetime
      ,@respons_person  nvarchar(50)
      ,@mo              nvarchar(50) ;

   begin try
      select
            @report_company = VALUE
      from  dbo.SYS_GLOBAL_PARAM
      where CODE = 'COMP2' ;

      set @report_title = N'Report Released Borrow BPKB' ;

      select
            @report_image = VALUE
      from  dbo.SYS_GLOBAL_PARAM
      where CODE = 'IMGDSF' ;

      begin
         insert into rpt_released_borrow_bpkb
         (
            user_id
            ,report_company
            ,report_title
            ,report_image
			,filter_branch_name
            ,branch_code
            ,branch_name
            ,as_of_date
            ,agreement_no
            ,client_name
            ,seq
            ,merk
            ,model
            ,type
            ,chassis_no
            ,engine_no
            ,bpkb_no
            ,year
            ,plat_no
            ,faktur
            ,kwitansi
            ,registered_name
            ,reason
            ,borrowed_date
            ,returned_date
            ,respons_person
            ,mo
			,is_condition
         )
                     select @p_user_id
                           ,@report_company
                           ,@report_title
                           ,@report_image
						   ,@p_branch_name
                           ,@p_branch_code
                           ,dm.branch_name
                           ,@p_as_of_date
						   ,ass.agreement_external_no
                           --,case
                           --    when isnull(ass.agreement_no, '') = '' then amast.agreement_no
                           --    else ass.agreement_no
                           -- end
                           ,case
                               when isnull(ass.client_name, '') = '' then am.client_name
                               else ass.client_name
                            end
                           ,row_number() over (partition by
                                                  ass.agreement_no
                                               order by ass.agreement_no
                                              ) as row_num
                           ,av.merk_name
                           ,av.model_name
                           ,av.type_item_name
                           ,dmfam.reff_no_2 
							--case
                            --   when dmd.document_code is null then dpfam.reff_no_2
                            --   else dmfam.reff_no_2
                            --end                 'reff_no_2'
                           ,dmfam.reff_no_3
							--case
                            --   when dmd.document_code is null then dpfam.reff_no_3
                            --   else dmfam.reff_no_3
                            --end                 'reff_no_3'
                           ,av.bpkb_no
                           ,case
                               when isnull(av.built_year, '') = '' then amast.asset_year
                               else av.built_year
                            end
                           ,case ass.type_code
                               when 'vhcl' then av.plat_no
                               else ''
                            end
                           ,dmfam.reff_no_2 
						   ,dmfam.reff_no_3 
                           ,av.stnk_name             -- nama yang tertera di bpkb
                           ,dmv.movement_remarks     -- borrow reason
                           ,dmv.movement_date
                           ,dmv.estimate_return_date
                           ,dmv.movement_by_emp_name -- pic peminjam bpkb
                           ,am.marketing_name        -- marketing officer (mo)
						   ,@p_is_condition
                     from  dbo.document_main                      dm with (nolock)
                           inner join ifinams.dbo.asset            ass with (nolock) on (dm.asset_no              = ass.code)
                           inner join dbo.fixed_asset_main         dmfam with (nolock) on (dmfam.asset_no         = dm.asset_no)
                           inner join ifinams.dbo.asset_vehicle    av with (nolock) on (av.asset_code             = ass.code)
                           left join ifinopl.dbo.agreement_main   am with (nolock) on am.agreement_no            = ass.agreement_no
                           left join ifinopl.dbo.agreement_asset  amast with (nolock) on amast.fa_code           = ass.code and amast.agreement_no = ass.agreement_no
                           --left join dbo.document_movement_detail dmd with (nolock) on (dmd.document_code        = dm.code and dm.flag_borrow = dm.document_status)
						   left join dbo.document_movement_detail dmd with (nolock) on (dmd.document_code        = dm.code)
                           left join dbo.document_movement dmv with (nolock) on (dmv.code = dmd.MOVEMENT_CODE)
                     where dm.branch_code                      = case @p_branch_code
                                                                    when 'all' then dm.branch_code
                                                                    else @p_branch_code
                                                                 end
						   and dm.document_type = 'BPKB'
						   and dm.document_status = 'ON BORROW'
						   and cast(isnull(dmv.movement_date,'1900-01-01') as date) <= cast(@p_as_of_date as date) ;
                           --and (
                           --       isnull(ass.agreement_no, '') <> ''
                           --       or amast.agreement_no        <> ''
                           --    )
                           --and dmv.movement_status in
                           --    (
                           --       'ON TRANSIT', 'POST'
                           --    )
      end ;

	  if not exists (select * from dbo.rpt_released_borrow_bpkb where user_id = @p_user_id)
	  begin
	  		
			insert into dbo.rpt_released_borrow_bpkb
			(
			    user_id
			    ,report_company
			    ,report_title
			    ,report_image
				,filter_branch_name
			    ,branch_code
			    ,branch_name
			    ,as_of_date
			    ,agreement_no
			    ,client_name
			    ,seq
			    ,merk
			    ,model
			    ,type
			    ,chassis_no
			    ,engine_no
			    ,bpkb_no
			    ,year
			    ,plat_no
			    ,faktur
			    ,kwitansi
			    ,registered_name
			    ,reason
			    ,borrowed_date
			    ,returned_date
			    ,respons_person
			    ,mo
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
			    ,''
			    ,@p_as_of_date
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
			    ,''
			    ,''
			    ,''
			    ,''
			    ,''
			    ,null
			    ,null
			    ,''
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
         set @msg = N'V' + N';' + @msg ;
      end ;
      else
      begin
         set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
      end ;

      raiserror(@msg, 16, -1) ;

      return ;
   end catch ;
end ;
