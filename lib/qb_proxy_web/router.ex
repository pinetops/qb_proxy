defmodule RedirectLocal do
  import Plug.Conn
  import Plug.Conn, only: [put_resp_header: 3, send_resp: 3]

  def init(opts), do: opts

  def call(conn, _opts) do
    # Remove '/redirect' from the request path before redirecting
    target_path = String.replace_prefix(conn.request_path, "/redirect", "")

    target =
      "http://localhost:4000" <> target_path <> "?" <> URI.encode_query(conn.query_params)

    conn
    |> put_resp_header("location", target)
    |> send_resp(302, "")
  end
end

defmodule QbProxyWeb.Router do
  use QbProxyWeb, :router

  require Logger

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", QbProxyWeb do
    pipe_through :api
  end

  forward "/redirect", RedirectLocal

  forward "/", ReverseProxyPlug,
    upstream: "https://quickbooks.api.intuit.com/",
    response_mode: :buffer,
    error_callback: &__MODULE__.log_reverse_proxy_error/1

  def log_reverse_proxy_error(error) do
    Logger.warning("ReverseProxyPlug network error: #{inspect(error)}")
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:qb_proxy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: QbProxyWeb.Telemetry
    end
  end
end
