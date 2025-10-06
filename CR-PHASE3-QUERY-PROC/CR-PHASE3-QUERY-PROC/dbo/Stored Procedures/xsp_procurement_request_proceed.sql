-- Stored Procedure

CREATE PROCEDURE dbo.xsp_procurement_request_proceed 
(
	@p_code			   nvarchar(50)
	,@p_company_code   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)

)
as
begin
	declare @msg							nvarchar(max)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@qty_request					int
			,@uom_name						nvarchar(50)
			,@request_code					nvarchar(50)
			,@request_code_doc				nvarchar(50)
			,@req_date						datetime
			,@interface_remarks				nvarchar(4000)
			,@reff_approval_category_code	nvarchar(50)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@approval_code					nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(50)
			,@approval_path					nvarchar(4000)
			,@path							nvarchar(250)
			,@procurement_type				nvarchar(50)
			,@qty							int
			,@remark						nvarchar(4000)
			,@file_name_doc					nvarchar(250)
			,@paths_doc						nvarchar(250)
			,@remark_doc					nvarchar(4000)
			,@url_path						nvarchar(250)
			,@requestor_code				nvarchar(50)
			,@requestor_name				nvarchar(250)

	begin try
		select @procurement_type	= procurement_type
				,@qty				= pri.quantity_request
		from dbo.procurement_request pr
		left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
		where code = @p_code

		if exists
		(
			select	1 from dbo.procurement_request_item pri
			where	procurement_request_code = @p_code
			and		 isnull(fa_code,'') in (
					select	b.asset_code
					from	ifinams.dbo.sale					   a
							inner join ifinams.dbo.sale_detail b on a.code = b.sale_code
					where	b.asset_code = pri.fa_code
							and a.status not in ('CANCEL', 'REJECT')
		))
		begin
			set @msg = N'Asset Is In Sales Request Process.' ;
			raiserror(@msg, 16, -1) ;
		end ;

		if(@procurement_type = 'MOBILISASI' and (@qty > 1 or @qty = 0))
		begin
			set @msg = 'Quantity Request Must be Equal 1' ;

			raiserror(@msg, 16, -1) ;
		end

		if exists
		(
			select	1
			from	dbo.procurement_request_item
			where	procurement_request_code = @p_code
		)
		begin

			if exists
			(
				select	1 
				from	dbo.procurement_request pr
						inner join dbo.procurement_request_item pri on pri.procurement_request_code = pr.code
				where	pr.procurement_type in ('MOBILISASI','EXPENSE')
						and pr.code = @p_code
						and isnull(pri.fa_code,'')=''
			)
			begin
				set @msg = 'Procurement cannot be proceed, please input fixed asset!'
				raiserror (@msg, 16, -1)
			end
            else if exists
			(
				select	1 
				from	dbo.procurement_request pr
						inner join dbo.procurement_request_item pri on pri.procurement_request_code = pr.code
						inner join ifinams.dbo.asset ast on ast.code = pri.fa_code
				where	pr.procurement_type = 'EXPENSE'
						and pr.code = @p_code
						and isnull(ast.is_gps,'0') = '1'
						and isnull(ast.gps_status,'') not in ('','UNSUBSCRIBE')
			)
			begin
			
				set @msg = N'Assets Already Have Active GPS';
				raiserror(@msg, 16, -1) ;
			end
            else 
			begin

				declare curr_proc_req_appv cursor fast_forward read_only for
				select pr.branch_code
						,pr.branch_name
						,pr.remark
						,pr.request_date
						,pr.mod_by
						,sem.name
				from dbo.procurement_request pr
				left join ifinsys.dbo.sys_employee_main sem on sem.code collate latin1_general_ci_as = pr.mod_by
				where pr.code = @p_code

				open curr_proc_req_appv

				fetch next from curr_proc_req_appv 
				into @branch_code
					,@branch_name
					,@remark
					,@req_date
					,@request_code
					,@requestor_name

				while @@fetch_status = 0
				begin
				    set @interface_remarks = 'Approval ' + @procurement_type + ' procurement request for ' + @p_code + ', branch ' + ': ' + @branch_name + ' ' + @remark ;
					--set @req_date = getdate() ;

					select	@reff_approval_category_code = reff_approval_category_code
					from	dbo.master_approval
					where	code						 = 'PRAPV' ;

					--select path di global param
					select	@url_path = value
					from	dbo.sys_global_param
					where	code = 'URL_PATH' ;

					select	@path = @url_path + value
					from	dbo.sys_global_param
					where	code = 'PATHPRQ'

					--set approval path
					set	@approval_path = @path + @p_code

					exec dbo.xsp_proc_interface_approval_request_insert @p_code						= @request_code output
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_request_status			= 'HOLD'
																		,@p_request_date			= @req_date
																		,@p_request_amount			= 0
																		,@p_request_remarks			= @interface_remarks
																		,@p_reff_module_code		= 'IFINPROC'
																		,@p_reff_no					= @p_code
																		,@p_reff_name				= 'PROCUREMENT REQUEST APPROVAL'
																		,@p_paths					= @approval_path
																		,@p_approval_category_code	= @reff_approval_category_code
																		,@p_approval_status			= 'HOLD'
																		,@p_requestor_code			= @request_code
																		,@p_requesttor_name			= @requestor_name
																		,@p_cre_date				= @p_mod_date	  
																		,@p_cre_by					= @p_mod_by		  
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date	  
																		,@p_mod_by					= @p_mod_by		  
																		,@p_mod_ip_address			= @p_mod_ip_address

					declare curr_appv cursor fast_forward read_only for
					select 	approval_code
							,reff_dimension_code
							,reff_dimension_name
							,dimension_code
					from	dbo.master_approval_dimension
					where	approval_code = 'PRAPV'

					open curr_appv

					fetch next from curr_appv 
					into @approval_code
						,@reff_dimension_code
						,@reff_dimension_name
						,@dimension_code

					while @@fetch_status = 0
					begin
						select	@table_name					 = table_name
								,@primary_column			 = primary_column
						from	dbo.sys_dimension
						where	code						 = @dimension_code

						exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
																	,@p_reff_code	= @p_code
																	,@p_reff_table	= 'PROCUREMENT_REQUEST'
																	,@p_output		= @dim_value output ;

						exec dbo.xsp_proc_interface_approval_request_dimension_insert @p_id						= 0
																					  ,@p_request_code			= @request_code
																					  ,@p_dimension_code		= @reff_dimension_code
																					  ,@p_dimension_value		= @dim_value
																					  ,@p_cre_date				= @p_mod_date
																					  ,@p_cre_by				= @p_mod_by
																					  ,@p_cre_ip_address		= @p_mod_ip_address
																					  ,@p_mod_date				= @p_mod_date
																					  ,@p_mod_by				= @p_mod_by
																					  ,@p_mod_ip_address		= @p_mod_ip_address

						-- declare cursor 
						declare	curr_appv_doc	cursor for
						select 	procurement_request_code
								,remark
								,file_name
								,file_path
						from	dbo.procurement_request_document pr
						where	pr.procurement_request_code = @p_code;

						open	curr_appv_doc
						fetch	curr_appv_doc
						into		@request_code_doc
									,@remark_doc
									,@file_name_doc
									,@paths_doc

						while @@fetch_status = 0  --(-1) itu artinya tidak ada data
						begin

							exec dbo.xsp_proc_interface_approval_request_document_insert @p_id					= 0
																						 ,@p_request_code		= @request_code_doc
																						 ,@p_document_code		= ''
																						 ,@p_document_remarks	= @remark_doc
																						 ,@p_file_name			= @file_name_doc
																						 ,@p_paths				= @paths_doc
																						 ,@p_cre_date			= @p_mod_date
																						 ,@p_cre_by				= @p_mod_by
																						 ,@p_cre_ip_address		= @p_mod_ip_address
																						 ,@p_mod_date			= @p_mod_date
																						 ,@p_mod_by				= @p_mod_by
																						 ,@p_mod_ip_address		= @p_mod_ip_address

						fetch	curr_appv_doc
						into	@request_code_doc
								,@remark_doc
								,@file_name_doc
								,@paths_doc

						end

						close		curr_appv_doc
						deallocate  curr_appv_doc

						fetch next from curr_appv 
						into @approval_code
							,@reff_dimension_code
							,@reff_dimension_name
							,@dimension_code
					end

				close curr_appv
				deallocate curr_appv

				    fetch next from curr_proc_req_appv 
					into @branch_code
						,@branch_name
						,@remark
						,@req_date
						,@request_code
						,@requestor_name
				end

				close curr_proc_req_appv
				deallocate curr_proc_req_appv

				--update status procurement request
				update	procurement_request
				set		status			 = 'ON PROCESS'
						--				 
						,mod_date		 = @p_mod_date
						,mod_by			 = @p_mod_by
						,mod_ip_address  = @p_mod_ip_address
				where	code			 = @p_code
					and company_code = @p_company_code ;
			end;
		end ;
		else
		begin
			set @msg = 'Data Item must be submitted' ;

			raiserror(@msg, 16, -1) ;
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
