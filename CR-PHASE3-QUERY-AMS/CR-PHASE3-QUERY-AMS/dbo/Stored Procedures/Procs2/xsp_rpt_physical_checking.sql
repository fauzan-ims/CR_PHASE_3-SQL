--Created, Aliv at 26-05-2023
CREATE PROCEDURE dbo.xsp_rpt_physical_checking
(
	@p_user_id			nvarchar(50)
	,@p_from_date		datetime 
	,@p_to_date			datetime
	,@p_is_condition	nvarchar(1)
)
as
begin

	delete dbo.rpt_physical_checking
	where	user_id = @p_user_id ;

	declare @msg				nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_title		nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_address	nvarchar(250)
			,@code				nvarchar(50)	
			,@ex_agreement_no	nvarchar(50)	
			,@status_unit		nvarchar(50)	
			,@status_pemakaian	nvarchar(50)	
			,@leased_object		nvarchar(50)	
			,@year				int

	begin try
											
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'Report Physical Checking';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select @report_address = value 
		from	dbo.sys_global_param
		where	code = 'COMADD2';

		insert into dbo.rpt_physical_checking
		(
			user_id
			,report_company
			,report_title
			,report_image
			,report_address
			,from_date
			,to_date
			,code				
			,ex_agreement_no	
			,status_unit		
			,status_pemakaian	
			,leased_object		
			,year				
			,chasis_no
			,plat_no
			,physical_check_location
			,date
			,pic
			,condition
			,is_condition
		)
		select @p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@report_address
				,@p_from_date
				,@p_to_date
				,ass.code
				,isnull(ass.agreement_external_no, ex_agreement.ex_agreement_no)
				,ass.status
				,case rental_status
					when '' then 'FREE'
					when null then 'FREE'
					else rental_status
				end 'rental_status'
				,item_name
				,avh.built_year
				,avh.chassis_no
				,avh.plat_no
				,opnd.location_name
				,opnd.date
				,opnm.pic_name
				,opnd.condition_code
				,@p_is_condition
		from dbo.asset ass
		left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		inner join dbo.opname_detail opnd on (opnd.asset_code = ass.code)
		left join dbo.opname opnm on (opnm.code = opnd.opname_code)
		outer apply (
			select		top 1
						ama.agreement_external_no 'ex_agreement_no'
			from		ifinopl.dbo.agreement_asset aast
						inner join ifinopl.dbo.agreement_main ama on ama.AGREEMENT_NO = aast.AGREEMENT_NO
			where		aast.fa_code = ass.code
			order by	ama.agreement_date desc
		)ex_agreement
		where opnm.opname_date between cast (@p_from_date as date) and cast (@p_to_date as date)
		and opnm.status='POST';
		--where purchase_date <= @p_as_of_date

		if not exists (select * from dbo.rpt_physical_checking where user_id = @p_user_id)
		begin
				insert into dbo.rpt_physical_checking
				(
				    user_id
				    ,report_company
				    ,report_title
				    ,report_image
				    ,report_address
				    ,from_date
					,to_date
				    ,code
				    ,ex_agreement_no
				    ,status_unit
				    ,status_pemakaian
				    ,leased_object
				    ,year
				    ,chasis_no
				    ,plat_no
				    ,physical_check_location
				    ,date
				    ,pic
				    ,condition
				    ,is_condition
				)
				values
				(   
					@p_user_id
				    ,@report_company
				    ,@report_title
				    ,@report_image
				    ,@report_address
				    ,@p_from_date
					,@p_to_date
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
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

