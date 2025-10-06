--created by, Bilal at 30/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_additional_collateral
(
	@p_user_id			nvarchar(max)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_is_condition	nvarchar(1) --(+) untuk kondisi excel data only
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin

	delete dbo.rpt_additional_collateral
	where user_id = @p_user_id 

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@agreement_no			nvarchar(50)
		    ,@branch_name			nvarchar(250)
		    ,@client_name			nvarchar(250)
		    ,@date					datetime
		    ,@received_date			datetime
		    ,@document_name			nvarchar(50)
		    ,@document_no			nvarchar(50)
		    ,@remark				nvarchar(250)

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		set	@report_title = 'Report Additional Collateral'

		insert into dbo.rpt_additional_collateral
		(
		    user_id
		    ,filter_branch_code
			,filter_branch_name
		    ,report_company
		    ,report_title
		    ,report_image
		    ,agreement_no
		    ,branch_name
		    ,client_name
		    ,date
		    ,received_date
		    ,document_name
		    ,document_no
		    ,remark
			,is_condition
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		 
		SELECT	@p_user_id
				,@p_branch_code
				,@p_branch_name
				,@report_company
				,@report_title
				,@report_image
				,aa.agreement_external_no
				,aa.branch_name
				,aa.client_name
				,dm.mutation_date
				,dm.mutation_return_date
				,dm.document_type
				,dp.cover_note_no
				,dh.remarks
				,@p_is_condition
				--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address
		from	dbo.document_main dm 
				inner join ifinams.dbo.asset aa on (aa.code = dm.asset_no)
				--inner join  dbo.fixed_asset_main fam on (fam.asset_no=dm.asset_no)
				inner join dbo.document_pending dp on (dp.ASSET_NO = dm.ASSET_NO and dp.DOCUMENT_TYPE = dm.DOCUMENT_TYPE)
				outer apply (select top 1 remarks 
							from dbo.document_history 
							where dm.code=document_code and mod_date in (select max(doch.mod_date) from dbo.document_history doch where dm.code=document_code)
							)dh
		where	dm.mutation_type ='BORROW'
		and		dm.mutation_location = 'BORROW CLIENT'
	


		if not exists (select * from dbo.rpt_additional_collateral where user_id = @p_user_id)
		begin
				
				insert into dbo.rpt_additional_collateral
				(
					user_id
					,filter_branch_code
					,filter_branch_name
					,report_company
					,report_title
					,report_image
					,agreement_no
					,branch_name
					,client_name
					,date
					,received_date
					,document_name
					,document_no
					,remark
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
					,@report_company
					,@report_title
					,@report_image
					,''
					,''
					,''
					,NULL
					,NULL
					,''
					,''
					,''
					,@p_is_condition
					--
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
