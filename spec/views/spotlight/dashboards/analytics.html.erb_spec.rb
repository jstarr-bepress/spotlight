# frozen_string_literal: true

describe 'spotlight/dashboards/analytics.html.erb', type: :view do
  let(:current_exhibit) { FactoryBot.create(:exhibit) }

  before do
    allow(view).to receive_messages(current_exhibit: current_exhibit, exhibit_root_path: '/some/path')
  end

  it 'has a header' do
    render
    expect(rendered).to have_selector '.page-header', text: 'Curation'
    expect(rendered).to have_selector '.page-header small', text: 'Analytics'
  end

  it 'has directions for configuring analytics' do
    render
    expect(rendered).to have_link 'configure an analytics provider'
  end

  context 'with a configured analytics integration' do
    before do
      allow(current_exhibit).to receive(:analytics_provider).and_return(double(Spotlight::Analytics::Ga, enabled?: true))
      stub_template 'spotlight/dashboards/_analytics.html.erb' => 'Analytics data'
    end

    it 'has analytics data' do
      render

      expect(rendered).to have_content 'Analytics data'
    end
  end
end
