require 'spec_helper'

describe Tabular::Queries::Tabs do
  describe '.search' do
    context 'when there are no matching records' do
      it 'returns no records' do
        expect(subject.search('No Matches')).to be_empty
      end
    end

    context 'when there are matching records' do
      let(:tab_one) do
        build :tab,
          artist: 'Grizzly Bear',
          album: 'Shields',
          title: 'Sleeping Ute'
      end
      let(:tab_two) do
        build :tab,
          artist: 'Ben Folds',
          album: 'Rockin\' the Suburbs',
          title: 'Rockin\' the Suburbs'
      end
      let(:tab_three) do
        build :tab,
          artist: 'Arcade Fire',
          album: 'The Suburbs',
          title: 'The Suburbs'
      end

      let(:tabs) { [tab_one, tab_two, tab_three] }
      let(:query) { 'The Suburbs' }
      let(:matched_tabs) { [tab_two, tab_three] }

      before { tabs.each(&:save!) }

      it 'returns those records' do
        expect(subject.search(query)).to eq(matched_tabs)
      end
    end

    context 'when there is an attempted SQL injection' do
      it 'is escaped' do
        expect(subject.search('; DROP TABLE tabs; --')).to be_empty
        expect { subject.search('valid query') }.to_not raise_error
      end
    end
  end
end
