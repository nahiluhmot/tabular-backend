require 'spec_helper'

describe Tabular::Services::Presenters do
  describe '#present!' do
    context 'when the object has no presenter' do
      it 'fails with a PresentationError' do
        expect { subject.present!(:no_presenter) }
          .to raise_error(Tabular::Errors::PresentationError)
      end
    end

    context 'when the model has a presenter' do
      let(:user) { create(:user) }

      it 'presents the model' do
        expect(subject.present!(user)).to eq('username' => user.username)
      end
    end
  end

  describe '#present_with!' do
    let(:presenter) do
      Class.new do
        def initialize(data)
          @data = data
        end

        def present
          @data.slice(:age, :name)
        end
      end
    end
    let(:data) { { age: 22, name: 'Tom', height: 70 } }
    let(:expected) { { age: 22, name: 'Tom' } }

    it 'presents the model with the specified class' do
      expect(subject.present_with!(data, presenter)).to eq(expected)
    end
  end

  describe '#present_json!' do
    let(:user) { create(:user) }

    it 'calls to_json on the presented object' do
      expect(subject.present_json!(user))
        .to eq({ username: user.username }.to_json)
    end
  end

  describe '#present_json_wih!' do
    let(:presenter) do
      Class.new do
        def initialize(data)
          @data = data
        end

        def present
          @data.select(&:odd?)
        end
      end
    end
    let(:expected) { [1, 3].to_json }
    let(:data) { [1, 2, 3] }

    it 'calls to_json on the presented object' do
      expect(subject.present_json_with!(data, presenter)).to eq(expected)
    end
  end
end
