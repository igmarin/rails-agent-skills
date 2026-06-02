RSpec.describe Reports::GenerateReport do
  describe '.call' do
    let_it_be(:user) { create(:user) }
    let!(:account) { create(:account, owner: user) }
    let(:params) { { account_id: account.id, format: :pdf } }

    subject(:result) { described_class.call(params) }

    context 'happy path' do
      it 'returns success and creates a report record' do
        expect(result[:success]).to be true
        expect(result[:response][:report]).to be_persisted
      end
    end

    context 'when format is invalid' do
      let(:params) { { account_id: account.id, format: :docx } }

      it 'returns failure and includes error message' do
        expect(result[:success]).to be false
        expect(result[:response][:error][:message]).to include('unsupported format')
      end
    end

    context 'account not found' do
      subject(:result) { described_class.call(account_id: 999_999, format: :pdf) }

      it 'returns not found' do
        expect(result[:success]).to be false
      end
    end
  end
end
