require 'rubygems'
require 'active_resource'
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module HelperMethods
  def define_helper_method(klass, name, code, *args)
    method_name = (name.is_a? Symbol) ? name : name.to_sym
    klass.class_eval do
      define_method method_name do
        code.call(*args)
      end
    end
  end
end

describe "basic functionallity callbacks with ActiveResource" do

  before :all do
    class Mock < ActiveResource::Base
      acts_with_callbacks

      self.site = 'http://localhost:3000'

      before_save :test_for_save
      after_destroy :test_for_destroy
      
      private
      
      def test_for_save
        true
      end

      def test_for_destroy
        true
      end
    end

    response = {:id => 1, :datum => "blah"}.to_xml(:root => "data")

    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/mocks.xml", {}, response, 201
      mock.get "/mocks/1.xml", {}, response
      mock.put "/mocks/1.xml", {}, nil, 204
      mock.delete "/mocks/1.xml", {}, nil, 200
    end
  end

  before :each do
    @it = Mock.find(1)
  end

  it "should not raise an error" do
    @it.datum.should_not be_empty
    lambda {
      @it.save
    }.should_not raise_error
  end

  it "should save correct data" do
    @it.datum = "new"
    @it.should be_valid
    @it.should_receive(:save).and_return(true)
    @it.save
  end

  it "should save correct data" do
    @it.should_receive(:destroy).and_return(true)
    @it.destroy
  end

  it "should recieve simple_for_save" do
    @it.datum = "new"
    @it.should_receive(:test_for_save).and_return(true)
    @it.save
  end

  it "should recieve simple_for_save" do
    @it.datum = "new"
    @it.should_receive(:test_for_destroy).and_return(true)
    @it.destroy
  end
end

describe "before_save callbacks with ActiveResource" do
  include HelperMethods

  before :all do
    class Mock < ActiveResource::Base
      acts_with_callbacks

      self.site = 'http://localhost:3000'
    end

    response = {:id => 1, :datum => "blah"}.to_xml(:root => "data")

    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/mocks.xml", {}, response, 201
      mock.get "/mocks/1.xml", {}, response
      mock.put "/mocks/1.xml", {}, nil, 204
      mock.delete "/mocks/1.xml", {}, nil, 200
    end
  end

  before :each do
    @it = Mock.find(1)
  end

  it "should call before_save callbacks before save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "first")

    Mock.instance_eval do
      before_save :ordering
    end

    @it.save { logger.call("second") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call after_save callbacks after save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "second")

    Mock.instance_eval do
      after_save :ordering
    end

    @it.save { logger.call("first") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call before_destroy callbacks before destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "first")

    Mock.instance_eval do
      before_destroy :ordering
    end

    @it.destroy { logger.call("second") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call after_destroy callbacks after destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "second")

    Mock.instance_eval do
      after_destroy :ordering
    end

    @it.destroy { logger.call("first") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call multiple callbacks for before_save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      before_save :one, :two, :three
    end

    @it.save

    log.should include("one was called", "two was called", "three was called")
  end

  it "should call multiple callbacks for after_save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      after_save :one, :two, :three
    end

    @it.save

    log.should include("one was called", "two was called", "three was called")
  end

  it "should call multiple callbacks for before_destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      before_destroy :one, :two, :three
    end

    @it.destroy

    log.should include("one was called", "two was called", "three was called")
  end

  it "should call multiple callbacks for after_destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      after_destroy :one, :two, :three
    end

    @it.destroy

    log.should include("one was called", "two was called", "three was called")
  end
end