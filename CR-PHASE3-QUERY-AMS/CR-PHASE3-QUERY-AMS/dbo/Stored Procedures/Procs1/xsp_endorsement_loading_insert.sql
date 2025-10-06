CREATE PROCEDURE dbo.xsp_endorsement_loading_insert
(
	@p_id					bigint = 0 output
	,@p_endorsement_code	nvarchar(50)
	,@p_old_or_new			nvarchar(3)
	,@p_loading_code		nvarchar(50)
	,@p_year_period			int
	,@p_initial_buy_rate	decimal(9, 6)  = 0
	,@p_initial_sell_rate	decimal(9, 6)  = 0
	,@p_initial_buy_amount	decimal(18, 2) = 0
	,@p_initial_sell_amount decimal(18, 2) = 0
	,@p_total_buy_amount	decimal(18, 2) = 0
	,@p_total_sell_amount	decimal(18, 2) = 0
	,@p_remain_buy			decimal(18, 2) = 0
	,@p_remain_sell			decimal(18, 2) = 0
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
	declare @msg nvarchar(max) ;

	begin TRY
		insert into endorsement_loading
		(
			endorsement_code
			,old_or_new
			,loading_code
			,year_period
			,initial_buy_rate
			,initial_sell_rate
			,initial_buy_amount
			,initial_sell_amount
			,total_buy_amount
			,total_sell_amount
			,remain_buy
			,remain_sell
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_endorsement_code
			,@p_old_or_new
			,@p_loading_code
			,@p_year_period
			,@p_initial_buy_rate	
			,@p_initial_sell_rate	
			,@p_initial_buy_amount	
			,@p_initial_sell_amount 
			,@p_total_buy_amount	
			,@p_total_sell_amount	
			,@p_remain_buy			
			,@p_remain_sell			
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


