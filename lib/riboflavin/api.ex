defmodule Riboflavin.API do
  @moduledoc """
  Direct API interface for Backblaze B2
  """

  @type cred_t :: {String.t, String.t}

  @doc """
  Used to log in to the B2 API. Returns an authorization token that can be used for account-level operations, and a URL that should be used as the base URL for subsequent API calls.
  """
  @spec b2_authorize_account(cred_t, String.t) :: Map.t
  def b2_authorize_account(credentials, api_url) do
    auth = [basic_auth: credentials]
    HTTPoison.get!(api_url <> "/b2_authorize_account", [{"Accept", "application/json"}], [hackney: auth])
    |> Map.get(:body)
    |> Poison.decode!
  end

  # {{{ Bucket Commands

  @doc """
  Creates a new bucket. A bucket belongs to the account used to create it.
  """
  @spec b2_create_bucket(String.t, String.t, String.t, String.t, String.t) :: Map.t
  def b2_create_bucket(auth_token, api_url, account_id, bucket_name, bucket_type) do
    post(api_url <> "/b2api/v1/b2_create_bucket", auth_token, %{accountId: account_id, bucketName: bucket_name, bucketType: bucket_type})
  end

  @doc """
  Deletes the bucket specified. Only buckets that contain no version of any files can be deleted.
  """
  @spec b2_delete_bucket(String.t, String.t, String.t, String.t) :: Map.t
  def b2_delete_bucket(auth_token, api_url, account_id, bucket_id) do
    post(api_url <> "/b2api/v1/b2_delete_bucket", auth_token, %{accountId: account_id, bucketId: bucket_id})
  end

  @doc """
  Lists buckets associated with an account in alphabetical order by bucket ID.
  """
  @spec b2_list_buckets(String.t, String.t, String.t) :: Map.t
  def b2_list_buckets(auth_token, api_url, account_id) do
    post(api_url <> "/b2api/v1/b2_list_buckets", auth_token, %{accountId: account_id})
  end

  @doc """
  Update an existing bucket.
  """
  @spec b2_update_bucket(String.t, String.t, String.t, String.t) :: Map.t
  def b2_update_bucket(auth_token, api_url, bucket_id, bucket_type) do
    post(api_url <> "/b2api/v1/b2_update_bucket", auth_token, %{bucketId: bucket_id, bucketType: bucket_type})
  end

  # }}}

  # {{{ Bucket File Commands
  @doc """
  Lists the names of all files in a bucket, starting at a given name.
  TODO: Start File Name
  """
  @spec b2_list_file_names(String.t, String.t, String.t, number) :: Map.t
  def b2_list_file_names(auth_token, api_url, bucket_id, max_file_count \\ 100) do
    post(api_url <> "/b2api/v1/b2_list_file_names", auth_token, %{bucketId: bucket_id, maxFileCount: max_file_count})
  end

  @doc """
  Lists all of the versions of all of the files contained in one bucket, in alphabetical order by file name, and by reverse of data/time uploaded for versions of files with the same name.
  TODO: Start file name and ID
  """
  @spec b2_list_file_versions(String.t, String.t, String.t, number) :: Map.t
  def b2_list_file_versions(auth_token, api_url, bucket_id, max_file_count \\ 100) do
    post(api_url <> "/b2api/v1/b2_list_file_versions", auth_token, %{bucketId: bucket_id, maxFileCount: max_file_count})
  end

  # }}}

  # {{{ File Commands

  @doc """
  Deletes one version of a file from B2.
  """
  @spec b2_delete_file_version(String.t, String.t, String.t, String.t) :: Map.t
  def b2_delete_file_version(auth_token, api_url, file_name, file_id) do
    post(api_url <> "/b2api/v1/b2_delete_file_version", auth_token, %{fileName: file_name, fileId: file_id})
  end

  @doc """
  Downloads one file from B2.
  """
  @spec b2_download_file_by_id(String.t, String.t, String.t) :: Map.t
  def b2_download_file_by_id(auth_token, api_url, file_id) do
    post(api_url <> "/b2api/v1/b2_download_file_by_id", auth_token, %{fileId: file_id})
  end

  @doc """
  Downloads one file by providing the name of the bucket and the name of the file.
  """
  @spec b2_download_file_by_name(String.t, String.t, String.t, String.t) :: Map.t
  def b2_download_file_by_name(auth_token, download_url, bucket_name, file_name) do
    download(download_url <> "/file/" <> bucket_name <> "/" <> file_name, auth_token)
  end

  @doc """
  Gets information about one file stored in B2.
  """
  @spec b2_get_file_info(String.t, String.t, String.t) :: Map.t
  def b2_get_file_info(auth_token, api_url, file_id) do
    post(api_url <> "/b2api/v1/b2_get_file_info", auth_token, %{fileId: file_id})
  end

  @doc """
  Gets a URL to use for uploading files.
  """
  @spec b2_get_upload_url(String.t, String.t, String.t) :: Map.t
  def b2_get_upload_url(auth_token, api_url, bucket_id) do
    post(api_url <> "/b2api/v1/b2_get_upload_url", auth_token, %{bucketId: bucket_id})
  end

  @doc """
  Hides a file so that downloading by name will not find the file, but previous versions of the file are still stored. See File Versions about what it means to hide a file.
  """
  @spec b2_hide_file(String.t, String.t, String.t, String.t) :: Map.t
  def b2_hide_file(auth_token, api_url, bucket_id, file_name) do
    post(api_url <> "/b2api/v1/b2_hide_file", auth_token, %{bucketId: bucket_id, fileName: file_name})
  end

  @doc """
  Uploads one file to B2, returning its unique file ID.
  """
  @spec b2_upload_file(String.t, String.t, String.t, String.t, Map.t) :: Map.t
  def b2_upload_file(auth_token, api_url, bucket_id, file_name, headers) do
    upload_data = b2_get_upload_url(auth_token, api_url, bucket_id)
    file_info = File.stat!(file_name)
    initial_headers = %{
      "Authorization" => upload_data["authorizationToken"],
      "X-Bz-File-Name" => Path.basename(file_name),
      "Content-Type" => "b2/x-auto",
      "Content-Length" => file_info.size,
      "X-Bz-Content-Sha1" => sha1_file(file_name)
    }
    combined_headers = Map.merge(initial_headers, headers)
    post_file(upload_data["uploadUrl"], combined_headers, file_name)
  end

  # }}}

  # {{{ Internal Helpers

  @doc """
  Formats and sends post to URL and returns Map with response.
  """
  def post(url, auth_token, body) do
    HTTPoison.post!(url, Poison.encode!(body), %{"Authorization" => auth_token})
    |> Map.get(:body)
    |> Poison.decode!
  end

  @doc """
  Post a file and headers
  """
  def post_file(url, headers, file_name) do
    HTTPoison.post!(url, {:file, file_name}, headers)
    |> Map.get(:body)
    |> Poison.decode!
  end

  @doc """
  Formats and gets to URL and returns Map with response.
  """
  def download(url, auth_token) do
    headers = if auth_token != "", do: %{"Authorization" => auth_token}, else: %{}
    case HTTPoison.get!(url, headers) do
      %HTTPoison.Response{status_code: 200, body: file_data} -> file_data
      other -> Map.get(other, :body) |> Poison.decode!
    end
  end

  @doc """
  TODO: Download async to not block on download.
  """
  def download_async(url, auth_token \\ "") do
    headers = if auth_token != "", do: %{"Authorization" => auth_token}, else: %{}
                 HTTPoison.get!(url, headers)
                 |> Map.get(:body)
                 |> Poison.decode!
  end

  @doc """
  Generate Sha1 of File
  """
  def sha1_file(file) do
    sha = :crypto.hash_init(:sha)
    File.stream!(file, [], 1048576)
    |> Enum.reduce(sha, fn(buf, acc) ->
      :crypto.hash_update acc, buf
    end)
    |> :crypto.hash_final
    |> Base.encode16
    |> String.downcase
  end

  # }}}

end
