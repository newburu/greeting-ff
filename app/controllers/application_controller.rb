class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # エラー画面の設定
  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end
  
  include ErrorHandlers if Rails.env.production? or Rails.env.staging?  # 開発に影響が出ないように、本番と検証環境のみに適用する

end
