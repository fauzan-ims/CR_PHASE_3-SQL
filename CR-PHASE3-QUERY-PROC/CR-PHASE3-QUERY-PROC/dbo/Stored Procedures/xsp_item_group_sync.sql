create procedure xsp_item_group_sync
(
	@p_cre_date		   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@code			   nvarchar(50)
			,@company_code	   nvarchar(50)
			,@description	   nvarchar(250)
			,@group_level	   int
			,@parent_code	   nvarchar(50)
			,@transaction_type nvarchar(20)
			,@is_active		   nvarchar(1) ;

	begin try
		--declar cursor
		declare c_item_group cursor for
		select	code
				,company_code
				,description
				,group_level
				,parent_code
				,transaction_type
				,is_active
		from	ifinbam.dbo.master_item_group ;

		--open cursor
		open c_item_group ;

		--fetch cursor
		fetch c_item_group
		into @code
			 ,@company_code
			 ,@description
			 ,@group_level
			 ,@parent_code
			 ,@transaction_type
			 ,@is_active ;

		while @@fetch_status = 0
		begin
			if exists
			(
				select	1
				from	dbo.master_item_group
				where	code = @code
			)
			begin
				update	dbo.master_item_group
				set		company_code = @company_code
						,description = @description
						,group_level = @group_level
						,parent_code = @parent_code
						,transaction_type = @transaction_type
						,is_active = @is_active
				where	code = @code ;
			end ;
			else
			begin
				insert into dbo.master_item_group
				(
					code
					,company_code
					,description
					,group_level
					,parent_code
					,transaction_type
					,is_active
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(	@code
					,@company_code
					,@description
					,@group_level
					,@parent_code
					,@transaction_type
					,@is_active
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;
			end ;

			--fetch cursor
			fetch c_item_group
			into @code
				 ,@company_code
				 ,@description
				 ,@group_level
				 ,@parent_code
				 ,@transaction_type
				 ,@is_active ;
		end ;

		--close and deallocate cursr
		close c_item_group ;
		deallocate c_item_group ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
