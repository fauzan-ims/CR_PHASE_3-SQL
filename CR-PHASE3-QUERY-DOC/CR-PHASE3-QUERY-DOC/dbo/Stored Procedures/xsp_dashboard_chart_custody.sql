/*
	created : nia, 15 Juni 2021
*/
create PROCEDURE dbo.xsp_dashboard_chart_custody
as
begin
	declare @msg nvarchar(max) ;

	--temporary new
	declare @new table
	(
		total			 int
		,total_post		 int
		,branch_name	 nvarchar(250)
		,document_status nvarchar(10)
	) ;

	insert into @new
	(
		total
		,total_post
		,branch_name
		,document_status
	)
	select		count(1)
				,0
				,branch_name
				,document_status
	from		dbo.document_pending
	where		document_status = 'NEW'
	group by	document_status
				,branch_code
				,branch_name ;

	insert into @new
	(
		total
		,total_post
		,branch_name
		,document_status
	)
	select		0
				,count(1)
				,branch_name
				,document_status
	from		dbo.document_pending
	where		document_status = 'TRANSIT'
	group by	document_status
				,branch_code
				,branch_name ;

	select	total
			,total_post
			,branch_name
			,document_status
	from	@new ;
end ;
