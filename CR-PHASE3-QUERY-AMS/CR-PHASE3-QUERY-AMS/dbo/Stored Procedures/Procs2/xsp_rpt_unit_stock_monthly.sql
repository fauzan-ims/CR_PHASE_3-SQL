--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_unit_stock_monthly
(
	@p_user_id		 nvarchar(50) = ''
	,@p_month		 int			 = null
    ,@p_year		 nvarchar(4)
    ,@p_is_condition nvarchar(1)
)
as
begin
	delete	rpt_unit_stock_monthly
	where	user_id = @p_user_id ;

	delete	dbo.RPT_DETAIL_UNIT_STOCK
	where	USER_ID = @p_user_id ;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_image			nvarchar(250)
			,@in_or_out				nvarchar(50)
			,@status_unit_stock		nvarchar(50)
			,@start_week_day1		int			 = 0 --1
			,@start_week_day2		int			 = 7 --8
			,@start_week_day3		int			 = 14 --15
			,@start_week_day4		int			 = 21 --22
			,@end_week_day1			int			 = 6 --7
			,@end_week_day2			int			 = 13 --14
			,@end_week_day3			int			 = 20 --21
			,@end_week_day4			int
			,@w1					int			 = 0
			,@w2					int			 = 0
			,@w3					int			 = 0
			,@w4					int			 = 0
			,@total_w1				int
			,@total_w2				int
			,@total_w3				int
			,@total_w4				int
			,@date					datetime
			,@w1_in					int
			,@w1_out				int
			,@w2_in					int
			,@w2_out				int
			,@w3_in					int
			,@w3_out				int
			,@w4_in					int
			,@w4_out				int
			,@status_allocation		nvarchar(50)
			,@process_status_detail nvarchar(50) ;

	declare @tamp table
	(
		w1					   int
		,w2					   int
		,w3					   int
		,w4					   int
		,status_allocation	   nvarchar(50)
		,process_status_detail nvarchar(50)
	) ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Unit Stock Monthly' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin

			/* declare variables */
			declare @type nvarchar(50) ;

			declare cursor_name cursor fast_forward read_only for
			select	distinct
					type
			from	dbo.handover_asset
			where	month(handover_date) = @p_month ;

			open cursor_name ;

			fetch next from cursor_name
			into @type ;

			while @@fetch_status = 0
			begin
				select	@total_w1 = count(1)
				from	dbo.handover_asset
				where	month(handover_date) = @p_month 
						and year(handover_date) = @p_year ;

				select	@date = eomonth(handover_date)
				from	dbo.handover_asset
				where	month(handover_date) = @p_month 
						and year(handover_date) = @p_year ;

				set @end_week_day4 = day(@date) ;

				if (@type in
				(
					'DELIVERY', 'MAINTENANCE OUT', 'RENT RETURN', 'REPLACE GTS OUT', 'REPLACE OUT', 'RETURN OUT', 'SELL OUT'
				)
				   )
				begin
					begin --DELIVERY
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month
									and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month	and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --MAINTENANCE OUT
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --RENT RETURN
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --REPLACE GTS OUT
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --REPLACE OUT
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --RETURN OUT
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --SELL OUT
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'OUT'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end
				end ;


				--In
				if (@type in
				(
					'MAINTENANCE IN', 'PICK UP', 'REPLACE GTS IN', 'REPLACE IN', 'RETURN IN'
				)
				   )
				begin
					begin --MAINTENANCE IN
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin -- PICK UP
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --REPLACE GTS IN
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --REPLACE IN
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end

					begin --RETURN IN
						select		@w1					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day1 and @end_week_day1
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w2					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day2 and @end_week_day2
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w3					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day3 and @end_week_day3
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;

						select		@w4					= isnull(count(1),0)
									,@status_unit_stock = type
									,@in_or_out			= N'IN'
						from		dbo.HANDOVER_ASSET
						where		TYPE					 = @type
									and day(HANDOVER_DATE)
									between @start_week_day4 and @end_week_day4
									and month(HANDOVER_DATE) = @p_month and year(handover_date) = @p_year 
						group by	type ;
					end
				end ;

				--select		@w1					= count(1)
				--			,@status_unit_stock = process_status
				--			,@in_or_out			= N'IN'
				--from		dbo.ASSET
				--where		PURCHASE_DATE
				--			between @start_week_day1 and @end_week_day1
				--			and month(PURCHASE_DATE) = @p_month
				--group by	process_status ;

				--select		@w2					= count(1)
				--			,@status_unit_stock = process_status
				--			,@in_or_out			= N'IN'
				--from		dbo.ASSET
				--where		PURCHASE_DATE
				--			between @start_week_day2 and @end_week_day2
				--			and month(PURCHASE_DATE) = @p_month
				--group by	process_status ;

				--select		@w3					= count(1)
				--			,@status_unit_stock = process_status
				--			,@in_or_out			= N'IN'
				--from		dbo.ASSET
				--where		PURCHASE_DATE
				--			between @start_week_day3 and @end_week_day3
				--			and month(PURCHASE_DATE) = @p_month
				--group by	process_status ;

				--select		@w4					= count(1)
				--			,@status_unit_stock = process_status
				--			,@in_or_out			= N'IN'
				--from		dbo.ASSET
				--where		PURCHASE_DATE
				--			between @start_week_day4 and @end_week_day4
				--			and month(PURCHASE_DATE) = @p_month
				--group by	process_status ;

				insert into dbo.rpt_unit_stock_monthly
				(
					user_id
					,report_company
					,report_title
					,report_image
					,in_or_out
					,total_w4
					,total_w3
					,total_w2
					,total_w1
					,w1
					,w2
					,w3
					,w4
					,status_unit_stock
					,parameter_month
					,total_w4_on_hand
					,total_w3_on_hand
					,total_w2_on_hand
					,total_w1_on_hand
					,month_desc
					,year
					,is_condition
				)
				values
				(
					@p_user_id			-- USER_ID - nvarchar(50)
					,@report_company	-- REPORT_COMPANY - nvarchar(250)
					,@report_title		-- REPORT_TITLE - nvarchar(250)
					,@report_image		-- REPORT_IMAGE - nvarchar(50)
					,@in_or_out			-- IN_OR_OUT - nvarchar(50)
					,0				-- TOTAL_W4 - int
					,0				-- TOTAL_W3 - int
					,0				-- TOTAL_W2 - int
					,@total_w1			-- TOTAL_W1 - int
					,@w1				-- W1 - int
					,@w2				-- W2 - int
					,@w3				-- W3 - int
					,@w4				-- W4 - int
					,@status_unit_stock -- STATUS_UNIT_STOCK - nvarchar(50)
					,@p_month			-- PARAMETER_MONTH - int
					,0				-- TOTAL_W4_ON_HAND - int
					,0				-- TOTAL_W3_ON_HAND - int
					,0				-- TOTAL_W2_ON_HAND - int
					,0				-- TOTAL_W1_ON_HAND - int
					,case
						when @p_month = '1' then 'Januari'
						when @p_month = '2' then 'Februari'
						when @p_month = '3' then 'Maret'
						when @p_month = '4' then 'April'
						when @p_month = '5' then 'Mei'
						when @p_month = '6' then 'Juni'
						when @p_month = '7' then 'Juli'
						when @p_month = '8' then 'Agustus'
						when @p_month = '9' then 'September'
						when @p_month = '10' then 'Oktober'
						when @p_month = '11' then 'November'
						when @p_month = '12' then 'Desember.'
					end
					,@p_year
					,@p_is_condition
				) ;

				fetch next from cursor_name
				into @type ;
			end ;

			select	@w1_in	= isnull(sum(W1),0)
					,@w2_in = isnull(sum(W2),0)
					,@w3_in = isnull(sum(W3),0)
					,@w4_in = isnull(sum(W4),0)
			from	dbo.RPT_UNIT_STOCK_MONTHLY
			where	USER_ID		  = @p_user_id
					and IN_OR_OUT = 'IN' ;

			select	@w1_out	 = isnull(sum(W1),0)
					,@w2_out = isnull(sum(W2),0)
					,@w3_out = isnull(sum(W3),0)
					,@w4_out = isnull(sum(W4),0)
			from	dbo.RPT_UNIT_STOCK_MONTHLY
			where	USER_ID		  = @p_user_id
					and IN_OR_OUT = 'OUT' ;

			update	dbo.rpt_unit_stock_monthly
			set		total_w1_on_hand = total_w1 + @w1_in - @w1_out
					,total_w2 = total_w1 + @w1_in - @w1_out
			where	user_id = @p_user_id ;

			update	rpt_unit_stock_monthly
			set		total_w2_on_hand = total_w2 + @w2_in - @w2_out
					,total_w3 = total_w2 + @w2_in - @w2_out
			where	user_id = @p_user_id ;

			update	dbo.rpt_unit_stock_monthly
			set		total_w3_on_hand = total_w3 + @w3_in - @w3_out
					,total_w4 = total_w3 + @w3_in - @w3_out
			where	user_id = @p_user_id ;

			update	dbo.rpt_unit_stock_monthly
			set		total_w4_on_hand = total_w4 + @w4_in - @w4_out
			where	user_id = @p_user_id ;

			--update	dbo.rpt_unit_stock_monthly
			--set		month_desc = datename(month, @date)
			--where	user_id = @p_user_id ;

			------------------------------------------------------------------------------------------------------------------------------------------------------
			set @w1 = 0 ;
			set @w2 = 0 ;
			set @w3 = 0 ;
			set @w4 = 0 ;
			set @status_allocation = null ;
			set @process_status_detail = null ;

			--BREAKDOWN
			begin
				select		@w1						= count(1)
							,@status_allocation		= N'BREAKDOWN'
							,@process_status_detail = PROCESS_STATUS
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and day(AGING_DATE)
							between @start_week_day1 and @end_week_day1
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				select		@w2						= isnull(count(1),0)
							,@status_allocation		= N'BREAKDOWN'
							,@process_status_detail = PROCESS_STATUS
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and day(AGING_DATE)
							between @start_week_day2 and @end_week_day2
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				select		@w3						= isnull(count(1),0)
							,@status_allocation		= N'BREAKDOWN'
							,@process_status_detail = PROCESS_STATUS
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and day(AGING_DATE)
							between @start_week_day3 and @end_week_day3
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				select		@w4						= isnull(count(1),0)
							,@status_allocation		= N'BREAKDOWN'
							,@process_status_detail = PROCESS_STATUS
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and day(AGING_DATE)
							between @start_week_day4 and @end_week_day4
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				insert into @tamp
			(
				w1
				,w2
				,w3
				,w4
				,status_allocation
				,process_status_detail
			)
			values
			(
				@w1
				,@w2
				,@w3
				,@w4
				,@status_allocation
				,@process_status_detail
			) ;

				set @w1 = 0 ;
				set @w2 = 0 ;
				set @w3 = 0 ;
				set @w4 = 0 ;
				set @status_allocation = null ;
				set @process_status_detail = null ;
			end

			--READY
			begin
				select	@w1						= isnull(count(1),0)
						,@status_allocation		= N'READY'
						,@process_status_detail = N'READY TO USE'
				from	dbo.ASSET_AGING
				where	STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
						and RENTAL_STATUS	  = ''
						and day(AGING_DATE)
						between @start_week_day1 and @end_week_day1
						and month(AGING_DATE) = @p_month and year(aging_date) = @p_year ;

				select	@w2						= isnull(count(1),0)
						,@status_allocation		= N'READY'
						,@process_status_detail = N'READY TO USE'
				from	dbo.ASSET_AGING
				where	STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
						and RENTAL_STATUS	  = ''
						and day(AGING_DATE)
						between @start_week_day2 and @end_week_day2
						and month(AGING_DATE) = @p_month and year(aging_date) = @p_year ;

				select	@w3						= isnull(count(1),0)
						,@status_allocation		= N'READY'
						,@process_status_detail = N'READY TO USE'
				from	dbo.ASSET_AGING
				where	STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
						and RENTAL_STATUS	  = ''
						and day(AGING_DATE)
						between @start_week_day3 and @end_week_day3
						and month(AGING_DATE) = @p_month and year(aging_date) = @p_year ;

				select	@w4						= isnull(count(1),0)
						,@status_allocation		= N'READY'
						,@process_status_detail = N'READY TO USE'
				from	dbo.ASSET_AGING
				where	STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
						and RENTAL_STATUS	  = ''
						and day(AGING_DATE)
						between @start_week_day4 and @end_week_day4
						and month(AGING_DATE) = @p_month and year(aging_date) = @p_year ;

				select		@w1						= isnull(count(1),0)
							,@status_allocation		= N'READY'
							,@process_status_detail = N'BOOKED'
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and RESERVED_BY is not null
							and RESERVED_DATE is not null
							and day(AGING_DATE)
							between @start_week_day1 and @end_week_day1
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				select		@w2						= isnull(count(1),0)
							,@status_allocation		= N'READY'
							,@process_status_detail = N'BOOKED'
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and RESERVED_BY is not null
							and RESERVED_DATE is not null
							and day(AGING_DATE)
							between @start_week_day1 and @end_week_day1
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				select		@w3						= isnull(count(1),0)
							,@status_allocation		= N'READY'
							,@process_status_detail = N'BOOKED'
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and RESERVED_BY is not null
							and RESERVED_DATE is not null
							and day(AGING_DATE)
							between @start_week_day1 and @end_week_day1
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				select		@w4						= isnull(count(1),0)
							,@status_allocation		= N'READY'
							,@process_status_detail = N'BOOKED'
				from		dbo.ASSET_AGING
				where		STATUS in
				(
					'STOCK', 'REPLACEMENT'
				)
							and RENTAL_STATUS	  = ''
							and RESERVED_BY is not null
							and RESERVED_DATE is not null
							and day(AGING_DATE)
							between @start_week_day1 and @end_week_day1
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	process_status ;

				insert into @tamp
			(
				w1
				,w2
				,w3
				,w4
				,status_allocation
				,process_status_detail
			)
			values
			(
				@w1
				,@w2
				,@w3
				,@w4
				,@status_allocation
				,@process_status_detail
			) ;

				set @w1 = 0 ;
				set @w2 = 0 ;
				set @w3 = 0 ;
				set @w4 = 0 ;
				set @status_allocation = null ;
				set @process_status_detail = null ;
			end

			--SELLING PROCESS
			begin
				select		@w1						= isnull(count(1),0)
							,@status_allocation		= N'SELLING PROCESS'
							,@process_status_detail = S.SELL_TYPE
				from		dbo.ASSET_AGING			  AA
							left join dbo.SALE_DETAIL SD on SD.ASSET_CODE = AA.CODE
							left join dbo.SALE		  S on S.CODE		  = SD.SALE_CODE
				where		AA.STATUS in
				(
					'SOLD'
				)
							and day(AGING_DATE)
							between @start_week_day1 and @end_week_day1
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	S.SELL_TYPE ;

				select		@w2						= isnull(count(1),0)
							,@status_allocation		= N'SELLING PROCESS'
							,@process_status_detail = S.SELL_TYPE
				from		dbo.ASSET_AGING			  AA
							left join dbo.SALE_DETAIL SD on SD.ASSET_CODE = AA.CODE
							left join dbo.SALE		  S on S.CODE		  = SD.SALE_CODE
				where		AA.STATUS in
				(
					'SOLD'
				)
							and day(AGING_DATE)
							between @start_week_day2 and @end_week_day2
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	S.SELL_TYPE ;

				select		@w3						= isnull(count(1),0)
							,@status_allocation		= N'SELLING PROCESS'
							,@process_status_detail = S.SELL_TYPE
				from		dbo.ASSET_AGING			  AA
							left join dbo.SALE_DETAIL SD on SD.ASSET_CODE = AA.CODE
							left join dbo.SALE		  S on S.CODE		  = SD.SALE_CODE
				where		AA.STATUS in
				(
					'SOLD'
				)
							and day(AGING_DATE)
							between @start_week_day3 and @end_week_day3
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	S.SELL_TYPE ;

				select		@w4						= isnull(count(1),0)
							,@status_allocation		= N'SELLING PROCESS'
							,@process_status_detail = S.SELL_TYPE
				from		dbo.ASSET_AGING			  AA
							left join dbo.SALE_DETAIL SD on SD.ASSET_CODE = AA.CODE
							left join dbo.SALE		  S on S.CODE		  = SD.SALE_CODE
				where		AA.STATUS in
				(
					'SOLD'
				)
							and day(AGING_DATE)
							between @start_week_day4 and @end_week_day4
							and month(AGING_DATE) = @p_month and year(aging_date) = @p_year
				group by	S.SELL_TYPE ;

				insert into @tamp
			(
				w1
				,w2
				,w3
				,w4
				,status_allocation
				,process_status_detail
			)
			values
			(
				@w1
				,@w2
				,@w3
				,@w4
				,@status_allocation
				,@process_status_detail
			) ;
			end

			begin -- insert to detail
				insert into dbo.RPT_DETAIL_UNIT_STOCK
				(
					USER_ID
					,REPORT_COMPANY
					,REPORT_TITLE
					,REPORT_IMAGE
					,STATUS_ALLOCATION
					,STATUS
					,PARAMETER_MONTH
					,W1
					,W2
					,W3
					,W4
					,DESC_MONTH
				)
				select	@p_user_id							-- USER_ID - nvarchar(50)
						,@report_company					-- REPORT_COMPANY - nvarchar(250)
						,@report_title						-- REPORT_TITLE - nvarchar(250)
						,@report_image						-- REPORT_IMAGE - nvarchar(50)
						,isnull(status_allocation, '')		-- STATUS_ALLOCATION - nvarchar(50)
						,isnull(process_status_detail, '')	-- STATUS - nvarchar(50)
						,@p_month							-- PARAMETER_MONTH - int
						,isnull(w1, 0)
						,isnull(w2, 0)
						,isnull(w3, 0)
						,isnull(w4, 0)
						,datename(month, @date)
				from	@tamp ;

				delete @tamp ;
			end

			--insert into dbo.RPT_DETAIL_UNIT_STOCK
			--(
			--	USER_ID
			--	,REPORT_COMPANY
			--	,REPORT_TITLE
			--	,REPORT_IMAGE
			--	,STATUS_ALLOCATION
			--	,STATUS
			--	,PARAMETER_MONTH
			--	,W1
			--	,W2
			--	,W3
			--	,W4
			--)
			--values
			--(
			--	@p_user_id				-- USER_ID - nvarchar(50)
			--	,@report_company		-- REPORT_COMPANY - nvarchar(250)
			--	,@report_title			-- REPORT_TITLE - nvarchar(250)
			--	,@report_image			-- REPORT_IMAGE - nvarchar(50)
			--	,@status_allocation		-- STATUS_ALLOCATION - nvarchar(50)
			--	,@process_status_detail -- STATUS - nvarchar(50)
			--	,@p_month				-- PARAMETER_MONTH - int
			--	,@w1					-- W1 - int
			--	,@w2					-- W2 - int
			--	,@w3					-- W3 - int
			--	,@w4					-- W4 - int
			--) ;
			

			close cursor_name ;
			deallocate cursor_name ;
		end ;

		if not exists (select * from dbo.rpt_unit_stock_monthly where user_id = @p_user_id)
		begin
				insert into dbo.rpt_unit_stock_monthly
				(
				    user_id
				    ,report_company
				    ,report_title
				    ,report_image
				    ,in_or_out
				    ,total_w4
				    ,total_w3
				    ,total_w2
				    ,total_w1
				    ,w1
				    ,w2
				    ,w3
				    ,w4
				    ,status_unit_stock
				    ,parameter_month
				    ,total_w4_on_hand
				    ,total_w3_on_hand
				    ,total_w2_on_hand
				    ,total_w1_on_hand
				    ,month_desc
				    ,is_condition
				)
				values
				(   
					@p_user_id
				    ,@report_company
				    ,@report_title
				    ,@report_image
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
