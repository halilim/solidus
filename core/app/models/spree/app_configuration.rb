# This is the primary location for defining spree preferences
#
# The expectation is that this is created once and stored in
# the spree environment
#
# setters:
# a.color = :blue
# a[:color] = :blue
# a.set :color = :blue
# a.preferred_color = :blue
#
# getters:
# a.color
# a[:color]
# a.get :color
# a.preferred_color
#
require "spree/core/search/base"
require "spree/core/search/variant"

module Spree
  class AppConfiguration < Preferences::Configuration
    # Alphabetized to more easily lookup particular preferences
    preference :address_requires_state, :boolean, default: true # should state/state_name be required
    preference :admin_interface_logo, :string, default: 'logo/spree_50.png'
    preference :admin_products_per_page, :integer, default: 10
    preference :admin_variants_per_page, :integer, default: 20
    preference :allow_checkout_on_gateway_error, :boolean, default: false
    preference :allow_guest_checkout, :boolean, default: true
    preference :allow_return_item_amount_editing, :boolean, default: false # Determines whether an admin is allowed to change a return item's pre-calculated amount
    preference :alternative_billing_phone, :boolean, default: false # Request extra phone for bill addr
    preference :alternative_shipping_phone, :boolean, default: false # Request extra phone for ship addr
    preference :always_put_site_name_in_title, :boolean, default: true
    preference :auto_capture, :boolean, default: false # automatically capture the credit card (as opposed to just authorize and capture later)
    preference :binary_inventory_cache, :boolean, default: false # only invalidate product cache when a stock item changes whether it is in_stock
    preference :checkout_zone, :string, default: nil # replace with the name of a zone if you would like to limit the countries
    preference :company, :boolean, default: false # Request company field for billing and shipping addr
    preference :create_rma_for_unreturned_exchange, :boolean, default: false # allows rma to be created for items after unreturned exchange charge has been made
    preference :currency, :string, default: "USD"
    preference :default_country_id, :integer
    preference :expedited_exchanges, :boolean, default: false # NOTE this requires payment profiles to be supported on your gateway of choice as well as a delayed job handler to be configured with activejob. kicks off an exchange shipment upon return authorization save. charge customer if they do not return items within timely manner.
    preference :expedited_exchanges_days_window, :integer, default: 14 # the amount of days the customer has to return their item after the expedited exchange is shipped in order to avoid being charged
    preference :layout, :string, default: 'spree/layouts/spree_application'
    preference :logo, :string, default: 'logo/spree_50.png'
    preference :max_level_in_taxons_menu, :integer, default: 1 # maximum nesting level in taxons menu
    preference :order_mutex_max_age, :integer, default: 2.minutes
    preference :orders_per_page, :integer, default: 15
    preference :properties_per_page, :integer, default: 15
    preference :products_per_page, :integer, default: 12
    preference :promotions_per_page, :integer, default: 15
    preference :customer_returns_per_page, :integer, default: 15
    preference :require_master_price, :boolean, default: true
    preference :return_eligibility_number_of_days, :integer, default: 365
    preference :shipping_instructions, :boolean, default: false # Request instructions/info for shipping
    preference :show_only_complete_orders_by_default, :boolean, default: true
    preference :show_variant_full_price, :boolean, default: false #Displays variant full price or difference with product price. Default false to be compatible with older behavior
    preference :show_products_without_price, :boolean, default: false
    preference :show_raw_product_description, :boolean, :default => false
    preference :tax_using_ship_address, :boolean, default: true
    preference :track_inventory_levels, :boolean, default: true # Determines whether to track on_hand values for variants / products.

    # Default mail headers settings
    preference :send_core_emails, :boolean, :default => true
    preference :mails_from, :string, :default => 'spree@example.com'

    # Store credits configurations
    preference :credit_to_new_allocation, :boolean, default: false

    # searcher_class allows spree extension writers to provide their own Search class
    def searcher_class
      @searcher_class ||= Spree::Core::Search::Base
    end

    def searcher_class=(sclass)
      @searcher_class = sclass
    end

    # all the following can be deprecated when store prefs are no longer supported
    DEPRECATED_STORE_PREFERENCES = {
      site_name: :name,
      site_url: :url,
      default_meta_description: :meta_description,
      default_meta_keywords: :meta_keywords,
      default_seo_title: :seo_title,
    }

    DEPRECATED_STORE_PREFERENCES.each do |old_preference_name, store_method|
      # Avoid warning about implementation details
      bc = ActiveSupport::BacktraceCleaner.new
      bc.add_silencer { |line| line =~ %r{spree/preferences} }

      # support all the old preference methods with a warning
      define_method "preferred_#{old_preference_name}" do
        ActiveSupport::Deprecation.warn("#{old_preference_name} is no longer supported on Spree::Config, please access it through #{store_method} on Spree::Store", bc.clean(caller))
        Store.default.send(store_method)
      end
    end
  end
end
