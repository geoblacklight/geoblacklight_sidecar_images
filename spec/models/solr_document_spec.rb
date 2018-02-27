describe SolrDocument, type: :model do
  let(:document) { described_class.new(id: 'abcd123') }
  subject { document }

  describe '#sidecar' do
    it 'returns a sidecar for adding fields' do
      expect(subject.sidecar).to be_kind_of SolrDocumentSidecar
      expect(subject.sidecar).to eq exhibit
    end
  end
end
