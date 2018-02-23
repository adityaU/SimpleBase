defmodule AfterGlow.Sql.Adapters.QueryMakers.Redshift do
  use AfterGlow.Sql.Adapters.QueryMakers.Common

  @time_fn_based_on_duration %{
    "seconds" => "getdate()",
    "minutes" => "getdate()",
    "hours"  => "getdate()",
    "days"  => "current_date",
    "weeks"  => "current_date",
    "months"  => "current_date",
    "years"  => "current_date",
    "quarters"  => "current_date",
  }

  def parse_filter_date_obj_value(val, dtt, dur) do
    {val, duration} = case dur["value"] do
                        "quarters" ->
                          { (val |> String.to_integer)*3, "months"}
                        _ ->
                          {val , dur["value"]} 
                      end
    op = case dtt["value"] do
           "ago" -> "-"
           _ -> "+"
         end
    "(#{@time_fn_based_on_duration[duration]} #{op} INTERVAL '#{val} #{duration}')"
  end

  def stringify_select(%{"raw" => true, "value" => value}, columns_required), do: value
  def stringify_select(%{"name" => _name, "value" => "raw_data"}, []), do: "*"
  def stringify_select(%{"name" => _name, "value" => "raw_data"}, columns_required), do: "*"
  def stringify_select(%{"name" => _name, "value" => "count"}, columns_required), do: "count(*)"

  # def cast_group_by(el, nil),  do: el
  # def cast_group_by(el, "day"),  do: "DATE(CONCAT(year(#{el}),'-', month(#{el}), '-', day(#{el}), 'T00:00:00'))  sep|rator as \"#{el} by Day\""
  # def cast_group_by(el, "minutes"),  do: "TIMESTAMP(CONCAT(year(#{el}),'-', month(#{el}), '-', day(#{el}), 'T', hour(#{el}),':', minute(#{el}), ':00')) sep|rator as \"#{el} by Minute\""
  # def cast_group_by(el, "seconds"),  do: "TIMESTAMP(CONCAT(year(#{el}),'-', month(#{el}), '-', day(#{el}), 'T', hour(#{el}),':', minute(#{el}), ':', second(#{el}))) sep|rator as \"#{el} by Second\""
  # def cast_group_by(el, "hour"),  do: "TIMESTAMP(CONCAT(year(#{el}),'-', month(#{el}), '-', day(#{el}), 'T', hour(#{el}),':00:00')) sep|rator as \"#{el}  by Hour\""
  # def cast_group_by(el, "week"),  do: "CONCAT(year(#{el}),', Week: ', week(#{el})) sep|rator as \"#{el}  by Week\""
  # def cast_group_by(el, "month"),  do: "DATE(CONCAT(year(#{el}),'-', month(#{el}), '-01T00:00:00')) sep|rator as \"#{el}  by Month\""
  # def cast_group_by(el, "quarter"),  do: "CONCAT(year(#{el}),', Quarter: ', quarter(#{el})) sep|rator as \"#{el}  by  Quarter\""
  # def cast_group_by(el, "year"),  do: "year(#{el}) sep|rator as \"#{el}  by Year\""
  # def cast_group_by(el, "hour_day"),  do: "hour(#{el}) sep|rator as \"#{el}  by hour of the day\""
  # def cast_group_by(el, "day_week"),  do: "dayofweek(#{el}) sep|rator as \"#{el}  by Day of the Week\""
  # def cast_group_by(el, "day_month"),  do: "dayofmonth(#{el}) sep|rator as \"#{el}  by By Day of the Month\""
  # def cast_group_by(el, "week_year"),  do: "weekofyear(#{el}) sep|rator as \"#{el}  by Week of the Year\""
  # def cast_group_by(el, "month_year"),  do: "month(#{el}) sep|rator as \"#{el}  by Month of the Year\""
  # def cast_group_by(el, "quarter_year"),  do: "quarter(#{el}) sep|rator as \"#{el}  by Quarter of the Year\""
end
