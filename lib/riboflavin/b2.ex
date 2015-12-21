defmodule Riboflavin.B2 do
  @moduledoc """
  File management for Backblaze B2
  """

  alias Riboflavin.B2Auth
  alias Riboflavin.API

  @doc """
  Pull credentials from config and send auth request to Backblaze. Return auth code and store for application
  """
  def authorize_account do
    auth_info = API.b2_authorize_account({Application.get_env(:riboflavin, :account_id), Application.get_env(:riboflavin, :application_key)}, Application.get_env(:riboflavin, :api_url))
    case auth_info do
      %{"accountId" => _} -> update_b2auth(auth_info)
      _ -> auth_info
    end
  end

  def update_b2auth(auth_info) do
    B2Auth.update(:account_id, auth_info["accountId"])
    B2Auth.update(:auth_token, auth_info["authorizationToken"])
    B2Auth.update(:api_url, auth_info["apiUrl"])
    B2Auth.update(:download_url, auth_info["downloadUrl"])
  end

  @doc """
  Check if we've already auth'd with backblaze
  """
  def authorized? do
    !is_nil B2Auth.get(:auth_token)
  end

  # {{{ Bucket Commands

  @doc """
  Create a new bucket
  """
  def create_bucket(bucket_name, bucket_type) do
    if !authorized? do
      authorize_account
    end

    API.b2_create_bucket(B2Auth.get(:auth_token), B2Auth.get(:api_url), B2Auth.get(:account_id), bucket_name, bucket_type)
  end

  def delete_bucket(bucket_id) do
    if !authorized? do
      authorize_account
    end

    API.b2_delete_bucket(B2Auth.get(:auth_token), B2Auth.get(:api_url), B2Auth.get(:account_id), bucket_id)
  end

  def list_buckets do
    if !authorized? do
      authorize_account
    end

    API.b2_list_buckets(B2Auth.get(:auth_token), B2Auth.get(:api_url), B2Auth.get(:account_id))
  end

  def update_bucket(bucket_id, bucket_type) do
    if !authorized? do
      authorize_account
    end

    API.b2_update_bucket(B2Auth.get(:auth_token), B2Auth.get(:api_url), bucket_id, bucket_type)
  end

  # }}}

  # {{{ Bucket File Commands

  def list_file_names(bucket_id, max_file_count \\ 100) do
    if !authorized? do
      authorize_account
    end

    API.b2_list_file_names(B2Auth.get(:auth_token), B2Auth.get(:api_url), bucket_id, max_file_count)
  end

  def list_file_versions(bucket_id, max_file_count \\ 100) do
    if !authorized? do
      authorize_account
    end

    API.b2_list_file_versions(B2Auth.get(:auth_token), B2Auth.get(:api_url), bucket_id, max_file_count)
  end

  # }}}

  # {{{ File Commands


  def delete_file_version(file_name, file_id) do
    if !authorized? do
      authorize_account
    end

    API.b2_delete_file_version(B2Auth.get(:auth_token), B2Auth.get(:api_url), file_name, file_id)
  end

  def download_file_by_id(file_id) do
    if !authorized? do
      authorize_account
    end

    API.b2_download_file_by_id(B2Auth.get(:auth_token), B2Auth.get(:api_url), file_id)
  end

  def download_file_by_name(bucket_name, file_name, do_auth \\ false) do
    if !authorized? do
      authorize_account
    end
    auth_token = if do_auth, do: B2Auth.get(:auth_token), else: ""

    API.b2_download_file_by_name(auth_token, B2Auth.get(:download_url), bucket_name, file_name)
  end

  def get_file_info(file_id) do
    if !authorized? do
      authorize_account
    end

    API.b2_get_file_info(B2Auth.get(:auth_token), B2Auth.get(:api_url), file_id)
  end

  def get_upload_url(file_id) do
    if !authorized? do
      authorize_account
    end

    API.b2_get_upload_url(B2Auth.get(:auth_token), B2Auth.get(:api_url), file_id)
  end

  def hide_file(bucket_id, file_name) do
    if !authorized? do
      authorize_account
    end

    API.b2_hide_file(B2Auth.get(:auth_token), B2Auth.get(:api_url), bucket_id, file_name)
  end

  def upload_file(bucket_id, file_name, headers) do
    if !authorized? do
      authorize_account
    end

    API.b2_upload_file(B2Auth.get(:auth_token), B2Auth.get(:api_url), bucket_id, file_name, headers)
  end

  # }}}

end
