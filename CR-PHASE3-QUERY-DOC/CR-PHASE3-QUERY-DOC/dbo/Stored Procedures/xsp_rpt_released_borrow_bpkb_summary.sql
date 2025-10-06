--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_released_borrow_bpkb_summary]
(
   @p_user_id      nvarchar(50) = ''
   ,@p_branch_code nvarchar(50) = ''
   ,@p_as_of_date  datetime     = null
)
as
begin
   delete dbo.rpt_released_borrow_bpkb_summary
   where  user_id = @p_user_id ;

   declare
      @msg             nvarchar(max)
      ,@report_company nvarchar(250)
      ,@report_title   nvarchar(250)
      ,@report_image   nvarchar(250)
      ,@branch_code    nvarchar(50)
      ,@branch_name    nvarchar(50)
      ,@product        nvarchar(50)
      ,@reason         nvarchar(50)
      ,@total          int ;

   begin try
      select
            @report_company = VALUE
      from  dbo.sys_global_param
      where CODE = 'COMP2' ;

      set @report_title = N'Report Released Borrow BPKB' ;

      select
            @report_image = VALUE
      from  dbo.SYS_GLOBAL_PARAM
      where CODE = 'IMGDSF' ;

      begin
         insert into dbo.RPT_RELEASED_BORROW_BPKB_SUMMARY
         (
            USER_ID
            ,REPORT_COMPANY
            ,REPORT_TITLE
            ,REPORT_IMAGE
            ,BRANCH_CODE
            ,BRANCH_NAME
            ,PRODUCT
            ,REASON
            ,TOTAL
         )
                     select
                           distinct
                           @p_user_id
                           ,@report_company
                           ,@report_title
                           ,@report_image
                           ,rptbrw.BRANCH_CODE
                           ,rptbrw.BRANCH_NAME
                           ,'OPERATING LEASE' -- confirm pak Hari produk hanya 1 yaitu OPL
                           ,rptbrw.REASON
                           ,cnt.REASON
                     from  dbo.RPT_RELEASED_BORROW_BPKB rptbrw with (nolock)
                           outer apply (
                                          select
                                                count(isnull(rptbrwou.REASON, '')) REASON
                                          from  rpt_released_borrow_bpkb rptbrwou with (nolock)
                                          where rptbrwou.USER_ID    = rptbrw.USER_ID
                                                and rptbrwou.REASON = rptbrw.REASON
                                       )                cnt
                     where user_id = @p_user_id;
      end ;
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
