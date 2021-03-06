require 'spec_helper'

describe Eventifier::Preferences do
  let(:preferences) { Eventifier::Preferences.new double('User') }
  let(:settings)    { double 'Settings', :preferences => {} }

  before :each do
    Eventifier::NotificationMapping.stub :notification_mappings => {
      'create.posts'    => [:readers],
      'create.comments' => [{:post => :readers}]
    }
    Eventifier::NotificationSetting.stub :for_user => settings
  end

  describe '#to_hashes' do
    it "interprets each key" do
      expect(preferences.to_hashes.collect { |hash| hash[:key] }).to eq [
        'default',
        'create_posts_notify_readers',
        'create_comments_notify_post_readers'
      ]
    end

    it "sets values to true if unknown" do
      expect(preferences.to_hashes.collect { |hash| hash[:value] }).
        to eq [true, true, true]
    end

    it "sets values to true if known and true" do
      settings.preferences['email'] = {}
      settings.preferences['email']['create_posts_notify_readers'] = true

      expect(preferences.to_hashes.collect { |hash| hash[:value] }).
        to eq [true, true, true]
    end

    it "sets values to false if known and false" do
      settings.preferences['email'] = {}
      settings.preferences['email']['create_posts_notify_readers'] = false

      expect(preferences.to_hashes.collect { |hash| hash[:value] }).
        to eq [true, false, true]
    end

    it "returns keys if no translations available for labels" do
      expect(preferences.to_hashes.collect { |hash| hash[:label] }).to eq [
        'default',
        'create_posts_notify_readers',
        'create_comments_notify_post_readers'
      ]
    end

    it "matches translations for labels" do
      I18n.backend.reload!
      I18n.backend.store_translations :en, :events => {
        :labels => {
          :preferences => {
            'default'                             => 'All Events',
            'create_posts_notify_readers'         => 'New Posts',
            'create_comments_notify_post_readers' => 'New Comments'
          }
        }
      }

      expect(preferences.to_hashes.collect { |hash| hash[:label] }).
        to eq ['All Events', 'New Posts', 'New Comments']
    end
  end

  describe '#update' do
    before :each do
      settings.stub save: true
    end

    it "updates the user's email preferences" do
      preferences.update(
        'create_posts_notify_readers'         => '',
        'create_comments_notify_post_readers' => '0'
      )

      expect(
        settings.preferences['email']['create_posts_notify_readers']
      ).to be_truthy
      expect(
        settings.preferences['email']['create_comments_notify_post_readers']
      ).to be_falsey
    end

    it "sets everything to false if no preferences are supplied" do
      preferences.update({})

      expect(
        settings.preferences['email']['create_posts_notify_readers']
      ).to be_falsey
      expect(
        settings.preferences['email']['create_comments_notify_post_readers']
      ).to be_falsey
    end

    it 'saves the settings changes' do
      settings.should_receive(:save)

      preferences.update('create_posts_notify_readers' => '')
    end
  end
end
