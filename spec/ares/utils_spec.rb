require 'spec_helper'

describe Ares::Utils do
  describe Ares::Utils::Buildable do
    class TestBuilder
      extend Ares::Utils::Buildable

      attr_builder :test
    end

    subject { TestBuilder.new }

    it 'creates method' do
      expect(subject).to respond_to :test
    end

    describe '#test' do
      it 'sets value to instance var' do
        subject.test('test')
        value = subject.instance_variable_get :@test
        expect(value).to eq 'test'
      end

      it 'returns self after set' do
        builder = subject.test('test')
        expect(builder).to be subject
      end

      it 'returns set value' do
        subject.test('test')
        expect(subject.test).to eq 'test'
      end
    end
  end
end