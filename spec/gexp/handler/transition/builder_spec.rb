# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper.rb')

describe Gexp::Handler::Transition::Builder do

  shared_examples_for Gexp::Handler::Transition::Builder do

    let(:object) do 
      object = ItemExample.new
      mock(object).config { config }
      object
    end

    let(:actor) {
      actor = Object.new
      stub(actor).object { object }
      stub(actor).subject {}
      stub(actor).provider {}
      actor
    }

    let(:transition) do
      transition = Object.new
      stub(transition).to_name { to }
      stub(transition).from_name { from }
      stub(transition).event { event }
      stub(transition).args { [ actor ] }

      transition
    end

    let(:object_param) do
      object = Object.new
      stub(object).config { config }
      object
    end

    let(:subject) do
      Gexp::Handler::Transition::Builder.new \
        transition,
        object_param,
        subject_param,
        provider_param
    end

    it "должен возвращать массив чекеров" do
      subject.checkers.should == result_chekers
    end

    it "должен возвращать массив модифаеров" do
      subject.modifiers.should == result_modifiers
    end

  end

  context "Define handler example" do

    it_behaves_like Gexp::Handler::Transition::Builder do
      let(:to) { :prebuilded }
      let(:from) { :created }
      let(:event) { :place }
      let(:config) do 
        conf = Object.new
        stub(conf).to_hash { { states: {
          events: {
            place: {
              check: [
                [ :resources, :subject, { wood: 5, energy: 1 } ],
                [ :subject, [ :place_allowed?, :not_blocked? ] ],
              ],
              modify: [
                [ :object, [ :change_tile_type! ] ]
              ]
            },
            sell: {
              check: [
                [ :object, [ :has_current_user? ] ]
              ]
            }
          },
          transitions: {
            created: {
              selled: { },
              prebuilded: {
                check: [
                  [ :shared_resources, :subject, { 0 => 5 } ]
                ],
                modify: [
                  [ :shared_resources, :subject, { 0 => 5 } ],
                  [ :resources, :subject, { wood: -5, energy: -1 } ],
                  [ :shared_resources, :subject, { 0 => -5 } ]
                ]
              }
            }
          }
        } } }
      end

      let(:result_chekers) { 
        [
          [ :resources, :subject, { wood: 5, energy: 1 } ],
          [ :subject, [ :place_allowed?, :not_blocked? ] ],
          [ :shared_resources, :subject, { 0 => 5 } ],
        ] 
      }
      let(:result_modifiers) { 
        [
          [ :object, [ :change_tile_type! ] ],
          [ :shared_resources, :subject, { 0 => 5 } ],
          [ :resources, :subject, { wood: -5, energy: -1 } ],
          [ :shared_resources, :subject, { 0 => -5 } ]
        ]
      }
      let(:subject_param) { Object.new }
      let(:provider_param) { Object.new }

    end

  end
end