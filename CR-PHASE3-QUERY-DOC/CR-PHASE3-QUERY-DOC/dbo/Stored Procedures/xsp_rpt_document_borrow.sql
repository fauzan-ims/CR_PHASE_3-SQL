CREATE PROCEDURE dbo.xsp_rpt_document_borrow
(
	@p_user_id				nvarchar(50)
    ,@p_from_date			datetime
    ,@p_to_date				datetime
    ,@p_branch_code			nvarchar(50)
    ,@p_branch_name			nvarchar(250)
	,@p_is_condition		nvarchar(1) --(+) Untuk Kondisi Excel Data Only
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin 
		delete	dbo.rpt_document_borrow
		where	user_id = @p_user_id

		declare @report_company			nvarchar(250)
				,@report_title			nvarchar(250)
				,@report_image			nvarchar(250)
				--
				,@filter_branch_name	nvarchar(50)
				,@branch_code			nvarchar(50)
				,@branch_name			nvarchar(250)
				,@asset_no			nvarchar(50)
				,@asset_name			nvarchar(250)
				,@document_name			nvarchar(250)
				,@borrow_date			datetime
				,@entimate_return_date  datetime
				,@borrow_by				nvarchar(250)
				,@borrow_name			nvarchar(250)
				,@aging_date			int
				--
				,@datetimenow			datetime
                ,@report_code			nvarchar(50)

		set	@report_title = 'Report Document Borrow'

		set @datetimeNow = getdate();

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		/* declare main cursor */
		declare c_document_borrow cursor local fast_forward read_only for 
		select	isnull(dm.branch_name,'-')	
				,isnull(dm.branch_code,'-')
				,isnull(dm.branch_name,'-')
				,isnull(dm.asset_no,'-')
				,isnull(dm.asset_name,'-')
				,isnull(dcd.document_name,'-')
				,dm.mutation_date
				,dm.mutation_return_date
				,isnull(dm.mutation_location,'-')
				,isnull(dm.mutation_by,'-')
		from	dbo.document_main dm with(nolock)
				left join dbo.document_detail dcd with(nolock) on (dcd.document_code = dm.code) 
		where	cast(dm.mutation_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		and		dm.branch_code = case @p_branch_code
									when 'ALL' then dm.branch_code
									else @p_branch_code
								end	
		and		dm.document_status = 'ON BORROW' 

		/* fetch record */
		open	c_document_borrow
		fetch	c_document_borrow
		into	@filter_branch_name
				,@branch_code		
				,@branch_name		
				,@asset_no			
				,@asset_name			
				,@document_name			
				,@borrow_date							
				,@entimate_return_date  	
				,@borrow_by					
				,@borrow_name									
																	
		while @@fetch_status = 0
		begin 
				set @aging_date = datediff(day, @entimate_return_date, dbo.xfn_get_system_date()) --DATEDIFF (day, @entimate_return_date, @datetimenow)

				/* insert into table report */
				insert into dbo.rpt_document_borrow
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_branch_code 
				          ,filter_branch_name 
				          ,filter_from_date 
				          ,filter_to_date 
				          ,branch_code 
				          ,branch_name 
				          ,asset_no 
				          ,asset_name 
				          ,document_name 
				          ,borrow_date 
				          ,entimate_return_date 
				          ,borrow_by 
				          ,borrow_name 
				          ,aging_date 
						  ,is_condition
				          ,cre_date 
				          ,cre_by 
				          ,cre_ip_address 
				          ,mod_date 
				          ,mod_by 
				          ,mod_ip_address
				        )
				values  ( 
						  @p_user_id
				          ,@report_company
				          ,@report_title 
				          ,@report_image 
				          ,@p_branch_code
				          ,@p_branch_name
				          ,@p_from_date
				          ,@p_to_date
				          ,@branch_code 
				          ,@branch_name 
				          ,@asset_no
				          ,@asset_name 
				          ,@document_name
				          ,@borrow_date
				          ,@entimate_return_date
				          ,@borrow_by
				          ,@borrow_name
				          ,isnull(@aging_date,0)
						  ,@p_is_condition
				          ,@p_cre_date
						  ,@p_cre_by
						  ,@p_cre_ip_address
						  ,@p_mod_date		
						  ,@p_mod_by									 
						  ,@p_mod_ip_address
				        )

		/* fetch record berikutnya */
		fetch	c_document_borrow
		into	@filter_branch_name
				,@branch_code		
				,@branch_name		
				,@asset_no			
				,@asset_name			
				,@document_name		
				,@borrow_date							
				,@entimate_return_date  	
				,@borrow_by					
				,@borrow_name			
								
		end		
		
		/* tutup cursor */
		close		c_document_borrow
		deallocate	c_document_borrow

		if not exists (select * from dbo.rpt_document_borrow where user_id = @p_user_id)
		begin
               
			   insert into dbo.rpt_document_borrow
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_branch_code 
				          ,filter_branch_name 
				          ,filter_from_date 
				          ,filter_to_date 
				          ,branch_code 
				          ,branch_name 
				          ,asset_no 
				          ,asset_name 
				          ,document_name 
				          ,borrow_date 
				          ,entimate_return_date 
				          ,borrow_by 
				          ,borrow_name 
				          ,aging_date 
						  ,is_condition
				          ,cre_date 
				          ,cre_by 
				          ,cre_ip_address 
				          ,mod_date 
				          ,mod_by 
				          ,mod_ip_address
				        )
				values  ( 
						  @p_user_id
				          ,@report_company
				          ,@report_title 
				          ,@report_image 
				          ,@p_branch_code
				          ,@p_branch_name
				          ,@p_from_date
				          ,@p_to_date
				          ,'' 
				          ,'' 
				          ,'none'
				          ,'' 
				          ,''
				          ,null
				          ,null
				          ,''
				          ,''
				          ,0
						  ,@p_is_condition
				          ,@p_cre_date
						  ,@p_cre_by
						  ,@p_cre_ip_address
						  ,@p_mod_date		
						  ,@p_mod_by									 
						  ,@p_mod_ip_address
				        )

		end
end
