require IEx
defmodule AfterGlow.Snapshots do
  @moduledoc """
  The Snapshots context.
  """

  import Ecto.Query, warn: false
  alias AfterGlow.Repo

  alias AfterGlow.Snapshots.Snapshot
  alias AfterGlow.Snapshots.SnapshotData
  alias AfterGlow.Database
  alias AfterGlow.Question
  alias AfterGlow.Sql.DbConnection
  alias AfterGlow.Async
  alias AfterGlow.SnapshotsTasks
  alias AfterGlow.Helpers.CsvHelpers
  alias AfterGlow.Mailers.CsvMailer
  import Ecto.Query, only: [from: 2]

  @doc """
  Returns the list of snapshots.

  ## Examples

  iex> list_snapshots()
  [%Snapshot{}, ...]

  """
  def list_snapshots do
    Repo.all(Snapshot)
  end

  @doc """
  Gets a single snapshot.

  Raises `Ecto.NoResultsError` if the Snapshot does not exist.

  ## Examples

  iex> get_snapshot!(123)
  %Snapshot{}

  iex> get_snapshot!(456)
  ** (Ecto.NoResultsError)

  """
  def get_snapshot!(id) do
    snapshot_data_preload_query = from c in SnapshotData, limit: 2000
    Repo.get!(Snapshot, id)
    |> Repo.preload(snapshot_data: snapshot_data_preload_query)
  end


  @doc """
  Creates a snapshot.

  ## Examples

  iex> create_snapshot(%{field: value})
  {:ok, %Snapshot{}}

  iex> create_snapshot(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_snapshot(attrs \\ %{}, email_id) do
    created = %Snapshot{}
    |> Snapshot.changeset(attrs)
    |> Repo.insert()
    with {:ok, %Snapshot{} = snapshot} <- created do
      Async.perform(&SnapshotsTasks.save/2, [snapshot, email_id])
    end
    created
  end

  @doc """
  Updates a snapshot.

  ## Examples

  iex> update_snapshot(snapshot, %{field: new_value})
  {:ok, %Snapshot{}}

  iex> update_snapshot(snapshot, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_snapshot(%Snapshot{} = snapshot, attrs) do
    snapshot
    |> Snapshot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Snapshot.

  ## Examples

  iex> delete_snapshot(snapshot)
  {:ok, %Snapshot{}}

  iex> delete_snapshot(snapshot)
  {:error, %Ecto.Changeset{}}

  """
  def delete_snapshot(%Snapshot{} = snapshot) do
    Repo.delete(snapshot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking snapshot changes.

  ## Examples

  iex> change_snapshot(snapshot)
  %Ecto.Changeset{source: %Snapshot{}}

  """
  def change_snapshot(%Snapshot{} = snapshot) do
    Snapshot.changeset(snapshot, %{})
  end

  def save_data(%Snapshot{} = snapshot) do
    snapshot = snapshot |> Repo.preload(:question)
    question = snapshot.question |> Repo.preload(:variables)
    db_identifier = question.human_sql["database"]["unique_identifier"]
    db_record = Repo.one(from d in Database, where: d.unique_identifier == ^db_identifier) 
    query = Question.replace_variables(question.sql, question.variables , question.variables)
    {:ok, columns} = DbConnection.execute_with_stream(db_record |> Map.from_struct,
      query,
      &insert_snapshot_data_in_bulk(snapshot, &1, &2)
    )

  end

  def fetch_and_upload_for_snapshot(id, email_id) do
    Async.perform(&create_and_send_csv/2, [id, email_id])
  end

  def create_and_send_csv(id, email_id) do
    snapshot = Snapshot |> Repo.get!(id)
    query = from sd in SnapshotData,
      select: sd.row,
      where: sd.snapshot_id == ^snapshot.id
    stream = Repo.stream(query)
    {:ok, url} = Repo.transaction(fn() ->
      stream = stream |> Stream.map(fn x -> x["values"] end)
      CsvHelpers.save_to_file_and_upload([stream], snapshot.columns)
    end)
    CsvMailer.mail(email_id, url)
  end

  defp insert_snapshot_data_in_bulk(snapshot, rows, columns) do
    update_snapshot(snapshot, %{columns: columns})
    query = "insert into snapshot_data (snapshot_id, row, inserted_at, updated_at) values"
    time_string = DateTime.utc_now |> DateTime.to_string
    v = rows
    |> Enum.map(fn chunk ->
      values = chunk
      |> Enum.map(fn x ->
        value = Poison.encode!(%{values: x}) |> String.replace("'", "''")
        "( #{snapshot.id}, '#{value}', '#{time_string}', '#{time_string}' )"
      end)
      |> Enum.join(", ")
      if values |> String.first do
        query = query <> values
        Ecto.Adapters.SQL.query!(Repo, query, [])
      end
    end)
    "I am Done" |> IO.inspect
  end
end

