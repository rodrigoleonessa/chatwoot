class Api::V1::Accounts::Google::CalendarsController < Api::V1::Accounts::BaseController
  include GoogleConcern

  def index
    response = google_client.request(:get, 'https://www.googleapis.com/calendar/v3/calendars/primary/events',
                                     access_token: access_token,
                                     params: {
                                       timeMin: Time.zone.now.iso8601,
                                       maxResults: 20,
                                       singleEvents: true,
                                       orderBy: 'startTime'
                                     })
    render json: JSON.parse(response.body)
  rescue OAuth2::Error => e
    render json: { error: e.message }, status: :unauthorized
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def access_token
    # We look for the user's google access token.
    # In Chatwoot, this is typically stored in the Authorization model, or via an Inbox channel.
    # For a personal calendar integration, we'll check for a Google OAuth authorization linked to the user.
    
    # Assuming the user has connected via Profile > Integrations or similar flow that creates an Authorization
    authorization = current_user.present? ? AuthenticationProvider.find_by(name: 'google_oauth2', user: current_user) : nil

    # If no user-level auth, we might fallback to account-level if appropriate, but for calendar it should be user-specific.
    if authorization
       # Ensure token is fresh
       # authorization.refresh_token! if authorization.expires_at < Time.zone.now
       return authorization.token
    end

    # If we are in an development/test mode without real auth, we might raise or return nil
    raise "Google Account not connected" 
  end
end
