module Tabular
  # This module acts as a namespace for errors thrown throughout the app.
  module Errors
    # Top level error for application specific problems. Never thrown, but can
    # be used as a catch-all.
    BaseError = Class.new(StandardError)

    # Raised when a user tries to login with the wrong password.
    BadPassword = Class.new(BaseError)

    # Raised when a model cannot be created/updated because the new data is
    # invalid.
    InvalidModel = Class.new(BaseError)

    # Raised when a model cannot be found.
    NoSuchModel = Class.new(BaseError)

    # Raised when a password does not match its password confirmation (typcially
    # when creating a user or updating a password).
    PasswordsDoNotMatch = Class.new(BaseError)

    # Raised when the a new password is too short
    PasswordTooShort = Class.new(BaseError)

    # Raised when the user is unauthorized to perform an action.
    Unauthorized = Class.new(BaseError)
  end
end
