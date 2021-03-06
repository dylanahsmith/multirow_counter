require 'helper'

describe MultirowCounter do
  before do
    reset_tables
  end

  it "should respond to #version" do
    assert @shop.respond_to?(:version)
  end

  it "should begin at 0" do
    assert_equal 0, @shop.version
  end

  it "should allow incrementing" do
    @shop.new_version!
    assert_equal 1, @shop.version
  end

  it "supports many increments" do
    10.times { @shop.new_version! }
    assert_equal 10, @shop.version
  end

  it "supports batch increments" do
    @shop.new_version!(10)
    assert_equal 10, @shop.version
  end

  it "should not send all increments to the same row" do
    10.times { @shop.new_version! }

    shop_versions = ShopVersion.where(:shop_id => @shop.id)
    refute shop_versions.any? { |v| v.value == 10 }
  end

  it "requires the number of rows to be specified" do
    class Foo < ActiveRecord::Base
      lambda { 
        multirow_counter :the_count, :random => 'oops'
      }.must_raise ArgumentError
    end
  end

  it "defines a second obscure getter" do
    @shop.multirow_counter_version.must_equal @shop.version
  end
end

