CREATE PROCEDURE dbo.xsp_asset_tracking_transaction
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_code			nvarchar(50)
)
as
begin
	declare @msg			nvarchar(max)
			,@status		nvarchar(20) 
			,@rows_count	int = 0;

	begin try  
		declare @tracking_main as table 
		(
			code		nvarchar(50)
			,date		datetime
			,branch		nvarchar(150)
			,status		nvarchar(50)
			,remark		nvarchar(250)
		)

		if exists (select 1 from dbo.mutation_detail where asset_code = @p_code)
		begin
			insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	code				
					,mutation_date		
					,from_branch_name	
					,mtn.status			
					,'MUTATION'
			from	dbo.mutation mtn
					inner join dbo.mutation_detail mtd on mtd.mutation_code = mtn.code
			where	mtd.asset_code = @p_code 
			and		(mtn.status in ('HOLD', 'ON PROCESS')
				or	mtd.status_received in ('SENT','RETURNED')) ;
		end
		else if exists (select 1 from dbo.disposal_detail where asset_code = @p_code)
		begin
		    insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	dsp.code			
					,dsp.disposal_date	
					,dsp.branch_name 	
					,dsp.status			
					,'DISPOSAL'
			from	dbo.disposal dsp
					inner join dbo.disposal_detail dsd on dsd.disposal_code = dsp.code
			where	dsd.asset_code = @p_code 
			and		dsp.status in ('HOLD', 'ON PROCESS') ;
		end
		else if exists (select 1 from dbo.reverse_disposal_detail where asset_code = @p_code)
		begin
		    insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	dsp.code					
					,dsp.reverse_disposal_date	
					,dsp.branch_name 			
					,dsp.status					
					,'REVERSE DISPOSAL'
			from	dbo.reverse_disposal dsp
					inner join dbo.reverse_disposal_detail dsd on dsd.reverse_disposal_code = dsp.code
			where	dsd.asset_code = @p_code 
			and		dsp.status in ('HOLD', 'ON PROCESS') ;
		end
		else if exists (select 1 from dbo.sale_detail where asset_code = @p_code)
		begin
		    insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	sle.code			
					,sle.sale_date		
					,sle.branch_name 	
					,sle.status			
					,'SALE'
			from	dbo.sale sle
					inner join dbo.sale_detail sld on sld.sale_code = sle.code
			where	sld.asset_code = @p_code 
			and		sle.status in ('HOLD', 'ON PROCESS') ;
		end
		else if exists (select 1 from dbo.reverse_sale_detail where asset_code = @p_code)
		begin
		    insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	sle.code					
					,sle.reverse_sale_date		
					,sle.branch_name 			
					,sle.status					
					,'REVERSE SALE'
			from	dbo.reverse_sale sle
					inner join dbo.reverse_sale_detail sld on sld.reverse_sale_code = sle.code
			where	sld.asset_code = @p_code 
			and		sle.status in ('HOLD', 'ON PROCESS') ;
		end
		else if exists (select 1 from dbo.opname_detail where asset_code = @p_code)
		begin
		    insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	opn.code			
					,opn.opname_date	
					,opn.branch_name 	
					,opn.status			
					,'OPNAME'
			from	dbo.opname opn
					inner join dbo.opname_detail opd on opd.opname_code = opn.code
			where	opd.asset_code = @p_code 
			and		opn.status in ('HOLD', 'ON PROCESS') ;
		end
		else if exists (select 1 from dbo.change_category where asset_code = @p_code)
		begin
		    insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	chc.code			
					,chc.date			
					,chc.branch_name 	
					,chc.status			
					,'CHANGE CATEGORY'
			from	dbo.change_category chc
			where	chc.asset_code = @p_code 
			and		chc.status in ('HOLD', 'ON PROCESS') ;
		end
		else if exists (select 1 from dbo.maintenance where asset_code = @p_code)
		begin
		    insert into @tracking_main
			(
			    code
				,date
				,branch
				,status
				,remark
			)
			select	chc.code			
					,chc.transaction_date			
					,chc.branch_name 	
					,chc.status			
					,'MAINTENANCE'
			from	dbo.maintenance chc
			where	chc.asset_code = @p_code 
			and		chc.status in ('HOLD', 'ON PROCESS', 'POST') ;
		end
		else if exists (select 1 from dbo.REGISTER_MAIN where fa_code = @p_code)
		begin
			insert into @tracking_main
			(
				code
				,date
				,branch
				,status
				,remark
			)
			select code
					,register_date
					,branch_name
					,register_status
					,'REGISTER'
			from dbo.register_main
			where fa_code = @p_code
			and register_status <> 'CANCEL'
		end



		select	@rows_count = count(1)
		from	@tracking_main
		where	(
					code									like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), date, 103)	like '%' + @p_keywords + '%'
					or	branch								like '%' + @p_keywords + '%'
					or	status								like '%' + @p_keywords + '%'
					or	remark								like '%' + @p_keywords + '%'
				) ;

		select	code
				,convert(nvarchar(30), date, 103) 'date'
				,branch
				,status
				,remark 
				,@rows_count 'rowcount'
		from	@tracking_main 
		where	(
					code									like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), date, 103)	like '%' + @p_keywords + '%'
					or	branch								like '%' + @p_keywords + '%'
					or	status								like '%' + @p_keywords + '%'
					or	remark								like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then cast(date as sql_variant)
													 when 3 then branch
													 when 4 then remark
													 when 5 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then cast(date as sql_variant)
													 when 3 then branch
													 when 4 then remark
													 when 5 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;		
				
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
end ;
