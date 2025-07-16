require 'paypal_server_sdk'

class PaypalService
  include PaypalServerSdk

  def self.client
    @client ||= PaypalServerSdk::Client.new(
      client_credentials_auth_credentials: ClientCredentialsAuthCredentials.new(
        o_auth_client_id: ENV['PAYPAL_CLIENT_ID'],
        o_auth_client_secret: ENV['PAYPAL_SECRET_KEY']
      ),
      environment: Environment::SANDBOX,
      logging_configuration: LoggingConfiguration.new(
        mask_sensitive_headers: false,
        log_level: Logger::INFO,
        request_logging_config: RequestLoggingConfiguration.new(
          log_headers: true,
          log_body: true,
        ),
        response_logging_config: ResponseLoggingConfiguration.new(
          log_headers: true,
          log_body: true
        )
      )
    )
  end

  def self.create_order(cart, success_url, cancel_url)
    order_response = client.orders.create_order({
      'body' => OrderRequest.new(
        intent: CheckoutPaymentIntent::CAPTURE,
        purchase_units: [
          PurchaseUnitRequest.new(
            amount: AmountWithBreakdown.new(
              currency_code: 'MXN',
              value: cart.cart_items.sum { |item| item.product.price * item.quantity },
              breakdown: AmountBreakdown.new(
                item_total: Money.new(
                  currency_code: 'MXN',
                  value: cart.cart_items.sum { |item| item.product.price * item.quantity }
                )
              )
            ),
            items: cart.cart_items.map do |item|
              Item.new(
                name: item.product.name,
                unit_amount: Money.new(
                  currency_code: 'MXN',
                  value: item.product.price
                ),
                quantity: item.quantity,
                sku: item.product.id,
                category: ItemCategory::PHYSICAL_GOODS
              )
            end,
          )
        ],
      )
    })
    
    order_response.data
  end

  def self.capture_order(paypal_order_id)
    client.orders.capture_order({
      'id' => paypal_order_id,
      'prefer' => 'return=representation'
    })
  end
end 