# spec/models/invoice_spec.rb

RSpec.describe Invoice, type: :model do
  describe '#overdue?' do
    let!(:user) { create(:user, name: 'Alice', email: 'alice@example.com', role: 'customer', plan: 'pro', verified: true) }
    let!(:account) { create(:account, owner: user, name: 'Alice Corp', subdomain: 'alice', tier: 'enterprise') }
    let!(:invoice) { create(:invoice, account: account, amount_cents: 5000, currency: 'USD', status: 'unpaid', notes: 'Q1 invoice') }

    context 'when invoice is past due' do
      it 'is overdue' do
        invoice.update!(due_date: 30.days.ago)
        expect(invoice).to be_overdue
      end
    end

    context 'when due date is today' do
      it 'is not overdue' do
        invoice.update!(due_date: Date.today)
        expect(invoice).not_to be_overdue
      end
    end
  end

  describe '#total_with_tax' do
    let!(:invoice) { create(:invoice, amount_cents: 10000, tax_rate: 0.1) }

    it 'returns amount plus tax' do
      expect(invoice.total_with_tax).to eq(11000)
    end
  end
end
