defmodule RefreshAccessToken do
  @client_id "ABXTy2UMjulekpUCKG9X3cprZZTKGseVM67S69SxJUgwwJ0wQi"
  @client_secret "Qc4uxzhDIyrVsozU0qn2KaxcgJSB2JnBpJZYYBZb"

  def get_bearer_token(_is_sandbox \\ false) do
    base_url = "https://oauth.platform.intuit.com"
    url = base_url <> "/oauth2/v1/tokens/bearer"

    refresh_token = QbProxy.Tokens.get_token_value("refresh_token")

    IO.inspect(refresh_token)
    params = [{"grant_type", "refresh_token"}, {"refresh_token", refresh_token}]

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Basic " <> encode_credentials(@client_id, @client_secret)}
    ]

    case HTTPoison.post(url, {:form, params}, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> IO.inspect()
        |> case do
          %{"access_token" => access_token, "refresh_token" => new_refresh_token} ->
            QbProxy.Tokens.upsert_token("access_token", access_token)

            if new_refresh_token != refresh_token do
              QbProxy.Tokens.upsert_token("refresh_token", new_refresh_token)
            end

            access_token
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp encode_credentials(client_id, client_secret) do
    credentials = "#{client_id}:#{client_secret}" |> :erlang.iolist_to_binary()
    Base.encode64(credentials)
  end
end

defmodule QbProxyWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :qb_proxy

  @basic_auth_username "your_username"
  @basic_auth_password "your_password"

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_qb_proxy_key",
    signing_salt: "ydjsUd3k",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :qb_proxy,
    gzip: false,
    only: QbProxyWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :qb_proxy
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # plug Plug.Parsers,
  #   parsers: [:urlencoded, :multipart, :json],
  #   pass: ["*/*"],
  # ,
  #   json_decoder: Phoenix.json_library()

  # body_reader: {CacheBodyReader, :read_body, []}

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug QbProxyWeb.Router
end
