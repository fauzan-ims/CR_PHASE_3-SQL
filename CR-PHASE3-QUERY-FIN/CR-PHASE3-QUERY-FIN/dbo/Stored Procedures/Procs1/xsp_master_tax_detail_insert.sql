CREATE PROCEDURE dbo.xsp_master_tax_detail_insert
(
	@p_id					   bigint = 0 output
	,@p_tax_code			   nvarchar(50)
	,@p_effective_date		   datetime
	,@p_from_value_amount	   decimal(18, 2)
	,@p_to_value_amount		   decimal(18, 2)
	,@p_with_tax_number_pct	   decimal(9, 6)
	,@p_without_tax_number_pct decimal(9, 6)
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		if (cast(@p_effective_date as date) < cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg ='Effective Date must be greater or equal than System Date';
			raiserror(@msg,16,-1) ;
		end

		if (@p_from_value_amount > @p_to_value_amount)
		begin
			set @msg = 'From Amount cannot be greater than To Amount' ;

			raiserror(@msg, 16, -1) ;
		end
		if exists
		(
			select	1
			from	master_tax_detail
			where	tax_code = @p_tax_code
			and		cast(effective_date as date)	= cast(@p_effective_date as date)
			and		(
						from_value_amount	<= @p_from_value_amount
						and @p_from_value_amount <= to_value_amount
					)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_tax_detail
			where	tax_code = @p_tax_code
			and		cast(effective_date as date)	= cast(@p_effective_date as date)
			and		(
						from_value_amount			<= @p_to_value_amount
						and @p_to_value_amount		<= to_value_amount
					)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_tax_detail
			where	tax_code = @p_tax_code
			and		cast(effective_date as date)	= cast(@p_effective_date as date)
			and		(
						@p_from_value_amount		<= from_value_amount
						and from_value_amount		<= @p_to_value_amount
					)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_tax_detail
			where	tax_code = @p_tax_code
			and		cast(effective_date as date)	= cast(@p_effective_date as date)
			and		(
						@p_to_value_amount			<= to_value_amount
						and to_value_amount			<= @p_to_value_amount
					)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if @p_with_tax_number_pct > 100
		begin
			set @msg ='With Tax Number must be lower than 100';
			raiserror(@msg,16,1) ;
		END

		if @p_without_tax_number_pct > 100
		begin
			set @msg ='Without Tax Number must be lower than 100';
			raiserror(@msg,16,1) ;
		END

		insert into master_tax_detail
		(
			tax_code
			,effective_date
			,from_value_amount
			,to_value_amount
			,with_tax_number_pct
			,without_tax_number_pct
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
			@p_tax_code
			,@p_effective_date
			,@p_from_value_amount
			,@p_to_value_amount
			,@p_with_tax_number_pct
			,@p_without_tax_number_pct
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
