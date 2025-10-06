CREATE PROCEDURE dbo.xsp_suspend_revenue_detail_insert
(
	@p_id					 bigint = 0 output
	,@p_suspend_revenue_code nvarchar(50)
	,@p_suspend_code		 nvarchar(50)
	--,@p_suspend_amount		 decimal(18, 2)
	--,@p_revenue_amount		 decimal(18, 2)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@transaction_code			nvarchar(50) 
			,@transaction_name			nvarchar(250)
			,@sum_amount				decimal(18, 2) 
			,@suspend_amount			decimal(18, 2)
			,@revenue_amount			decimal(18, 2) ;

	begin try
		if exists (select 1 from dbo.suspend_main where code = @p_suspend_code and isnull(transaction_code,'') <> '')
		begin
		    select	@transaction_code	= transaction_code
					,@transaction_name	= transaction_name 
			from	dbo.suspend_main 
			where	code = @p_suspend_code

		    set @msg = 'Suspend is in ' + @transaction_name + ', Transaction No : '+ @transaction_code;
			raiserror(@msg ,16,-1);
		end

		select	@suspend_amount		= remaining_amount
				,@revenue_amount	= remaining_amount
		from	dbo.suspend_main
		where	code = @p_suspend_code ;

		insert into suspend_revenue_detail
		(
			suspend_revenue_code
			,suspend_code
			,suspend_amount
			,revenue_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_suspend_revenue_code
			,@p_suspend_code
			,@suspend_amount
			,@revenue_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		select	@sum_amount		= sum(revenue_amount)
		from	dbo.suspend_revenue_detail
		where	suspend_revenue_code = @p_suspend_revenue_code

		update	dbo.suspend_revenue
		set		revenue_amount	= @sum_amount
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_suspend_revenue_code

		update	dbo.suspend_main
		set		transaction_code	= @p_suspend_revenue_code
				,transaction_name	= 'REVENUE'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_suspend_code

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
