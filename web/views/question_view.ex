defmodule AfterGlow.QuestionView do
  use AfterGlow.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :last_updated, :sql, :human_sql, :cached_results, :results_view_settings, :inserted_at, :updated_at, :shareable_link, :is_shareable_link_public, :query_type, :columns]

  has_many :dashboards,
    field: :dashboards,
    type: "dashboards",
    include: false
  
  has_many :tags,
    field: :tags,
    type: "tags",
    include: false
  
  has_many :variables,
    field: :variables,
    type: "variables",
    include: false
end
